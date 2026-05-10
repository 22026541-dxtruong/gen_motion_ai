package ie.app.neuragen.ui.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.FollowDto
import ie.app.neuragen.data.network.model.JobDto
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.network.model.UpdatePostRequest
import ie.app.neuragen.data.network.model.UserMeDto
import ie.app.neuragen.data.network.model.UserUpdateDto
import ie.app.neuragen.data.repository.AssetRepository
import ie.app.neuragen.data.repository.JobRepository
import ie.app.neuragen.data.repository.PostRepository
import ie.app.neuragen.data.repository.UserRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

/**
 * Represents a unified gallery item for both published posts (public) and completed jobs (private).
 * Mirrors the web's combined gallery display.
 */
data class GalleryItem(
    val id: String,
    val title: String,
    val isPublic: Boolean,
    val isJob: Boolean,
    val mediaUrl: String?,
    val thumbnailUrl: String?,
    val durationMs: Int,
    val viewCount: Int,
    val likeCount: Int,
    // Original references for operations
    val post: PostDto? = null,
    val job: JobDto? = null,
    val assetId: String? = null
)

data class ProfileUiState(
    val user: UserMeDto? = null,
    val publicGallery: List<GalleryItem> = emptyList(),
    val privateGallery: List<GalleryItem> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val selectedTab: Int = 0, // 0 = Public Gallery, 1 = Private Workspace

    // Edit Profile Dialog
    val isEditProfileOpen: Boolean = false,
    val editUsername: String = "",
    val editBio: String = "",
    val isUpdating: Boolean = false,
    val isUploadingAvatar: Boolean = false,
    val avatarPreview: String? = null,

    // Followers/Followings Dialog
    val isFollowersOpen: Boolean = false,
    val isFollowingsOpen: Boolean = false,
    val followers: List<FollowDto> = emptyList(),
    val followings: List<FollowDto> = emptyList(),

    // Edit Post Dialog
    val editingPost: GalleryItem? = null,
    val editPostCaption: String = "",
    val isSavingPostEdit: Boolean = false,

    // Publish Dialog
    val publishingItem: GalleryItem? = null,
    val publishCaption: String = "",
    val isPublishing: Boolean = false,

    // Delete
    val isDeletingPostId: String? = null
)

