package ie.app.neuragen.ui.userprofile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.network.model.UserPublicDto
import ie.app.neuragen.data.repository.PostRepository
import ie.app.neuragen.data.repository.UserRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

data class UserProfileUiState(
    val user: UserPublicDto? = null,
    val posts: List<PostDto> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val selectedTab: Int = 0 // 0 for Videos, 1 for Collections
)

@KoinViewModel
class UserProfileViewModel(
    @Provided private val userRepository: UserRepository,
    @Provided private val postRepository: PostRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(UserProfileUiState())
    val uiState: StateFlow<UserProfileUiState> = _uiState.asStateFlow()

    fun loadProfile(userId: String) {
        viewModelScope.launch {
            println("UserProfileViewModel: Loading profile for $userId...")
            _uiState.update { it.copy(isLoading = true, error = null) }
            
            val userResult = userRepository.getUser(userId)
            val postsResult = postRepository.getPosts() // Ideally filtered by userId, but following current repo structure

            if (userResult.isSuccess && postsResult.isSuccess) {
                val user = userResult.getOrThrow()
                // Filtering posts for this user specifically
                val userPosts = postsResult.getOrThrow().filter { it.userId == userId }
                println("UserProfileViewModel: Successfully loaded profile for ${user.username} and ${userPosts.size} posts")
                _uiState.update { 
                    it.copy(
                        user = user,
                        posts = userPosts,
                        isLoading = false
                    )
                }
            } else {
                val userError = userResult.exceptionOrNull()?.message
                val postsError = postsResult.exceptionOrNull()?.message
                val errorMsg = "Failed to load user profile. User error: $userError, Posts error: $postsError"
                println("UserProfileViewModel: ERROR: $errorMsg")
                _uiState.update { 
                    it.copy(
                        isLoading = false,
                        error = "Failed to load profile"
                    )
                }
            }
        }
    }

    fun onTabSelected(index: Int) {
        _uiState.update { it.copy(selectedTab = index) }
    }
}
