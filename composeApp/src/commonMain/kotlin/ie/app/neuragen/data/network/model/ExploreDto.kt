package ie.app.neuragen.data.network.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

@Serializable
data class ExploreItemDto(
    val id: String,
    val assetVersionId: String,
    val title: String? = null,
    val topic: String? = null,
    val isTrending: Boolean? = null,
    val score: Float? = null,
    val createdAt: String,
    val postId: String? = null,
    val assetVersion: AssetVersionDto? = null,
    val post: PostDto? = null,
    val thumbnailUrl: String? = null
)

@Serializable
data class ExploreResponse(
    val mode: String,
    val data: List<ExploreItemDto>,
    val nextCursor: String? = null,
    val limit: Int? = null
)

@Serializable
data class ForYouResponse(
    val mode: String,
    val data: List<ExploreItemDto>,
    val nextCursor: String? = null,
    val limit: Int? = null,
    val signals: JsonObject? = null,
    val fallback: String? = null
)

@Serializable
data class ExploreEventRequest(
    val postId: String,
    val eventType: String, // IMPRESSION|OPEN_POST|WATCH_3S|WATCH_50|LIKE|COMMENT|FOLLOW_CREATOR|HIDE
    val metadata: JsonObject? = null
)

@Serializable
data class ExploreEventResponse(
    val ok: Boolean,
    val postId: String,
    val topic: String? = null,
    val eventType: String,
    val weight: Float? = null
)

@Serializable
data class BatchExploreEventRequest(
    val events: List<ExploreEventRequest>
)

@Serializable
data class BatchExploreEventResponse(
    val ok: Boolean,
    val requested: Int,
    val accepted: Int,
    val recordedCount: Int,
    val skippedCount: Int,
    val groupedByType: JsonObject? = null,
    val topicUpdates: List<TopicUpdateDto>? = null,
    val hiddenPostCount: Int? = null
)

@Serializable
data class TopicUpdateDto(
    val topic: String,
    val totalWeight: Float
)
