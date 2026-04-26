package ie.app.neuragen.ui.auth

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ie.app.neuragen.data.network.model.AuthResponse
import ie.app.neuragen.data.repository.SessionRepository
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.firstOrNull
import neuragen.composeapp.generated.resources.Res
import neuragen.composeapp.generated.resources.compose_multiplatform
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.koinInject

@Composable
fun SplashScreen(
    onAuthenticated: () -> Unit,
    onNotAuthenticated: () -> Unit
) {
    val sessionRepository: SessionRepository = koinInject()

    LaunchedEffect(Unit) {
        delay(1500)
        val session = sessionRepository.getSession().firstOrNull()
        if (session != null) {
            onAuthenticated()
        } else {
            onNotAuthenticated()
        }
    }

    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Image(
            painter = painterResource(Res.drawable.compose_multiplatform),
            contentDescription = null,
            modifier = Modifier.size(150.dp)
        )
    }
}
