package ie.app.neuragen.util

import android.content.Context
import android.net.Uri
import androidx.browser.customtabs.CustomTabsIntent
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext

@Composable
actual fun rememberInAppBrowser(): InAppBrowser {
    val context = LocalContext.current
    return remember(context) { AndroidInAppBrowser(context) }
}

class AndroidInAppBrowser(private val context: Context) : InAppBrowser {
    override fun openUrl(url: String) {
        try {
            val intent = CustomTabsIntent.Builder().build()
            intent.launchUrl(context, Uri.parse(url))
        } catch (e: Exception) {
            // Fallback to default browser if Custom Tabs fails
            val fallbackIntent = android.content.Intent(android.content.Intent.ACTION_VIEW, Uri.parse(url))
            fallbackIntent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(fallbackIntent)
        }
    }
}
