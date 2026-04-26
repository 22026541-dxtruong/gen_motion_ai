package ie.app.neuragen.ui.navigation

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.AuthResponse
import ie.app.neuragen.data.network.model.LoginRequest
import ie.app.neuragen.data.repository.AuthRepository
import ie.app.neuragen.data.repository.SessionRepository
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
    @Provided private val authRepository: AuthRepository
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
