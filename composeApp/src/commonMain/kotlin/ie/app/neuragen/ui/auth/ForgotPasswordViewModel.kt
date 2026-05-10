package ie.app.neuragen.ui.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.repository.AuthRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

sealed interface ForgotPasswordUiState {
    data object Idle : ForgotPasswordUiState
    data object Loading : ForgotPasswordUiState
    data object Success : ForgotPasswordUiState
    data class Error(val message: String) : ForgotPasswordUiState
}

@KoinViewModel
class ForgotPasswordViewModel(
    @Provided private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<ForgotPasswordUiState>(ForgotPasswordUiState.Idle)
    val uiState: StateFlow<ForgotPasswordUiState> = _uiState.asStateFlow()

    fun forgotPassword(email: String) {
        if (email.isBlank()) {
            _uiState.value = ForgotPasswordUiState.Error("Email cannot be empty")
            return
        }
        
        viewModelScope.launch {
            _uiState.value = ForgotPasswordUiState.Loading
            println("ForgotPassword: Attempting to send reset link to $email")
            
            val result = authRepository.forgotPassword(email)
            result.onSuccess {
                println("ForgotPassword: Link sent successfully")
                _uiState.value = ForgotPasswordUiState.Success
            }.onFailure { error ->
                println("ForgotPassword: Failed to send link: ${error.message}")
                _uiState.value = ForgotPasswordUiState.Error(error.message ?: "Failed to send reset link")
            }
        }
    }

    fun resetState() {
        _uiState.value = ForgotPasswordUiState.Idle
    }
}
