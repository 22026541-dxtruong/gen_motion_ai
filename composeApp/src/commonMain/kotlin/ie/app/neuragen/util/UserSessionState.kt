package ie.app.neuragen.util

import ie.app.neuragen.data.network.model.UserMeDto
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Centralized, reactive user session state.
 *
 * All ViewModels that display user data (Topbar, ProfileScreen, BillingScreen, etc.)
 * observe [user] instead of fetching their own copy.
 *
 * After any mutation (avatar upload, profile edit, payment confirmed, etc.),
 * call [update] to broadcast the change app-wide in real-time.
 */
object UserSessionState {

    private val _user = MutableStateFlow<UserMeDto?>(null)
    val user: StateFlow<UserMeDto?> = _user.asStateFlow()

    /** Replace current user data (e.g., after /users/me fetch). */
    fun update(user: UserMeDto?) {
        _user.value = user
    }

    /** Patch current user in-place (e.g., after avatar or credit change). */
    fun patch(transform: (UserMeDto) -> UserMeDto) {
        _user.value?.let { _user.value = transform(it) }
    }

    /** Clear on logout. */
    fun clear() {
        _user.value = null
    }
}
