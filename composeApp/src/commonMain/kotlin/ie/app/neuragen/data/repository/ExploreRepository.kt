package ie.app.neuragen.data.repository

import ie.app.neuragen.data.local.dao.ExploreDao
import ie.app.neuragen.data.local.entity.CachedExploreItem
import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import ie.app.neuragen.util.currentTimeMillis
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface ExploreRepository {
    suspend fun getExplore(
        topic: String? = null,
        trending: Boolean? = null,
        mode: String? = null,
        sort: String? = null,
        limit: Int? = null,
        cursor: String? = null
    ): Result<ExploreResponse>

    suspend fun searchExplore(
        topic: String,
        trending: Boolean? = null,
        sort: String? = null,
        limit: Int? = null,
        cursor: String? = null
    ): Result<ExploreResponse>

    suspend fun getForYou(
        topic: String? = null,
        trending: Boolean? = null,
        mode: String? = null,
        sort: String? = null,
        limit: Int? = null,
        cursor: String? = null
    ): Result<ForYouResponse>

    suspend fun recordEvent(request: ExploreEventRequest): Result<ExploreEventResponse>
    suspend fun recordEventsBatch(events: List<ExploreEventRequest>): Result<BatchExploreEventResponse>

    // ── Cache-first API ──
    fun observeExplore(mode: String): Flow<List<ExploreItemDto>>
    suspend fun refreshAndCacheExplore(
        topic: String? = null,
        trending: Boolean? = null,
        mode: String? = null,
        sort: String? = null,
        limit: Int? = null
    ): Result<ExploreResponse>
}

@Single(binds = [ExploreRepository::class])
class ExploreRepositoryImpl(
    @Provided private val api: NeuraGenApi,
    @Provided private val exploreDao: ExploreDao
) : ExploreRepository {

    private val json = Json { ignoreUnknownKeys = true }

    // ── Network-only (existing, for pagination/search) ──

    override suspend fun getExplore(
        topic: String?,
        trending: Boolean?,
        mode: String?,
        sort: String?,
        limit: Int?,
        cursor: String?
    ): Result<ExploreResponse> = runCatching {
        api.getExplore(topic, trending, mode, sort, limit, cursor)
    }

    override suspend fun searchExplore(
        topic: String,
        trending: Boolean?,
        sort: String?,
        limit: Int?,
        cursor: String?
    ): Result<ExploreResponse> = runCatching {
        api.searchExplore(topic, trending, sort, limit, cursor)
    }

    override suspend fun getForYou(
        topic: String?,
        trending: Boolean?,
        mode: String?,
        sort: String?,
        limit: Int?,
        cursor: String?
    ): Result<ForYouResponse> = runCatching {
        api.getForYou(topic, trending, mode, sort, limit, cursor)
    }

    override suspend fun recordEvent(request: ExploreEventRequest): Result<ExploreEventResponse> = runCatching {
        api.recordExploreEvent(request)
    }

    override suspend fun recordEventsBatch(events: List<ExploreEventRequest>): Result<BatchExploreEventResponse> = runCatching {
        api.recordExploreEventsBatch(BatchExploreEventRequest(events))
    }

    // ── Cache-first Flow ──

    override fun observeExplore(mode: String): Flow<List<ExploreItemDto>> {
        return exploreDao.getByMode(mode).map { cachedList ->
            cachedList.mapNotNull { cached ->
                try {
                    json.decodeFromString<ExploreItemDto>(cached.jsonData)
                } catch (e: Exception) {
                    null
                }
            }
        }
    }

    override suspend fun refreshAndCacheExplore(
        topic: String?,
        trending: Boolean?,
        mode: String?,
        sort: String?,
        limit: Int?
    ): Result<ExploreResponse> {
        val result = runCatching {
            api.getExplore(topic, trending, mode, sort, limit, null)
        }
        result.getOrNull()?.let { response ->
            val resolvedMode = mode ?: "trending"
            val now = currentTimeMillis()
            val cached = response.data.mapIndexed { i, item ->
                CachedExploreItem(
                    id = item.id,
                    jsonData = json.encodeToString(item),
                    mode = resolvedMode,
                    cachedAt = now,
                    sortOrder = i
                )
            }
            exploreDao.clearByMode(resolvedMode)
            exploreDao.insertAll(cached)
        }
        return result
    }

}
