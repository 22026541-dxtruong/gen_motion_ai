package ie.app.neuragen.data.network.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class JobNotificationPayload(
    val id: String = "", // Generated locally: "{jobId}-{occurredAt}"
    val jobId: String,
    val kind: String, // JOB_QUEUED | JOB_RETRYING | JOB_PROVIDER_FALLBACK | JOB_COMPLETED | JOB_FAILED | JOB_CANCELLED
    val severity: String, // "info" | "success" | "warning" | "error"
    val title: String,
    val message: String,
    val status: String? = null, // Job status: QUEUED | PROCESSING | COMPLETED | FAILED | CANCELLED
    val progress: Int? = null,
    val provider: String? = null,
    val modelName: String? = null,
    val presetId: String? = null,
    val workflow: String? = null,
    val errorMessage: String? = null,
    val resultReady: Boolean = false,
    val occurredAt: String? = null, // ISO8601 timestamp from backend
    val thumbnailUrl: String? = null,
    var read: Boolean = false
) {
    /** Formatted display timestamp */
    val displayTimestamp: String
        get() = occurredAt ?: ""
}
