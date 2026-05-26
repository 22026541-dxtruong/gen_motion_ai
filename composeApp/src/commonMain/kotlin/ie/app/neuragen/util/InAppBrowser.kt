package ie.app.neuragen.util

import androidx.compose.runtime.Composable

@Composable
expect fun rememberInAppBrowser(): InAppBrowser

interface InAppBrowser {
    fun openUrl(url: String)
}
