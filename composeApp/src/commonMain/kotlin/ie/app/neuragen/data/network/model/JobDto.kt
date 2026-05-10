package ie.app.neuragen.data.network.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class VideoJobRequest(
    @SerialName("inputAssetId")
    val inputAssetId: String? = null,
    @SerialName("prompt")
    val prompt: String,
    @SerialName("negativePrompt")
    val negativePrompt: String? = null,
    @SerialName("presetId")
    val presetId: String,
)

@Serializable
data class JobResponse(
    @SerialName("jobId")
    val jobId: String? = null,
    @SerialName("id")
    val id: String? = null,
    @SerialName("status")
    val status: String? = null,
    @SerialName("creditCost")
    val creditCost: Int? = null,
    @SerialName("provider")
    val provider: String? = null,
    @SerialName("modelName")
    val modelName: String? = null,
    @SerialName("presetId")
    val presetId: String? = null,
    @SerialName("tier")
    val tier: String? = null,
    @SerialName("estimatedDurationSeconds")
    val estimatedDurationSeconds: Int? = null,
    @SerialName("includeBackgroundAudio")
    val includeBackgroundAudio: Boolean? = null,
    @SerialName("output")
    val output: JobOutputDto? = null,
    @SerialName("thumbnail")
    val thumbnail: JobOutputDto? = null
)

@Serializable
data class JobDto(
    val id: String,
    val type: String,
    val status: String,
    val progress: Float,
    val prompt: String,
    val negativePrompt: String? = null,
    val provider: String? = null,
    val modelName: String? = null,
    val presetId: String? = null,
    val tier: String? = null,
    val estimatedDurationSeconds: Int? = null,
    val workflow: String? = null,
    val includeBackgroundAudio: Boolean? = null,
    val creditCost: Int? = null,
    val errorMessage: String? = null,
    val createdAt: String,
    val updatedAt: String,
    val startedAt: String? = null,
    val completedAt: String? = null,
    val failedAt: String? = null,
    val output: JobOutputDto? = null,
    val thumbnail: JobOutputDto? = null,
    val inputAssets: List<AssetDto>? = null,
    val outputAssets: List<AssetDto>? = null,
    val thumbnailAssets: List<AssetDto>? = null,
    val logs: List<JobLogDto>? = null
)

@Serializable
data class JobOutputDto(
    val assetId: String,
    val bucket: String? = null,
    val objectKey: String? = null,
    val mimeType: String? = null,
    val sizeBytes: Long? = null,
    val downloadUrl: String,
    val expiresIn: Int,
    val createdAt: String? = null
)

@Serializable
data class JobLogDto(
    val id: String? = null,
    val jobId: String,
    val message: String,
    val createdAt: String
)

@Serializable
data class JobResultResponse(
    val jobId: String,
    val status: String,
    val progress: Float,
    val creditCost: Int,
    val resultReady: Boolean,
    val provider: String? = null,
    val modelName: String? = null,
    val presetId: String? = null,
    val tier: String? = null,
    val estimatedDurationSeconds: Int? = null,
    val workflow: String? = null,
    val includeBackgroundAudio: Boolean? = null,
    val assetId: String? = null,
    val bucket: String? = null,
    val objectKey: String? = null,
    val mimeType: String? = null,
    val sizeBytes: Long? = null,
    val downloadUrl: String? = null,
    val expiresIn: Int? = null,
    val createdAt: String? = null,
    val thumbnail: JobOutputDto? = null
)

@Serializable
data class CancelJobResponse(
    val jobId: String,
    val status: String,
    val refundedCredit: Int
)

@Serializable
data class JobsPaginationDto(
    val data: List<JobDto>,
    val nextCursor: String? = null,
    val take: Int? = null
)

@Serializable
data class JobSnapshotEvent(
    val jobId: String,
    val status: String,
    val progress: Float,
    val errorMessage: String? = null,
    val provider: String? = null,
    val modelName: String? = null,
    val presetId: String? = null,
    val tier: String? = null,
    val estimatedDurationSeconds: Int? = null,
    val workflow: String? = null,
    val includeBackgroundAudio: Boolean? = null,
    val createdAt: String = "",
    val updatedAt: String = "",
    val startedAt: String? = null,
    val completedAt: String? = null,
    val failedAt: String? = null,
    val logs: List<JobLogDto>? = null
)

@Serializable
data class JobStatusEvent(
    val jobId: String,
    val status: String,
    val progress: Float,
    val errorMessage: String? = null,
    val startedAt: String? = null,
    val completedAt: String? = null,
    val failedAt: String? = null,
    val occurredAt: String = ""
)

@Serializable
data class JobHeartbeatEvent(
    val jobId: String,
    val timestamp: String = ""
)

@Serializable
data class JobLogEvent(
    val jobId: String,
    val message: String,
    val createdAt: String = ""
)

sealed class JobStreamEvent {
    data class Snapshot(val data: JobSnapshotEvent) : JobStreamEvent()
    data class Status(val data: JobStatusEvent) : JobStreamEvent()
    data class Log(val data: JobLogEvent) : JobStreamEvent()
    data class Heartbeat(val data: JobHeartbeatEvent) : JobStreamEvent()
}
