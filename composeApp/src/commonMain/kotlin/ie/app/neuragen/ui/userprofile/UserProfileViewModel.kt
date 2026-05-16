package ie.app.neuragen.ui.userprofile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.network.model.UserPublicDto
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

data class UserProfileUiState(
    val user: UserPublicDto? = null,
    val posts: List<PostDto> = emptyList(),
    val followersCount: Int = 0,
    val followingCount: Int = 0,
    val isLoading: Boolean = false,
    val error: String? = null,
    // selectedTab removed — Collection tab eliminated
    val isFollowing: Boolean = false,
    val isTogglingFollow: Boolean = false
)

@KoinViewModel
class UserProfileViewModel(
    @Provided private val userRepository: UserRepository,
    @Provided private val postRepository: PostRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(UserProfileUiState())
    val uiState: StateFlow<UserProfileUiState> = _uiState.asStateFlow()

    private var currentUserId: String? = null

    fun loadProfile(userId: String) {
        currentUserId = userId
        viewModelScope.launch {
            println("UserProfileViewModel: Loading profile for $userId...")
            _uiState.update { it.copy(isLoading = true, error = null) }

            val userDeferred = async { userRepository.getUser(userId) }
            val postsDeferred = async { postRepository.getPosts() }
            val followersDeferred = async { postRepository.getFollowers(userId, take = 50) }
            val followingDeferred = async { postRepository.getFollowings(userId, take = 50) }
            val meDeferred = async { userRepository.getMe() }

            val userResult = userDeferred.await()
            val postsResult = postsDeferred.await()
            val followersResult = followersDeferred.await()
            val followingResult = followingDeferred.await()
            val meResult = meDeferred.await()

            if (userResult.isSuccess && postsResult.isSuccess) {
                val user = userResult.getOrThrow()
                // Filter posts for this user specifically
                val userPosts = postsResult.getOrThrow().filter { it.userId == userId }
                val followers = followersResult.getOrNull()?.data ?: emptyList()
                val following = followingResult.getOrNull()?.data ?: emptyList()
                val myUserId = meResult.getOrNull()?.id

                val isFollowing = myUserId != null && followers.any { it.follower?.id == myUserId }

                println("UserProfileViewModel: Successfully loaded profile for ${user.username} and ${userPosts.size} posts")
                _uiState.update {
                    it.copy(
                        user = user,
                        posts = userPosts,
                        followersCount = followers.size,
                        followingCount = following.size,
                        isFollowing = isFollowing,
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

    // onTabSelected removed — Collection tab eliminated

    fun toggleFollow() {
        val userId = currentUserId ?: return
        val isCurrentlyFollowing = _uiState.value.isFollowing
        val currentFollowerCount = _uiState.value.followersCount

        viewModelScope.launch {
            println("UserProfileViewModel: Toggling follow for $userId (currently following=$isCurrentlyFollowing)...")
            // Optimistic update
            _uiState.update { 
                it.copy(
                    isFollowing = !isCurrentlyFollowing, 
                    isTogglingFollow = true,
                    followersCount = if (isCurrentlyFollowing) (currentFollowerCount - 1).coerceAtLeast(0) else currentFollowerCount + 1
                ) 
            }

            val result = if (isCurrentlyFollowing) {
                postRepository.unfollowUser(userId)
            } else {
                postRepository.followUser(userId)
            }

            result.onSuccess {
                println("UserProfileViewModel: Successfully toggled follow!")
                _uiState.update { it.copy(isTogglingFollow = false) }
            }.onFailure { error ->
                println("UserProfileViewModel: Failed to toggle follow: ${error.message}")
                // Revert optimistic update on failure
                _uiState.update { 
                    it.copy(
                        isFollowing = isCurrentlyFollowing, 
                        isTogglingFollow = false,
                        followersCount = currentFollowerCount
                    ) 
                }
            }
        }
    }
}
