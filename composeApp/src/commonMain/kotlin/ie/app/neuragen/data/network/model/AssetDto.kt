package ie.app.neuragen.data.network.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

@Serializable
data class AssetDto(
    val id: String,
    val userId: String,
    val jobId: String? = null,
    val type: String, // IMAGE|VIDEO|THUMBNAIL|AUDIO
    val role: String, // INPUT|OUTPUT|THUMBNAIL|PREVIEW|TEMP
    val mimeType: String? = null,
    val originalName: String? = null,
    val createdAt: String,
    val updatedAt: String,
    val versions: List<AssetVersionDto>? = null,
    val user: UserPublicDto? = null,
    val job: AssetJobSummaryDto? = null
)

@Serializable
data class AssetVersionDto(
    val id: String? = null,
    val assetId: String? = null,
    val version: Int? = null,
    val storageProvider: String? = null,
    val bucket: String,
    val objectKey: String,
    val fileUrl: String? = null,
    val originalName: String? = null,
    val mimeType: String? = null,
    val sizeBytes: Long,
    val seed: Long? = null,
    val width: Int? = null,
    val height: Int? = null,
    val durationMs: Int? = null,
    val quality: String? = null,
    val metadata: JsonObject? = null,
    val createdAt: String
)

@Serializable
data class AssetJobSummaryDto(
    val id: String,
    val type: String,
    val status: String
)

@Serializable
data class DownloadResponse(
    val url: String,
    val expiresIn: Int
)
