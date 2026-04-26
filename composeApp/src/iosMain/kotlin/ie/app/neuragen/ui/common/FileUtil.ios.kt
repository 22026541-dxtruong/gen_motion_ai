package ie.app.neuragen.ui.common

import androidx.compose.runtime.Composable
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.usePinned
import platform.Foundation.NSData
import platform.Foundation.dataWithContentsOfFile
import platform.posix.memcpy

@OptIn(ExperimentalForeignApi::class)
@Composable
actual fun rememberFileBytesLoader(): (String) -> ByteArray? {
    return { path ->
        val data = NSData.dataWithContentsOfFile(path)
        data?.let {
            val bytes = ByteArray(it.length.toInt())
            bytes.usePinned { pinned ->
                memcpy(pinned.addressOf(0), it.bytes, it.length)
            }
            bytes
        }
    }
}
