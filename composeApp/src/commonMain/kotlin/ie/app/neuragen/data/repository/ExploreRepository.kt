package ie.app.neuragen.data.repository

import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import org.koin.core.annotation.Factory
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
}

@Single(binds = [ExploreRepository::class])
class ExploreRepositoryImpl(
    @Provided
    private val api: NeuraGenApi
) : ExploreRepository {


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
}
