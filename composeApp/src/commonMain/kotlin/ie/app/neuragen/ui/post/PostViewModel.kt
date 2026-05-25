package ie.app.neuragen.ui.post

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.CommentDto
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.repository.PostRepository
import ie.app.neuragen.data.repository.UserRepository
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

data class PostUiState(
    val post: PostDto? = null,
    val comments: List<CommentDto> = emptyList(),
    val currentUser: ie.app.neuragen.data.network.model.UserPublicDto? = null,
    val isLoading: Boolean = false,
    val isLiking: Boolean = false,
    val isLiked: Boolean = false,              // Trạng thái like hiện tại (persist qua API)
    val isCommenting: Boolean = false,
    val isFollowing: Boolean = false,          // Trạng thái follow tác giả
    val isTogglingFollow: Boolean = false,
    val error: String? = null
)

@KoinViewModel
class PostViewModel(
    @Provided private val postRepository: PostRepository,
    @Provided private val userRepository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(PostUiState())
    val uiState: StateFlow<PostUiState> = _uiState.asStateFlow()

    fun loadPost(postId: String) {
        viewModelScope.launch {
            println("PostViewModel: Loading post $postId...")
            _uiState.update { it.copy(isLoading = true, error = null) }

            // Load post, comments, likes và user info song song
            val postDeferred = async { postRepository.getPost(postId) }
            val commentsDeferred = async { postRepository.getComments(postId) }
            val meDeferred = async { userRepository.getMe() }
            val likesDeferred = async { postRepository.getPostLikes(postId, take = 50) }

            val postResult = postDeferred.await()
            val commentsResult = commentsDeferred.await()
            val meResult = meDeferred.await()
            val likesResult = likesDeferred.await()

            if (postResult.isSuccess) {
                val post = postResult.getOrThrow()
                val comments = commentsResult.getOrNull()?.data ?: emptyList()

                // Check liked status: so sánh userId hiện tại với danh sách likes
                val myUserId = meResult.getOrNull()?.id
                val likes = likesResult.getOrNull()?.data ?: emptyList()
                val isLiked = myUserId != null && likes.any { it.user?.id == myUserId }

                // Check following status: so sánh userId hiện tại với danh sách followers của tác giả
                val followersResult = postRepository.getFollowers(post.userId, take = 50)
                val followers = followersResult.getOrNull()?.data ?: emptyList()
                val isFollowing = myUserId != null && followers.any { it.follower?.id == myUserId }

                val currentUserPublic = meResult.getOrNull()?.let {
                    ie.app.neuragen.data.network.model.UserPublicDto(
                        id = it.id,
                        username = it.username,
                        avatarUrl = it.avatarUrl,
                        bio = it.bio
                    )
                }

                println("PostViewModel: Loaded post, ${comments.size} comments, isLiked=$isLiked, isFollowing=$isFollowing")

                _uiState.update {
                    it.copy(
                        post = post,
                        comments = comments,
                        currentUser = currentUserPublic,
                        isLiked = isLiked,
                        isFollowing = isFollowing,
                        isLoading = false
                    )
                }
            } else {
                val errorMsg = "Failed to load post. Error: ${postResult.exceptionOrNull()?.message}"
                println("PostViewModel: ERROR: $errorMsg")
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        error = "Failed to load post"
                    )
                }
            }
        }
    }

    fun toggleLike() {
        val post = _uiState.value.post ?: return
        val isCurrentlyLiked = _uiState.value.isLiked
        val currentLikeCount = post.likeCount

        viewModelScope.launch {
            println("PostViewModel: Toggling like for post ${post.id} (currently liked=$isCurrentlyLiked)...")

            // Optimistic update
            _uiState.update {
                it.copy(
                    isLiking = true,
                    isLiked = !isCurrentlyLiked,
                    post = post.copy(
                        likeCount = if (isCurrentlyLiked) (currentLikeCount - 1).coerceAtLeast(0)
                        else currentLikeCount + 1
                    )
                )
            }

            val result = if (isCurrentlyLiked) {
                postRepository.unlikePost(post.id)
            } else {
                postRepository.likePost(post.id)
            }

            result.onSuccess {
                println("PostViewModel: Successfully toggled like!")
                _uiState.update { it.copy(isLiking = false) }
            }.onFailure { error ->
                println("PostViewModel: Failed to toggle like: ${error.message}")
                // Revert optimistic update
                _uiState.update {
                    it.copy(
                        isLiking = false,
                        isLiked = isCurrentlyLiked,
                        post = post.copy(likeCount = currentLikeCount)
                    )
                }
            }
        }
    }

    fun toggleFollow() {
        val post = _uiState.value.post ?: return
        val authorId = post.userId
        val isCurrentlyFollowing = _uiState.value.isFollowing

        viewModelScope.launch {
            println("PostViewModel: Toggling follow for user $authorId (currently following=$isCurrentlyFollowing)...")
            // Optimistic update
            _uiState.update { it.copy(isFollowing = !isCurrentlyFollowing, isTogglingFollow = true) }

            val result = if (isCurrentlyFollowing) {
                postRepository.unfollowUser(authorId)
            } else {
                postRepository.followUser(authorId)
            }

            result.onSuccess {
                println("PostViewModel: Successfully toggled follow!")
                _uiState.update { it.copy(isTogglingFollow = false) }
            }.onFailure { error ->
                println("PostViewModel: Failed to toggle follow: ${error.message}")
                // Revert optimistic update
                _uiState.update { it.copy(isFollowing = isCurrentlyFollowing, isTogglingFollow = false) }
            }
        }
    }

    fun addComment(content: String) {
        val post = _uiState.value.post ?: return
        if (content.isBlank()) return

        viewModelScope.launch {
            println("PostViewModel: Adding comment to post ${post.id}...")
            _uiState.update { it.copy(isCommenting = true) }

            val result = postRepository.createComment(post.id, content)
            result.onSuccess { newComment ->
                println("PostViewModel: Successfully added comment")
                // Optimistic: thêm comment mới vào danh sách ngay lập tức
                val currentUser = _uiState.value.currentUser
                val commentWithUser = if (newComment.user == null && currentUser != null) {
                    newComment.copy(user = currentUser)
                } else {
                    newComment
                }
                val updatedComments = _uiState.value.comments + commentWithUser
                val currentPost = _uiState.value.post
                _uiState.update {
                    it.copy(
                        isCommenting = false,
                        comments = updatedComments,
                        post = currentPost?.copy(commentCount = currentPost.commentCount + 1)
                    )
                }
            }.onFailure { error ->
                println("PostViewModel: Failed to add comment: ${error.message}")
                _uiState.update { it.copy(isCommenting = false) }
            }
        }
    }
}
