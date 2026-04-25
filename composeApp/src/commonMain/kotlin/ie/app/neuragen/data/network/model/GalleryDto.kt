package ie.app.neuragen.data.network.model

import kotlinx.serialization.Serializable

@Serializable
data class CreateGalleryItemRequest(
    val assetVersionId: String,
    val isPublic: Boolean
)

@Serializable
data class GalleryItemDto(
    val id: String,
    val userId: String,
    val assetVersionId: String,
    val isPublic: Boolean,
    val createdAt: String,
    val assetVersion: AssetVersionDto? = null
)

@Serializable
data class UpdateGalleryItemRequest(
    val isPublic: Boolean
)
