package ie.app.neuragen.ui.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.AuthResponse
import ie.app.neuragen.data.network.model.LoginRequest
import ie.app.neuragen.data.network.model.RegisterRequest
import ie.app.neuragen.data.repository.AuthRepository
import ie.app.neuragen.data.repository.SessionRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

sealed interface AuthUiState {
    data object Idle : AuthUiState
    data object Loading : AuthUiState
    data class Success(val response: AuthResponse) : AuthUiState
    data class Error(val message: String) : AuthUiState
}

@KoinViewModel
class AuthViewModel(
    @Provided
    private val authRepository: AuthRepository,
    @Provided
    private val sessionRepository: SessionRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<AuthUiState>(AuthUiState.Idle)
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            println("Auth: Attempting login for $email")
            val result = authRepository.login(LoginRequest(email, password))
            result.onSuccess { response ->
                println("Auth: Login successful for ${response.email}")
                sessionRepository.saveSession(response)
                _uiState.value = AuthUiState.Success(response)
            }.onFailure { error ->
                println("Auth: Login failed: ${error.message}")
                _uiState.value = AuthUiState.Error(error.message ?: "Login failed")
            }
        }
    }

    fun register(email: String, password: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            println("Auth: Attempting registration for $email")
            val result = authRepository.register(RegisterRequest(email, password))
            result.onSuccess { response ->
                println("Auth: Registration successful for ${response.email}")
                sessionRepository.saveSession(response)
                _uiState.value = AuthUiState.Success(response)
            }.onFailure { error ->
                println("Auth: Registration failed: ${error.message}")
                _uiState.value = AuthUiState.Error(error.message ?: "Registration failed")
            }
        }
    }

    fun signInWithGoogle() {
        println("Auth: Sign in with Google requested")
        // Implementation for Google Sign In would go here
    }

    fun resetState() {
        _uiState.value = AuthUiState.Idle
    }
}
