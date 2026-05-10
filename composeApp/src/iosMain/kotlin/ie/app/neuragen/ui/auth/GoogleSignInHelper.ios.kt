package ie.app.neuragen.ui.auth

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember

actual class GoogleSignInHelper {
    actual suspend fun getIdToken(): String {
        throw UnsupportedOperationException("Google Sign-In chưa hỗ trợ trên iOS")
    }
}

@Composable
actual fun rememberGoogleSignInHelper(): GoogleSignInHelper {
    return remember { GoogleSignInHelper() }
}
