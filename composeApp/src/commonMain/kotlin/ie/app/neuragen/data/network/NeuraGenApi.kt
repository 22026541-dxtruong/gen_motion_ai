package ie.app.neuragen.data.network

import ie.app.neuragen.data.network.model.*
import kotlinx.serialization.json.JsonObject
import org.koin.core.annotation.Single

interface NeuraGenApi {
    // App
    suspend fun getHello(): String

    // Auth
    suspend fun register(request: RegisterRequest): AuthResponse
    suspend fun login(request: LoginRequest): AuthResponse
    suspend fun googleCallback(query: Map<String, String>): AuthResponse
    suspend fun refreshTokens(request: RefreshRequest): AuthResponse
    suspend fun logout(request: LogoutRequest): MessageResponse
    suspend fun logoutAll(): MessageResponse
    suspend fun changePassword(request: ChangePasswordRequest): MessageResponse
    suspend fun forgotPassword(request: ForgotPasswordRequest): MessageResponse
    suspend fun resetPassword(request: ResetPasswordRequest): MessageResponse

    // Users
    suspend fun updateMe(request: UserUpdateDto): UserDto
    suspend fun getMe(cursor: String? = null, take: Int? = null): UserMeDto
    suspend fun topupCredits(request: CreditTopupRequest): CreditTopupResponse
    suspend fun getUser(id: String): UserPublicDto
    suspend fun deleteMe(): UserDto

    // Posts
    suspend fun createPost(request: CreatePostRequest): PostDto
    suspend fun getPosts(): List<PostDto>
    suspend fun getPost(id: String): PostDto
    suspend fun updatePost(id: String, request: UpdatePostRequest): PostDto
    suspend fun deletePost(id: String): PostDto

    // Comments
    suspend fun createComment(request: CreateCommentRequest): CommentDto
    suspend fun getComments(postId: String, cursor: String? = null, take: Int? = null): CommentsPaginationDto
    suspend fun updateComment(id: String, request: CreateCommentRequest): CommentDto
    suspend fun deleteComment(id: String): CommentDto

    // Post Likes
    suspend fun likePost(request: CreatePostLikeRequest): PostLikeDto
    suspend fun getPostLikes(postId: String, cursor: String? = null, take: Int? = null): PostLikesPaginationDto
    suspend fun unlikePost(postId: String): PostLikeDto

    // Follows
    suspend fun followUser(request: CreateFollowRequest): FollowDto
    suspend fun getFollowers(userId: String, cursor: String? = null, take: Int? = null): FollowsPaginationDto
    suspend fun getFollowings(userId: String, cursor: String? = null, take: Int? = null): FollowsPaginationDto
    suspend fun unfollowUser(userId: String): FollowDto

    // Assets
    suspend fun getAsset(id: String): AssetDto
    suspend fun getDownloadUrl(id: String): DownloadResponse

    // Gallery
    suspend fun createGalleryItem(request: CreateGalleryItemRequest): GalleryItemDto
    suspend fun getGallery(): List<GalleryItemDto>
    suspend fun updateGalleryItem(id: String, request: UpdateGalleryItemRequest): GalleryItemDto
    suspend fun deleteGalleryItem(id: String): GalleryItemDto

    // Explore
    suspend fun getExplore(
        topic: String? = null,
        trending: Boolean? = null,
        mode: String? = null,
        sort: String? = null,
        limit: Int? = null,
        cursor: String? = null
    ): ExploreResponse
    suspend fun getForYou(
        topic: String? = null,
        trending: Boolean? = null,
        mode: String? = null,
        sort: String? = null,
        limit: Int? = null,
        cursor: String? = null
    ): ForYouResponse
    suspend fun recordExploreEvent(request: ExploreEventRequest): ExploreEventResponse
    suspend fun recordExploreEventsBatch(request: BatchExploreEventRequest): BatchExploreEventResponse

    // Jobs
    suspend fun createVideoJob(request: VideoJobRequest): JobResponse
    suspend fun getJobs(): List<JobDto>
    suspend fun getJob(id: String): JobDto
    suspend fun getJobResult(id: String): JobResultResponse
    suspend fun cancelJob(id: String): CancelJobResponse

    // Billing
    suspend fun getBillingCatalog(): BillingCatalogResponse
    suspend fun createOrder(request: CreateOrderRequest): OrderResponse
    suspend fun getMyOrders(): List<OrderResponse>
    suspend fun markOrderPaid(id: String, request: MarkPaidRequest): MarkPaidResponse
    suspend fun confirmPayosWebhook(request: PayosConfirmRequest): PayosConfirmResponse

    // Modal
    suspend fun modalGenerateVideo(request: ModalGenerateVideoRequest): JsonObject
}
