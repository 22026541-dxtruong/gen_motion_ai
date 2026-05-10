package ie.app.neuragen.data.network

import ie.app.neuragen.data.network.model.*
import ie.app.neuragen.data.network.model.JobStreamEvent.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.sse.sse
import io.ktor.client.request.*
import io.ktor.client.request.forms.*
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import org.koin.core.annotation.Single

suspend inline fun <reified T> HttpResponse.bodyOrThrow(): T {
    if (!status.isSuccess()) {
        val errorBody = runCatching { bodyAsText() }.getOrDefault("")
        // Try to extract message if it's a JSON object, otherwise use status description
        val msg = if (errorBody.contains("\"message\"")) {
            // A simple regex/string extraction is safer here than parsing with kotlinx.serialization if the structure varies
            errorBody.substringAfter("\"message\":\"").substringBefore("\"")
        } else {
            status.description
        }
        throw Exception(msg)
    }
    return body()
}

@Single(binds = [NeuraGenApi::class])
class NeuraGenApiImpl(
    private val client: HttpClient,
    private val json: Json
) : NeuraGenApi {


    override suspend fun getHello(): String = client.get("/").bodyOrThrow()

    // Auth
    override suspend fun register(request: RegisterRequest): AuthResponse =
        client.post("/auth/register") { setBody(request) }.bodyOrThrow()

    override suspend fun login(request: LoginRequest): AuthResponse =
        client.post("/auth/login") { setBody(request) }.bodyOrThrow()

    override suspend fun googleCallback(query: Map<String, String>): AuthResponse =
        client.get("/auth/google/callback") {
            query.forEach { (key, value) -> parameter(key, value) }
        }.bodyOrThrow()

    override suspend fun googleExchangeCode(code: String): AuthResponse =
        client.post("/auth/google/exchange-code") {
            setBody(GoogleExchangeCodeRequest(code))
        }.bodyOrThrow()

    override suspend fun googleTokenLogin(idToken: String, platform: String): AuthResponse =
        client.post("/auth/google/token") {
            setBody(GoogleTokenLoginRequest(idToken, platform))
        }.bodyOrThrow()

    override suspend fun refreshTokens(request: RefreshRequest): AuthResponse =
        client.post("/auth/refresh") { setBody(request) }.bodyOrThrow()

    override suspend fun logout(request: LogoutRequest): MessageResponse =
        client.post("/auth/logout") { setBody(request) }.bodyOrThrow()

    override suspend fun logoutAll(): MessageResponse =
        client.post("/auth/logout-all").bodyOrThrow()

    override suspend fun changePassword(request: ChangePasswordRequest): MessageResponse =
        client.patch("/auth/change-password") { setBody(request) }.bodyOrThrow()

    override suspend fun forgotPassword(request: ForgotPasswordRequest): MessageResponse =
        client.post("/auth/forgot-password") { setBody(request) }.bodyOrThrow()

    override suspend fun resetPassword(request: ResetPasswordRequest): MessageResponse =
        client.post("/auth/reset-password") { setBody(request) }.bodyOrThrow()

    // Users
    override suspend fun updateMe(request: UserUpdateDto): UserDto =
        client.patch("/users/me") { setBody(request) }.body()

    override suspend fun getMe(cursor: String?, take: Int?): UserMeDto =
        client.get("/users/me") {
            parameter("cursor", cursor)
            parameter("take", take)
        }.body()

    override suspend fun topupCredits(request: CreditTopupRequest): CreditTopupResponse =
        client.post("/users/me/credits/topup") { setBody(request) }.body()

    override suspend fun getUser(id: String): UserPublicDto =
        client.get("/users/$id").body()

    override suspend fun deleteMe(): UserDto =
        client.delete("/users/me").body()

    // Posts
    override suspend fun createPost(request: CreatePostRequest): PostDto =
        client.post("/posts") { setBody(request) }.body()

    override suspend fun getPosts(): List<PostDto> =
        client.get("/posts").body()

    override suspend fun getPost(id: String): PostDto =
        client.get("/posts/$id").body()

    override suspend fun updatePost(id: String, request: UpdatePostRequest): PostDto =
        client.patch("/posts/$id") { setBody(request) }.body()

    override suspend fun deletePost(id: String): PostDto =
        client.delete("/posts/$id").body()

    // Comments
    override suspend fun createComment(request: CreateCommentRequest): CommentDto =
        client.post("/posts/${request.postId}/comments") { setBody(request) }.body()

    override suspend fun getComments(postId: String, cursor: String?, take: Int?): CommentsPaginationDto =
        client.get("/posts/$postId/comments") {
            parameter("cursor", cursor)
            parameter("take", take)
        }.body()

    override suspend fun updateComment(id: String, request: CreateCommentRequest): CommentDto =
        client.patch("/comments/$id") { setBody(request) }.body()

    override suspend fun deleteComment(id: String): CommentDto =
        client.delete("/comments/$id").body()

    // Post Likes
    override suspend fun likePost(request: CreatePostLikeRequest): PostLikeDto =
        client.post("/posts/${request.postId}/post-likes") { setBody(request) }.body()

    override suspend fun getPostLikes(postId: String, cursor: String?, take: Int?): PostLikesPaginationDto =
        client.get("/posts/$postId/post-likes") {
            parameter("cursor", cursor)
            parameter("take", take)
        }.body()

    override suspend fun unlikePost(postId: String): PostLikeDto =
        client.delete("/posts/$postId/post-likes").body()

    // Follows
    override suspend fun followUser(request: CreateFollowRequest): FollowDto =
        client.post("/follows") { setBody(request) }.body()

    override suspend fun getFollowers(userId: String, cursor: String?, take: Int?): FollowsPaginationDto =
        client.get("/users/$userId/followers") {
            parameter("cursor", cursor)
            parameter("take", take)
        }.body()

    override suspend fun getFollowings(userId: String, cursor: String?, take: Int?): FollowsPaginationDto =
        client.get("/users/$userId/followings") {
            parameter("cursor", cursor)
            parameter("take", take)
        }.body()

    override suspend fun unfollowUser(userId: String): FollowDto =
        client.delete("/follows/$userId").body()

    // Assets
    override suspend fun getAsset(id: String): AssetDto =
        client.get("/assets/$id").body()

    override suspend fun getDownloadUrl(id: String): DownloadResponse =
        client.get("/assets/download/$id").body()

    override suspend fun uploadAsset(
        fileBytes: ByteArray,
        fileName: String,
        type: String,
        role: String
    ): AssetDto = client.post("/assets/upload") {
        setBody(
            MultiPartFormDataContent(
                formData {
                    // Đính kèm các trường text
                    append("type", type)
                    append("role", role)

                    // Đính kèm File (Tên key là "file" cực kỳ quan trọng)
                    append("file", fileBytes, Headers.build {
                        // Ktor cần Content-Disposition để biết tên file
                        append(HttpHeaders.ContentDisposition, "filename=\"$fileName\"")
                        // Bạn có thể set thêm Content-Type của file ở đây nếu cần (vd: image/jpeg)
                        append(HttpHeaders.ContentType, "image/*")
                    })
                }
            )
        )
    }.body()

    // Gallery
    override suspend fun createGalleryItem(request: CreateGalleryItemRequest): GalleryItemDto =
        client.post("/gallery") { setBody(request) }.body()

    override suspend fun getGallery(): List<GalleryItemDto> =
        client.get("/gallery").body()

    override suspend fun updateGalleryItem(id: String, request: UpdateGalleryItemRequest): GalleryItemDto =
        client.patch("/gallery/$id") { setBody(request) }.body()

    override suspend fun deleteGalleryItem(id: String): GalleryItemDto =
        client.delete("/gallery/$id").body()

    // Explore
    override suspend fun getExplore(
        topic: String?,
        trending: Boolean?,
        mode: String?,
        sort: String?,
        limit: Int?,
        cursor: String?
    ): ExploreResponse = client.get("/explore") {
        header(HttpHeaders.CacheControl, "no-cache")
        parameter("topic", topic)
        parameter("trending", trending)
        parameter("mode", mode)
        parameter("sort", sort)
        parameter("limit", limit)
        parameter("cursor", cursor)
    }.body()

    override suspend fun searchExplore(
        topic: String,
        trending: Boolean?,
        sort: String?,
        limit: Int?,
        cursor: String?
    ): ExploreResponse = client.get("/explore/search") {
        header(HttpHeaders.CacheControl, "no-cache")
        parameter("topic", topic)
        parameter("trending", trending)
        parameter("sort", sort)
        parameter("limit", limit)
        parameter("cursor", cursor)
    }.body()

    override suspend fun getForYou(
        topic: String?,
        trending: Boolean?,
        mode: String?,
        sort: String?,
        limit: Int?,
        cursor: String?
    ): ForYouResponse = client.get("/explore/for-you") {
        header(HttpHeaders.CacheControl, "no-cache")
        parameter("topic", topic)
        parameter("trending", trending)
        parameter("mode", mode)
        parameter("sort", sort)
        parameter("limit", limit)
        parameter("cursor", cursor)
    }.body()

    override suspend fun recordExploreEvent(request: ExploreEventRequest): ExploreEventResponse =
        client.post("/explore/events") { setBody(request) }.body()

    override suspend fun recordExploreEventsBatch(request: BatchExploreEventRequest): BatchExploreEventResponse =
        client.post("/explore/events/batch") { setBody(request) }.body()

    // Jobs
    override suspend fun createVideoJob(request: VideoJobRequest): JobResponse =
        client.post("/jobs/video") { setBody(request) }.body()

    override suspend fun getJobs(): List<JobDto> =
        client.get("/jobs").body()

    override suspend fun getJob(id: String): JobDto =
        client.get("/jobs/$id").body()

    override suspend fun getJobResult(id: String): JobResultResponse =
        client.get("/jobs/$id/result").body()

    override suspend fun cancelJob(id: String): CancelJobResponse =
        client.post("/jobs/$id/cancel").body()

    override fun streamJobEvents(jobId: String): Flow<JobStreamEvent> = flow {
        client.sse(
            urlString = "/jobs/$jobId/events",
            request = {
                header(HttpHeaders.Accept, "text/event-stream")
                header(HttpHeaders.CacheControl, "no-cache")
            }
        ) {
            incoming.collect { event ->
                val data = event.data ?: return@collect
                val jobEvent = try {
                    when (event.event) {
                        "snapshot" -> Snapshot(json.decodeFromString<JobSnapshotEvent>(data))
                        "status" -> Status(json.decodeFromString<JobStatusEvent>(data))
                        "log" -> Log(json.decodeFromString<JobLogEvent>(data))
                        "heartbeat" -> Heartbeat(json.decodeFromString<JobHeartbeatEvent>(data))
                        else -> null
                    }
                } catch (e: Exception) {
                    println("NeuraGenApiImpl: Failed to parse SSE event: ${event.event}. Error: ${e.message}")
                    null
                }
                if (jobEvent != null) emit(jobEvent)
            }
        }
    }

    override fun streamNotifications(): Flow<JobNotificationPayload> = flow {
        client.sse("/jobs/events/me") {
            incoming.collect { event ->
                if (event.event == "notification") {
                    val data = event.data ?: return@collect
                    try {
                        val payload = json.decodeFromString<JobNotificationPayload>(data)
                        emit(payload)
                    } catch (e: Exception) {
                        // Ignore parse errors
                    }
                }
            }
        }
    }

    // Billing
    override suspend fun getBillingCatalog(): BillingCatalogResponse =
        client.get("/billing/catalog").body()

    override suspend fun createOrder(request: CreateOrderRequest): OrderResponse =
        client.post("/billing/orders") { setBody(request) }.body()

    override suspend fun getMyOrders(): List<OrderResponse> =
        client.get("/billing/orders/me").body()

    override suspend fun markOrderPaid(id: String, request: MarkPaidRequest): MarkPaidResponse =
        client.post("/billing/orders/$id/mark-paid") { setBody(request) }.body()

    override suspend fun confirmPayosWebhook(request: PayosConfirmRequest): PayosConfirmResponse =
        client.post("/billing/webhooks/payos/confirm") { setBody(request) }.body()

    // Modal
    override suspend fun modalGenerateVideo(request: ModalGenerateVideoRequest): JsonObject =
        client.post("/modal/generate-video") { setBody(request) }.body()
}
