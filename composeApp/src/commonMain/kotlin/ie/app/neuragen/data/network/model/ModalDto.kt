package ie.app.neuragen.data.network.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

@Serializable
data class ModalGenerateVideoRequest(
    val prompt: String,
    val negativePrompt: String? = null,
    val inputImageUrl: String? = null,
    val jobId: String? = null,
    val provider: String? = null,
    val modelName: String? = null,
    val presetId: String? = null,
    val userId: String? = null,
    val workflow: String? = null
)
// Response is JsonObject or similar as it depends on external service