@KoinViewModel
class ProfileViewModel(
    @Provided private val userRepository: UserRepository,
    @Provided private val postRepository: PostRepository,
    @Provided private val jobRepository: JobRepository,
    @Provided private val assetRepository: AssetRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init {
        println("ProfileViewModel: Initializing...")
        loadProfile()
    }

    // ──────────────────────────────────────────────────────────────
    // Data Loading
    // ──────────────────────────────────────────────────────────────

    fun loadProfile() {
        viewModelScope.launch {
            println("ProfileViewModel: Loading profile...")
            _uiState.update { it.copy(isLoading = true, error = null) }

            val userResult = userRepository.getMe()

            if (userResult.isFailure) {
                println("ProfileViewModel: ERROR: Failed to load profile: ${userResult.exceptionOrNull()?.message}")
                _uiState.update { it.copy(isLoading = false, error = "Failed to load profile") }
                return@launch
            }

            val user = userResult.getOrThrow()
            println("ProfileViewModel: Successfully loaded profile for ${user.username}")

            // Load posts (filtered by current user for public gallery — mirrors web)
            val postsResult = postRepository.getPosts()
            val allPosts = postsResult.getOrDefault(emptyList())
            val userPosts = allPosts.filter { it.userId == user.id }

            val publicGallery = userPosts.filter { it.isPublic }.map { post ->
                val mediaUrl = post.videoUrl ?: post.thumbnailUrl ?: post.assetVersion?.fileUrl
                val durationMs = post.assetVersion?.durationMs ?: 0
                GalleryItem(
                    id = post.id,
                    title = post.caption ?: "Untitled Video",
                    isPublic = true,
                    isJob = false,
                    mediaUrl = mediaUrl,
                    thumbnailUrl = post.thumbnailUrl ?: post.assetVersion?.fileUrl,
                    durationMs = durationMs,
                    viewCount = post.viewCount,
                    likeCount = post.likeCount,
                    post = post
                )
            }

            // Load jobs (for private workspace — mirrors web's "Private Workspace" tab)
            val jobsResult = jobRepository.getJobs()
            val allJobs = jobsResult.getOrDefault(emptyList())
            val completedJobs = allJobs.filter { it.status == "COMPLETED" }

            val privateGallery = completedJobs.map { job ->
                val mediaUrl = job.output?.downloadUrl ?: job.thumbnail?.downloadUrl
                val durationMs = if (job.estimatedDurationSeconds != null) job.estimatedDurationSeconds * 1000 else 0
                GalleryItem(
                    id = job.id,
                    title = job.prompt,
                    isPublic = false,
                    isJob = true,
                    mediaUrl = mediaUrl,
                    thumbnailUrl = job.thumbnail?.downloadUrl ?: mediaUrl,
                    durationMs = durationMs,
                    viewCount = 0,
                    likeCount = 0,
                    job = job,
                    assetId = job.output?.assetId
                )
            }

            println("ProfileViewModel: Loaded ${publicGallery.size} public posts, ${privateGallery.size} private jobs")

            _uiState.update {
                it.copy(
                    user = user,
                    publicGallery = publicGallery,
                    privateGallery = privateGallery,
                    isLoading = false
                )
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Tab
    // ──────────────────────────────────────────────────────────────

    fun onTabSelected(index: Int) {
        _uiState.update { it.copy(selectedTab = index) }
    }

    // ──────────────────────────────────────────────────────────────
    // Edit Profile
    // ──────────────────────────────────────────────────────────────

    fun onEditProfileClick() {
        val user = _uiState.value.user
        _uiState.update {
            it.copy(
                isEditProfileOpen = true,
                editUsername = user?.username ?: "",
                editBio = user?.bio ?: "",
                avatarPreview = user?.avatarUrl
            )
        }
    }

    fun onEditUsernameChange(name: String) {
        _uiState.update { it.copy(editUsername = name) }
    }

    fun onEditBioChange(bio: String) {
        _uiState.update { it.copy(editBio = bio) }
    }

    fun onSaveProfile() {
        viewModelScope.launch {
            val currentState = _uiState.value
            println("ProfileViewModel: Saving profile changes for ${currentState.editUsername}...")
            _uiState.update { it.copy(isUpdating = true) }

            val update = UserUpdateDto(
                username = currentState.editUsername,
                bio = currentState.editBio,
                avatarUrl = currentState.avatarPreview
            )

            val result = userRepository.updateMe(update)
            result.onSuccess {
                println("ProfileViewModel: Profile updated successfully")
                _uiState.update { it.copy(isUpdating = false, isEditProfileOpen = false) }
                loadProfile()
            }.onFailure { error ->
                println("ProfileViewModel: Failed to update profile: ${error.message}")
                _uiState.update { it.copy(isUpdating = false) }
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Avatar Upload
    // ──────────────────────────────────────────────────────────────

    fun onAvatarUpload(fileBytes: ByteArray, fileName: String) {
        viewModelScope.launch {
            println("ProfileViewModel: Uploading avatar $fileName (${fileBytes.size} bytes)...")
            _uiState.update { it.copy(isUploadingAvatar = true) }

            val result = assetRepository.uploadAsset(fileBytes, fileName, type = "IMAGE", role = "INPUT")
            result.onSuccess { asset ->
                val uploadedUrl = asset.versions?.firstOrNull()?.fileUrl
                if (uploadedUrl != null) {
                    println("ProfileViewModel: Avatar uploaded: $uploadedUrl")
                    _uiState.update { it.copy(avatarPreview = uploadedUrl, isUploadingAvatar = false) }
                } else {
                    println("ProfileViewModel: Avatar upload succeeded but no URL returned")
                    _uiState.update { it.copy(isUploadingAvatar = false) }
                }
            }.onFailure { error ->
                println("ProfileViewModel: Avatar upload failed: ${error.message}")
                _uiState.update { it.copy(isUploadingAvatar = false) }
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Followers / Followings Dialogs
    // ──────────────────────────────────────────────────────────────

    fun onFollowersClick() {
        _uiState.update { it.copy(isFollowersOpen = true) }
        _uiState.value.user?.id?.let { loadFollowers(it) }
    }

    fun onFollowingsClick() {
        _uiState.update { it.copy(isFollowingsOpen = true) }
        _uiState.value.user?.id?.let { loadFollowings(it) }
    }

    private fun loadFollowers(userId: String) {
        viewModelScope.launch {
            println("ProfileViewModel: Loading followers for $userId...")
            val result = postRepository.getFollowers(userId)
            result.onSuccess { pagination ->
                println("ProfileViewModel: Loaded ${pagination.data.size} followers")
                _uiState.update { it.copy(followers = pagination.data) }
            }.onFailure { error ->
                println("ProfileViewModel: Failed to load followers: ${error.message}")
            }
        }
    }

    private fun loadFollowings(userId: String) {
        viewModelScope.launch {
            println("ProfileViewModel: Loading followings for $userId...")
            val result = postRepository.getFollowings(userId)
            result.onSuccess { pagination ->
                println("ProfileViewModel: Loaded ${pagination.data.size} followings")
                _uiState.update { it.copy(followings = pagination.data) }
            }.onFailure { error ->
                println("ProfileViewModel: Failed to load followings: ${error.message}")
            }
        }
    }

    fun onToggleFollow(userId: String) {
        println("ProfileViewModel: Toggling follow status for $userId")
        // Placeholder — follow/unfollow toggle
    }

    // ──────────────────────────────────────────────────────────────
    // Post Operations
    // ──────────────────────────────────────────────────────────────

    fun onDeletePost(postId: String) {
        viewModelScope.launch {
            println("ProfileViewModel: Deleting post $postId...")
            _uiState.update { it.copy(isDeletingPostId = postId) }
            val result = postRepository.deletePost(postId)
            result.onSuccess {
                println("ProfileViewModel: Post deleted successfully")
                _uiState.update { state ->
                    state.copy(
                        publicGallery = state.publicGallery.filter { it.id != postId },
                        isDeletingPostId = null
                    )
                }
            }.onFailure { error ->
                println("ProfileViewModel: Failed to delete post: ${error.message}")
                _uiState.update { it.copy(isDeletingPostId = null) }
            }
        }
    }

    fun onEditPostClick(item: GalleryItem) {
        _uiState.update {
            it.copy(
                editingPost = item,
                editPostCaption = item.title
            )
        }
    }

    fun onEditPostCaptionChange(caption: String) {
        _uiState.update { it.copy(editPostCaption = caption) }
    }

    fun onSavePostEdit() {
        val editingPost = _uiState.value.editingPost ?: return
        viewModelScope.launch {
            println("ProfileViewModel: Saving post edit for ${editingPost.id}...")
            _uiState.update { it.copy(isSavingPostEdit = true) }
            val result = postRepository.updatePost(
                editingPost.id,
                UpdatePostRequest(caption = _uiState.value.editPostCaption)
            )
            result.onSuccess {
                println("ProfileViewModel: Post updated successfully")
                _uiState.update { it.copy(isSavingPostEdit = false, editingPost = null) }
                loadProfile()
            }.onFailure { error ->
                println("ProfileViewModel: Failed to update post: ${error.message}")
                _uiState.update { it.copy(isSavingPostEdit = false) }
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Publish Job as Post
    // ──────────────────────────────────────────────────────────────

    fun onPublishClick(item: GalleryItem) {
        _uiState.update {
            it.copy(
                publishingItem = item,
                publishCaption = item.title
            )
        }
    }

    fun onPublishCaptionChange(caption: String) {
        _uiState.update { it.copy(publishCaption = caption) }
    }

    fun onConfirmPublish() {
        val item = _uiState.value.publishingItem ?: return
        viewModelScope.launch {
            println("ProfileViewModel: Publishing job ${item.id} as post...")
            _uiState.update { it.copy(isPublishing = true) }

            val result = postRepository.publishPost(
                jobId = if (item.isJob) item.id else null,
                assetId = item.assetId,
                caption = _uiState.value.publishCaption
            )

            result.onSuccess {
                println("ProfileViewModel: Published successfully")
                _uiState.update { it.copy(isPublishing = false, publishingItem = null) }
                loadProfile()
            }.onFailure { error ->
                println("ProfileViewModel: Failed to publish: ${error.message}")
                _uiState.update { it.copy(isPublishing = false) }
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Close Dialogs
    // ──────────────────────────────────────────────────────────────

    fun onCloseDialogs() {
        _uiState.update {
            it.copy(
                isEditProfileOpen = false,
                isFollowersOpen = false,
                isFollowingsOpen = false,
                editingPost = null,
                publishingItem = null
            )
        }
    }
}
