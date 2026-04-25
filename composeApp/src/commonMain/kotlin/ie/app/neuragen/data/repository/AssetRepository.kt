package ie.app.neuragen.data.repository

import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import org.koin.core.annotation.Factory
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface AssetRepository {
    suspend fun getAsset(id: String): Result<AssetDto>
    suspend fun getDownloadUrl(id: String): Result<DownloadResponse>
    suspend fun getGallery(): Result<List<GalleryItemDto>>
    suspend fun createGalleryItem(assetVersionId: String, isPublic: Boolean): Result<GalleryItemDto>
    suspend fun updateGalleryItem(id: String, isPublic: Boolean): Result<GalleryItemDto>
    suspend fun deleteGalleryItem(id: String): Result<GalleryItemDto>
}

@Single(binds = [AssetRepository::class])
class AssetRepositoryImpl(
    @Provided
    private val api: NeuraGenApi
) : AssetRepository {

    override suspend fun getAsset(id: String): Result<AssetDto> = runCatching {
        api.getAsset(id)
    }

    override suspend fun getDownloadUrl(id: String): Result<DownloadResponse> = runCatching {
        api.getDownloadUrl(id)
    }

    override suspend fun getGallery(): Result<List<GalleryItemDto>> = runCatching {
        api.getGallery()
    }

    override suspend fun createGalleryItem(assetVersionId: String, isPublic: Boolean): Result<GalleryItemDto> = runCatching {
        api.createGalleryItem(CreateGalleryItemRequest(assetVersionId, isPublic))
    }

    override suspend fun updateGalleryItem(id: String, isPublic: Boolean): Result<GalleryItemDto> = runCatching {
        api.updateGalleryItem(id, UpdateGalleryItemRequest(isPublic))
    }

    override suspend fun deleteGalleryItem(id: String): Result<GalleryItemDto> = runCatching {
        api.deleteGalleryItem(id)
    }
}
