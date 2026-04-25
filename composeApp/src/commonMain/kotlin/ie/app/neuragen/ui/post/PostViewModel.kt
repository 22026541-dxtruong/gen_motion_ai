package ie.app.neuragen.ui.post

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.CommentDto
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.repository.PostRepository
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
    val isLoading: Boolean = false,
    val isLiking: Boolean = false,
    val isCommenting: Boolean = false,
    val error: String? = null
)

@KoinViewModel
class PostViewModel(
    @Provided private val postRepository: PostRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(PostUiState())
    val uiState: StateFlow<PostUiState> = _uiState.asStateFlow()

    fun loadPost(postId: String) {
        viewModelScope.launch {
            println("PostViewModel: Loading post $postId...")
            _uiState.update { it.copy(isLoading = true, error = null) }
            
            val postResult = postRepository.getPost(postId)
            val commentsResult = postRepository.getComments(postId)

            if (postResult.isSuccess) {
                val post = postResult.getOrThrow()
                val comments = commentsResult.getOrNull()?.data ?: emptyList()
                println("PostViewModel: Successfully loaded post and ${comments.size} comments")
                _uiState.update { 
                    it.copy(
                        post = post,
                        comments = comments,
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
        viewModelScope.launch {
            println("PostViewModel: Toggling like for post ${post.id}...")
            _uiState.update { it.copy(isLiking = true) }
            // Logic for like/unlike would go here, currently using placeholder
            val result = postRepository.likePost(post.id)
            result.onSuccess {
                println("PostViewModel: Successfully toggled like")
                _uiState.update { it.copy(isLiking = false) }
                loadPost(post.id) // Refresh post data
            }.onFailure { error ->
                println("PostViewModel: Failed to toggle like: ${error.message}")
                _uiState.update { it.copy(isLiking = false) }
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
            result.onSuccess {
                println("PostViewModel: Successfully added comment")
                _uiState.update { it.copy(isCommenting = false) }
                loadPost(post.id) // Refresh comments
            }.onFailure { error ->
                println("PostViewModel: Failed to add comment: ${error.message}")
                _uiState.update { it.copy(isCommenting = false) }
            }
        }
    }
}
