package ie.app.neuragen.ui.navigation

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.AuthResponse
import ie.app.neuragen.data.network.model.LoginRequest
import ie.app.neuragen.data.network.model.JobNotificationPayload
import ie.app.neuragen.data.network.model.UserMeDto
import ie.app.neuragen.data.repository.AuthRepository
import ie.app.neuragen.data.repository.SessionRepository
import ie.app.neuragen.data.repository.UserRepository
import ie.app.neuragen.util.AppLifecycleObserver
import ie.app.neuragen.util.UserSessionState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

sealed interface SessionStatus {
    data object Loading : SessionStatus
    data class Authenticated(val response: AuthResponse) : SessionStatus
    data object Anonymous : SessionStatus
}

@KoinViewModel
class NavigationViewModel(
    @Provided private val sessionRepository: SessionRepository,
    @Provided private val authRepository: AuthRepository,
    @Provided private val userRepository: UserRepository
) : ViewModel() {

    val sessionStatus: StateFlow<SessionStatus> = sessionRepository.getSession()
        .map { if (it == null) SessionStatus.Anonymous else SessionStatus.Authenticated(it) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), SessionStatus.Loading)

    val session: StateFlow<AuthResponse?> = sessionRepository.getSession()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    var showLogoutConfirm by mutableStateOf(false)
    var showChangePassword by mutableStateOf(false)
    var showSwitchAccount by mutableStateOf(false)

    var changePasswordError by mutableStateOf<String?>(null)
    var isChangingPassword by mutableStateOf(false)

    var switchAccountError by mutableStateOf<String?>(null)
    var isSwitchingAccount by mutableStateOf(false)

    val userProfile: StateFlow<UserMeDto?> = UserSessionState.user
    val notifications = MutableStateFlow<List<JobNotificationPayload>>(emptyList())

    init {
        // Observe cached profile for instant display
        viewModelScope.launch {
            userRepository.observeProfile().collect { cachedProfile ->
                if (cachedProfile != null && UserSessionState.user.value == null) {
                    UserSessionState.update(cachedProfile)
                }
            }
        }

        viewModelScope.launch {
            sessionStatus.collect { status ->
                if (status is SessionStatus.Authenticated) {
                    fetchMyProfile()
                    startNotificationStream()
                } else {
                    UserSessionState.clear()
                    notifications.value = emptyList()
                }
            }
        }

        // Auto-refresh profile (credits, subscription status) when app returns to foreground
        viewModelScope.launch {
            AppLifecycleObserver.resumeCount.collect { count ->
                if (count > 0 && sessionStatus.value is SessionStatus.Authenticated) {
                    fetchMyProfile()
                }
            }
        }
    }

    private fun fetchMyProfile() {
        viewModelScope.launch {
            val result = userRepository.refreshAndCacheProfile()
            if (result.isSuccess) {
                UserSessionState.update(result.getOrNull())
            }
        }
    }

    /**
     * Public refresh — called after payment confirmation or profile edit
     * to immediately update credit balance in Topbar.
     */
    fun refreshProfile() {
        fetchMyProfile()
    }

    private fun startNotificationStream() {
        viewModelScope.launch {
            while (true) {
                try {
                    userRepository.streamNotifications().collect { payload ->
                        val current = notifications.value.toMutableList()
                        // Generate local id from jobId + occurredAt
                        val fallbackId = "${payload.jobId}-${payload.kind}"
                        val p = if (payload.id.isEmpty()) payload.copy(id = payload.occurredAt?.let { "${payload.jobId}-$it" } ?: fallbackId) else payload
                        if (!current.any { it.jobId == p.jobId && it.kind == p.kind }) {
                            current.add(0, p)
                            notifications.value = current.take(50)
                        }
                    }
                } catch (e: Exception) {
                    // Log error and retry
                    println("Notification SSE Error: ${e.message}. Reconnecting in 3s...")
                }
                kotlinx.coroutines.delay(3000)
            }
        }
    }

    fun markAllNotificationsAsRead() {
        notifications.value = notifications.value.map { it.copy(read = true) }
    }

    fun removeNotification(id: String) {
        notifications.value = notifications.value.filter { it.id != id }
    }

    fun markNotificationAsRead(id: String) {
        notifications.value = notifications.value.map { if (it.id == id) it.copy(read = true) else it }
    }

    fun clearNotifications() {
        notifications.value = emptyList()
    }

    fun logout() {
        viewModelScope.launch {
            session.value?.refreshToken?.let {
                authRepository.logout(it)
            } ?: sessionRepository.clearSession()
            showLogoutConfirm = false
        }
    }

    fun changePassword(old: String, new: String) {
        viewModelScope.launch {
            isChangingPassword = true
            changePasswordError = null
            val result = authRepository.changePassword(old, new)
            if (result.isSuccess) {
                showChangePassword = false
            } else {
                changePasswordError = result.exceptionOrNull()?.message ?: "Failed to change password"
            }
            isChangingPassword = false
        }
    }

    fun switchAccount(email: String, password: String) {
        viewModelScope.launch {
            isSwitchingAccount = true
            switchAccountError = null
            val result = authRepository.login(LoginRequest(email, password))
            if (result.isSuccess) {
                // Logout old session then save new
                session.value?.refreshToken?.let { authRepository.logout(it) }
                sessionRepository.saveSession(result.getOrThrow())
                showSwitchAccount = false
            } else {
                switchAccountError = result.exceptionOrNull()?.message ?: "Login failed"
            }
            isSwitchingAccount = false
        }
    }
}
