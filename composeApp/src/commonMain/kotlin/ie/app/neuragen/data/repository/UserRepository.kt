package ie.app.neuragen.data.repository

import ie.app.neuragen.data.local.dao.UserProfileDao
import ie.app.neuragen.data.local.entity.CachedUserProfile
import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import ie.app.neuragen.util.currentTimeMillis
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface UserRepository {
    suspend fun getMe(cursor: String? = null, take: Int? = null): Result<UserMeDto>
    suspend fun updateMe(update: UserUpdateDto): Result<UserDto>
    suspend fun deleteMe(): Result<UserDto>
    suspend fun getUser(id: String): Result<UserPublicDto>
    suspend fun topupCredits(amount: Int, note: String? = null): Result<CreditTopupResponse>
    fun streamNotifications(): Flow<JobNotificationPayload>

    // ── Cache-first API ──
    fun observeProfile(): Flow<UserMeDto?>
    suspend fun refreshAndCacheProfile(cursor: String? = null, take: Int? = null): Result<UserMeDto>
}

@Single([UserRepository::class])
class UserRepositoryImpl(
    @Provided private val api: NeuraGenApi,
    @Provided private val userProfileDao: UserProfileDao
) : UserRepository {

    private val json = Json { ignoreUnknownKeys = true }

    override suspend fun getMe(cursor: String?, take: Int?): Result<UserMeDto> = runCatching {
        api.getMe(cursor, take)
    }

    override suspend fun updateMe(update: UserUpdateDto): Result<UserDto> = runCatching {
        api.updateMe(update)
    }

    override suspend fun deleteMe(): Result<UserDto> = runCatching {
        api.deleteMe()
    }

    override suspend fun getUser(id: String): Result<UserPublicDto> = runCatching {
        api.getUser(id)
    }

    override suspend fun topupCredits(amount: Int, note: String?): Result<CreditTopupResponse> = runCatching {
        api.topupCredits(CreditTopupRequest(amount, note))
    }

    override fun streamNotifications(): Flow<JobNotificationPayload> = api.streamNotifications()

    // ── Cache-first ──

    override fun observeProfile(): Flow<UserMeDto?> {
        return userProfileDao.get().map { cached ->
            cached?.let {
                try {
                    json.decodeFromString<UserMeDto>(it.jsonData)
                } catch (e: Exception) {
                    null
                }
            }
        }
    }

    override suspend fun refreshAndCacheProfile(cursor: String?, take: Int?): Result<UserMeDto> {
        val result = runCatching { api.getMe(cursor, take) }
        result.getOrNull()?.let { user ->
            val now = currentTimeMillis()
            userProfileDao.insert(
                CachedUserProfile(
                    id = user.id,
                    jsonData = json.encodeToString(user),
                    cachedAt = now
                )
            )
        }
        return result
    }
}
