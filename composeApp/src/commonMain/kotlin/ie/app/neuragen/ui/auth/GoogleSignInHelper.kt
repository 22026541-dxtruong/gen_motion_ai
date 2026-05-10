package ie.app.neuragen.ui.auth

import androidx.compose.runtime.Composable

/**
 * Platform-specific Google Sign-In helper.
 * Returns a Google ID token on success, throws on failure/cancel.
 */
expect class GoogleSignInHelper {
    suspend fun getIdToken(): String
}

/**
 * Creates a platform-specific GoogleSignInHelper instance within a Composable context.
 */
@Composable
expect fun rememberGoogleSignInHelper(): GoogleSignInHelper
