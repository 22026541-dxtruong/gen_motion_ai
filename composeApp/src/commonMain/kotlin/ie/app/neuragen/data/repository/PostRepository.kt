package ie.app.neuragen.data.repository

import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface PostRepository {
    suspend fun getPosts(): Result<List<PostDto>>
    suspend fun getPost(id: String): Result<PostDto>
    suspend fun createPost(assetVersionId: String, caption: String?, isPublic: Boolean): Result<PostDto>
    suspend fun updatePost(id: String, request: UpdatePostRequest): Result<PostDto>
    suspend fun deletePost(id: String): Result<PostDto>

    suspend fun getComments(postId: String, cursor: String? = null, take: Int? = null): Result<CommentsPaginationDto>
    suspend fun createComment(postId: String, content: String): Result<CommentDto>
    suspend fun updateComment(id: String, content: String, postId: String): Result<CommentDto>
    suspend fun deleteComment(id: String): Result<CommentDto>

    suspend fun getPostLikes(postId: String, cursor: String? = null, take: Int? = null): Result<PostLikesPaginationDto>
    suspend fun likePost(postId: String): Result<PostLikeDto>
    suspend fun unlikePost(postId: String): Result<PostLikeDto>

    suspend fun getFollowers(userId: String, cursor: String? = null, take: Int? = null): Result<FollowsPaginationDto>
    suspend fun getFollowings(userId: String, cursor: String? = null, take: Int? = null): Result<FollowsPaginationDto>
    suspend fun followUser(followingId: String): Result<FollowDto>
    suspend fun unfollowUser(userId: String): Result<FollowDto>

    /**
     * Publish a completed video job as a public post.
     * Resolution chain (mirrors publishVideoAction on web):
     *   1. Direct assetVersionId if provided
     *   2. GET /assets/:assetId → versions[0].id
     *   3. GET /jobs/:jobId → output.assetId → GET /assets/:assetId → versions[0].id
     * Also creates a gallery item automatically.
     */
    suspend fun publishPost(
        jobId: String? = null,
        assetId: String? = null,
        assetVersionId: String? = null,
        caption: String
    ): Result<PostDto>
}

@Single([PostRepository::class])
class PostRepositoryImpl(
    @Provided
    private val api: NeuraGenApi
) : PostRepository {

    override suspend fun getPosts(): Result<List<PostDto>> = runCatching {
        api.getPosts()
    }

    override suspend fun getPost(id: String): Result<PostDto> = runCatching {
        api.getPost(id)
    }

    override suspend fun createPost(assetVersionId: String, caption: String?, isPublic: Boolean): Result<PostDto> = runCatching {
        api.createPost(CreatePostRequest(assetVersionId, caption, isPublic))
    }

    override suspend fun updatePost(id: String, request: UpdatePostRequest): Result<PostDto> = runCatching {
        api.updatePost(id, request)
    }

    override suspend fun deletePost(id: String): Result<PostDto> = runCatching {
        api.deletePost(id)
    }

    override suspend fun getComments(postId: String, cursor: String?, take: Int?): Result<CommentsPaginationDto> = runCatching {
        api.getComments(postId, cursor, take)
    }

    override suspend fun createComment(postId: String, content: String): Result<CommentDto> = runCatching {
        api.createComment(CreateCommentRequest(postId, content))
    }

    override suspend fun updateComment(id: String, content: String, postId: String): Result<CommentDto> = runCatching {
        api.updateComment(id, CreateCommentRequest(postId, content))
    }

    override suspend fun deleteComment(id: String): Result<CommentDto> = runCatching {
        api.deleteComment(id)
    }

    override suspend fun getPostLikes(postId: String, cursor: String?, take: Int?): Result<PostLikesPaginationDto> = runCatching {
        api.getPostLikes(postId, cursor, take)
    }

    override suspend fun likePost(postId: String): Result<PostLikeDto> = runCatching {
        api.likePost(CreatePostLikeRequest(postId))
    }

    override suspend fun unlikePost(postId: String): Result<PostLikeDto> = runCatching {
        api.unlikePost(postId)
    }

    override suspend fun getFollowers(userId: String, cursor: String?, take: Int?): Result<FollowsPaginationDto> = runCatching {
        api.getFollowers(userId, cursor, take)
    }

    override suspend fun getFollowings(userId: String, cursor: String?, take: Int?): Result<FollowsPaginationDto> = runCatching {
        api.getFollowings(userId, cursor, take)
    }

    override suspend fun followUser(followingId: String): Result<FollowDto> = runCatching {
        api.followUser(CreateFollowRequest(followingId))
    }

    override suspend fun unfollowUser(userId: String): Result<FollowDto> = runCatching {
        api.unfollowUser(userId)
    }

    override suspend fun publishPost(
        jobId: String?,
        assetId: String?,
        assetVersionId: String?,
        caption: String
    ): Result<PostDto> = runCatching {
        var resolvedVersionId = assetVersionId
        var resolvedAssetId = assetId

        // Step 1: If no assetId and no versionId, resolve from job
        if (resolvedVersionId == null && resolvedAssetId == null && jobId != null) {
            println("PostRepository: Resolving assetId from job $jobId...")
            val job = api.getJob(jobId)
            resolvedAssetId = job.output?.assetId
            println("PostRepository: Resolved assetId: $resolvedAssetId")
        }

        // Step 2: Resolve assetVersionId from assetId
        if (resolvedVersionId == null && resolvedAssetId != null) {
            println("PostRepository: Resolving assetVersionId from asset $resolvedAssetId...")
            val asset = api.getAsset(resolvedAssetId)
            resolvedVersionId = asset.versions?.firstOrNull()?.id
            println("PostRepository: Resolved assetVersionId: $resolvedVersionId")
        }

        if (resolvedVersionId == null) {
            throw IllegalStateException("Could not resolve asset version ID for publishing.")
        }

        // Step 3: Create the post
        println("PostRepository: Creating post with assetVersionId=$resolvedVersionId, caption='$caption'")
        val post = api.createPost(CreatePostRequest(resolvedVersionId, caption.ifBlank { null }, isPublic = true))

        // Step 4: Also add to gallery (best-effort, ignore failures)
        try {
            api.createGalleryItem(CreateGalleryItemRequest(resolvedVersionId, isPublic = true))
            println("PostRepository: Gallery item created successfully")
        } catch (e: Exception) {
            println("PostRepository: Failed to create gallery item (ignored): ${e.message}")
        }

        post
    }
}
