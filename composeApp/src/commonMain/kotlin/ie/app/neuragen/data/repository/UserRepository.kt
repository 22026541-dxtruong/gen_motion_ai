package ie.app.neuragen.data.repository

import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import org.koin.core.annotation.Factory
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface UserRepository {
    suspend fun getMe(cursor: String? = null, take: Int? = null): Result<UserMeDto>
    suspend fun updateMe(update: UserUpdateDto): Result<UserDto>
    suspend fun deleteMe(): Result<UserDto>
    suspend fun getUser(id: String): Result<UserPublicDto>
    suspend fun topupCredits(amount: Int, note: String? = null): Result<CreditTopupResponse>
}

@Single([UserRepository::class])
class UserRepositoryImpl(
    @Provided
    private val api: NeuraGenApi
) : UserRepository {

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
}
