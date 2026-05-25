package ie.app.neuragen.ui.auth

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember

import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

interface IosGoogleSignInProvider {
    suspend fun signIn(): String
}

var iosGoogleSignInProvider: IosGoogleSignInProvider? = null

actual class GoogleSignInHelper {
    actual suspend fun getIdToken(): String {
        val provider = iosGoogleSignInProvider
            ?: throw IllegalStateException("Google Sign-In provider chưa được thiết lập từ iOS app.")
        return provider.signIn()
    }
}

@Composable
actual fun rememberGoogleSignInHelper(): GoogleSignInHelper {
    return remember { GoogleSignInHelper() }
}
