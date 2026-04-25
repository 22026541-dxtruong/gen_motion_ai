package ie.app.neuragen.ui.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.FollowDto
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.network.model.UserMeDto
import ie.app.neuragen.data.network.model.UserUpdateDto
import ie.app.neuragen.data.repository.PostRepository
import ie.app.neuragen.data.repository.UserRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

data class ProfileUiState(
    val user: UserMeDto? = null,
    val posts: List<PostDto> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val selectedTab: Int = 0, // 0 for Public Gallery, 1 for Private Workspace
    val isEditProfileOpen: Boolean = false,
    val isFollowersOpen: Boolean = false,
    val editUsername: String = "",
    val editBio: String = "",
    val followers: List<FollowDto> = emptyList(),
    val isUpdating: Boolean = false
)

@KoinViewModel
class ProfileViewModel(
    @Provided private val userRepository: UserRepository,
    @Provided private val postRepository: PostRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init {
        println("ProfileViewModel: Initializing...")
        loadProfile()
    }

    fun onTabSelected(index: Int) {
        _uiState.update { it.copy(selectedTab = index) }
    }

    fun onEditProfileClick() {
        val user = _uiState.value.user
        println("ProfileViewModel: Opening Edit Profile Dialog")
        _uiState.update { 
            it.copy(
                isEditProfileOpen = true,
                editUsername = user?.username ?: "Alex Rivera",
                editBio = user?.bio ?: "Pushing the boundaries..."
            )
        }
    }

    fun onFollowersClick() {
        val user = _uiState.value.user
        println("ProfileViewModel: Opening Followers Dialog")
        _uiState.update { it.copy(isFollowersOpen = true) }
        user?.id?.let { loadFollowers(it) }
    }

    fun onCloseDialogs() {
        println("ProfileViewModel: Closing Dialogs")
        _uiState.update { it.copy(isEditProfileOpen = false, isFollowersOpen = false) }
    }

    fun onEditUsernameChange(name: String) {
        _uiState.update { it.copy(editUsername = name) }
    }

    fun onEditBioChange(bio: String) {
        _uiState.update { it.copy(editBio = bio) }
    }

    fun loadProfile() {
        viewModelScope.launch {
            println("ProfileViewModel: Loading profile...")
            _uiState.update { it.copy(isLoading = true, error = null) }
            
            val userResult = userRepository.getMe()
            val postsResult = postRepository.getPosts()

            if (userResult.isSuccess && postsResult.isSuccess) {
                val user = userResult.getOrThrow()
                val posts = postsResult.getOrThrow()
                println("ProfileViewModel: Successfully loaded profile for ${user.username}")
                _uiState.update { 
                    it.copy(
                        user = user,
                        posts = posts,
                        isLoading = false
                    )
                }
            } else {
                println("ProfileViewModel: ERROR: Failed to load profile")
                _uiState.update { it.copy(isLoading = false, error = "Failed to load profile") }
            }
        }
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

    fun onSaveProfile() {
        viewModelScope.launch {
            val currentState = _uiState.value
            println("ProfileViewModel: Saving profile changes for ${currentState.editUsername}...")
            _uiState.update { it.copy(isUpdating = true) }
            
            val update = UserUpdateDto(
                username = currentState.editUsername,
                bio = currentState.editBio
            )
            
            val result = userRepository.updateMe(update)
            result.onSuccess {
                println("ProfileViewModel: Profile updated successfully")
                _uiState.update { it.copy(isUpdating = false, isEditProfileOpen = false) }
                loadProfile() // Refresh profile
            }.onFailure { error ->
                println("ProfileViewModel: Failed to update profile: ${error.message}")
                _uiState.update { it.copy(isUpdating = false) }
            }
        }
    }

    fun onToggleFollow(followerId: String) {
        println("ProfileViewModel: Toggling follow status for $followerId")
        // Logic for toggle follow/unfollow in the list
    }
}

