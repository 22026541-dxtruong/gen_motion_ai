package ie.app.neuragen.ui.auth

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import ie.app.neuragen.data.repository.AuthRepository
import ie.app.neuragen.data.repository.SessionRepository
import ie.app.neuragen.data.repository.UserRepository
import kotlinx.coroutines.flow.firstOrNull
import org.koin.compose.koinInject

@Composable
fun SplashScreen(
    onAuthenticated: () -> Unit,
    onNotAuthenticated: () -> Unit,
    sessionRepository: SessionRepository = koinInject(),
    userRepository: UserRepository = koinInject(),
    authRepository: AuthRepository = koinInject()
) {
    LaunchedEffect(Unit) {
        val session = sessionRepository.getSession().firstOrNull()
        if (session == null) {
            onNotAuthenticated()
            return@LaunchedEffect
        }

        // Try to verify token by fetching user profile
        val result = userRepository.getMe()
        if (result.isSuccess) {
            onAuthenticated()
        } else {
            // Token might be expired, try to refresh
            val refreshResult = authRepository.refreshTokens(session.refreshToken)
            refreshResult.onSuccess { newSession ->
                sessionRepository.saveSession(newSession)
                onAuthenticated()
            }.onFailure {
                sessionRepository.clearSession()
                onNotAuthenticated()
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator()
    }
}
