package ie.app.neuragen.data.repository

import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.JsonObject
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class FakeNeuraGenApi : NeuraGenApi {
    override suspend fun getHello(): String = "Hello"
    override suspend fun register(request: RegisterRequest): AuthResponse = AuthResponse("id", "user", "email", "access", "refresh")
    override suspend fun login(request: LoginRequest): AuthResponse = AuthResponse("id", "user", "email", "access", "refresh")
    override suspend fun googleCallback(query: Map<String, String>): AuthResponse = AuthResponse("id", "user", "email", "access", "refresh")
    override suspend fun refreshTokens(request: RefreshRequest): AuthResponse = AuthResponse("id", "user", "email", "access", "refresh")
    override suspend fun logout(request: LogoutRequest): MessageResponse = MessageResponse("Logged out")
    override suspend fun logoutAll(): MessageResponse = MessageResponse("Logged out all")
    override suspend fun changePassword(request: ChangePasswordRequest): MessageResponse = MessageResponse("Changed")
    override suspend fun forgotPassword(request: ForgotPasswordRequest): MessageResponse = MessageResponse("Sent")
    override suspend fun resetPassword(request: ResetPasswordRequest): MessageResponse = MessageResponse("Reset")
    
    // Stub other methods
    override suspend fun updateMe(request: UserUpdateDto): UserDto = TODO()
    override suspend fun getMe(cursor: String?, take: Int?): UserMeDto = TODO()
    override suspend fun topupCredits(request: CreditTopupRequest): CreditTopupResponse = TODO()
    override suspend fun getUser(id: String): UserPublicDto = TODO()
    override suspend fun deleteMe(): UserDto = TODO()
    override suspend fun createPost(request: CreatePostRequest): PostDto = TODO()
    override suspend fun getPosts(): List<PostDto> = TODO()
    override suspend fun getPost(id: String): PostDto = TODO()
    override suspend fun updatePost(id: String, request: UpdatePostRequest): PostDto = TODO()
    override suspend fun deletePost(id: String): PostDto = TODO()
    override suspend fun createComment(request: CreateCommentRequest): CommentDto = TODO()
    override suspend fun getComments(postId: String, cursor: String?, take: Int?): CommentsPaginationDto = TODO()
    override suspend fun updateComment(id: String, request: CreateCommentRequest): CommentDto = TODO()
    override suspend fun deleteComment(id: String): CommentDto = TODO()
    override suspend fun likePost(request: CreatePostLikeRequest): PostLikeDto = TODO()
    override suspend fun getPostLikes(postId: String, cursor: String?, take: Int?): PostLikesPaginationDto = TODO()
    override suspend fun unlikePost(postId: String): PostLikeDto = TODO()
    override suspend fun followUser(request: CreateFollowRequest): FollowDto = TODO()
    override suspend fun getFollowers(userId: String, cursor: String?, take: Int?): FollowsPaginationDto = TODO()
    override suspend fun getFollowings(userId: String, cursor: String?, take: Int?): FollowsPaginationDto = TODO()
    override suspend fun unfollowUser(userId: String): FollowDto = TODO()
    override suspend fun getAsset(id: String): AssetDto = TODO()
    override suspend fun getDownloadUrl(id: String): DownloadResponse = TODO()
    override suspend fun createGalleryItem(request: CreateGalleryItemRequest): GalleryItemDto = TODO()
    override suspend fun getGallery(): List<GalleryItemDto> = TODO()
    override suspend fun updateGalleryItem(id: String, request: UpdateGalleryItemRequest): GalleryItemDto = TODO()
    override suspend fun deleteGalleryItem(id: String): GalleryItemDto = TODO()
    override suspend fun getExplore(topic: String?, trending: Boolean?, mode: String?, sort: String?, limit: Int?, cursor: String?): ExploreResponse = TODO()
    override suspend fun getForYou(topic: String?, trending: Boolean?, mode: String?, sort: String?, limit: Int?, cursor: String?): ForYouResponse = TODO()
    override suspend fun recordExploreEvent(request: ExploreEventRequest): ExploreEventResponse = TODO()
    override suspend fun recordExploreEventsBatch(request: BatchExploreEventRequest): BatchExploreEventResponse = TODO()
    override suspend fun createVideoJob(request: VideoJobRequest): JobResponse = TODO()
    override suspend fun getJobs(): List<JobDto> = TODO()
    override suspend fun getJob(id: String): JobDto = TODO()
    override suspend fun getJobResult(id: String): JobResultResponse = TODO()
    override suspend fun cancelJob(id: String): CancelJobResponse = TODO()
    override suspend fun getBillingCatalog(): BillingCatalogResponse = TODO()
    override suspend fun createOrder(request: CreateOrderRequest): OrderResponse = TODO()
    override suspend fun getMyOrders(): List<OrderResponse> = TODO()
    override suspend fun markOrderPaid(id: String, request: MarkPaidRequest): MarkPaidResponse = TODO()
    override suspend fun confirmPayosWebhook(request: PayosConfirmRequest): PayosConfirmResponse = TODO()
    override suspend fun modalGenerateVideo(request: ModalGenerateVideoRequest): JsonObject = TODO()
}

class AuthRepositoryTest {
    private val api = FakeNeuraGenApi()
    private val repository = AuthRepositoryImpl(api)

    @Test
    fun `login returns success`() = runTest {
        val result = repository.login(LoginRequest("test@test.com", "password"))
        assertTrue(result.isSuccess)
        assertEquals("user", result.getOrNull()?.username)
    }

    @Test
    fun `logout returns success`() = runTest {
        val result = repository.logout("token")
        assertTrue(result.isSuccess)
        assertEquals("Logged out", result.getOrNull()?.message)
    }
}
