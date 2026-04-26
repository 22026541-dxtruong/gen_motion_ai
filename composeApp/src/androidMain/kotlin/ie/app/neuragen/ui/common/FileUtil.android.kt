package ie.app.neuragen.ui.common

import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

@Composable
actual fun rememberFileBytesLoader(): (String) -> ByteArray? {
    val context = LocalContext.current
    return { uriString ->
        try {
            val uri = Uri.parse(uriString)
            context.contentResolver.openInputStream(uri)?.use { it.readBytes() }
        } catch (e: Exception) {
            null
        }
    }
}
