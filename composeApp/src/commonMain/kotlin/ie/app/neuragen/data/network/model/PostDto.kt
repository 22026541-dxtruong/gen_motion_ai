package ie.app.neuragen.data.network.model

import kotlinx.serialization.Serializable

@Serializable
data class CreatePostRequest(
    val assetVersionId: String,
    val caption: String? = null,
    val isPublic: Boolean
)

@Serializable
data class PostDto(
    val id: String,
    val userId: String,
    val assetVersionId: String,
    val caption: String? = null,
    val isPublic: Boolean,
    val likeCount: Int,
    val commentCount: Int,
    val viewCount: Int,
    val createdAt: String,
    val user: UserPublicDto? = null,
    val assetVersion: AssetVersionDto? = null,
    val videoUrl: String? = null,       // Backend computes this from assetVersion
    val thumbnailUrl: String? = null    // Backend computes this from assetVersion
)

@Serializable
data class UpdatePostRequest(
    val assetVersionId: String? = null,
    val caption: String? = null,
    val isPublic: Boolean? = null
)

@Serializable
data class CreateCommentRequest(
    val postId: String,
    val content: String
)

@Serializable
data class CommentDto(
    val id: String,
    val userId: String? = null,
    val postId: String? = null,
    val content: String,
    val createdAt: String,
    val user: UserPublicDto? = null
)

@Serializable
data class CommentsPaginationDto(
    val data: List<CommentDto>,
    val nextCursor: String? = null
)

@Serializable
data class CreatePostLikeRequest(
    val postId: String
)

@Serializable
data class PostLikeDto(
    val id: String,
    val userId: String? = null,
    val postId: String? = null,
    val createdAt: String,
    val user: UserPublicDto? = null
)

@Serializable
data class PostLikesPaginationDto(
    val data: List<PostLikeDto>,
    val nextCursor: String? = null
)

@Serializable
data class CreateFollowRequest(
    val followingId: String
)

@Serializable
data class FollowDto(
    val id: String,
    val followerId: String? = null,
    val followingId: String? = null,
    val createdAt: String? = null,
    val follower: UserPublicDto? = null,
    val following: UserPublicDto? = null
)

@Serializable
data class FollowsPaginationDto(
    val data: List<FollowDto>,
    val nextCursor: String? = null
)
