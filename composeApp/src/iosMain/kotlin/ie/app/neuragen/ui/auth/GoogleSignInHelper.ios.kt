package ie.app.neuragen.ui.auth

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember

import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

interface IosGoogleSignInProvider {
    fun signIn(onSuccess: (String) -> Unit, onError: (String) -> Unit)
}

var iosGoogleSignInProvider: IosGoogleSignInProvider? = null

actual class GoogleSignInHelper {
    actual suspend fun getIdToken(): String = suspendCoroutine { continuation ->
        val provider = iosGoogleSignInProvider
        if (provider == null) {
            continuation.resumeWithException(IllegalStateException("Google Sign-In provider chưa được thiết lập từ iOS app."))
            return@suspendCoroutine
        }
        
        provider.signIn(
            onSuccess = { token -> continuation.resume(token) },
            onError = { errorMsg -> continuation.resumeWithException(Exception(errorMsg)) }
        )
    }
}

@Composable
actual fun rememberGoogleSignInHelper(): GoogleSignInHelper {
    return remember { GoogleSignInHelper() }
}
