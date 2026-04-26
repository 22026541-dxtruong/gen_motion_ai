package ie.app.neuragen.data.network.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

@Serializable
data class AssetDto(
    @SerialName("id")
    val id: String? = null,
    @SerialName("userId")
    val userId: String? = null,
    @SerialName("jobId")
    val jobId: String? = null,
    @SerialName("type")
    val type: String? = null, // IMAGE|VIDEO|THUMBNAIL|AUDIO
    @SerialName("role")
    val role: String? = null, // INPUT|OUTPUT|THUMBNAIL|PREVIEW|TEMP
    @SerialName("mimeType")
    val mimeType: String? = null,
    @SerialName("originalName")
    val originalName: String? = null,
    @SerialName("createdAt")
    val createdAt: String? = null,
    @SerialName("updatedAt")
    val updatedAt: String? = null,
    @SerialName("versions")
    val versions: List<AssetVersionDto>? = null,
    @SerialName("user")
    val user: UserPublicDto? = null,
    @SerialName("job")
    val job: AssetJobSummaryDto? = null
)

@Serializable
data class AssetVersionDto(
    val id: String? = null,
    val assetId: String? = null,
    val version: Int? = null,
    val storageProvider: String? = null,
    val bucket: String? = null,
    val objectKey: String? = null,
    val fileUrl: String? = null,
    val originalName: String? = null,
    val mimeType: String? = null,
    val sizeBytes: Long? = null,
    val seed: Long? = null,
    val width: Int? = null,
    val height: Int? = null,
    val durationMs: Int? = null,
    val quality: String? = null,
    val metadata: JsonObject? = null,
    val createdAt: String? = null
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
