package ie.app.neuragen.ui.common

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.UIKitView
import platform.AVFoundation.AVPlayer
import platform.AVFoundation.play
import platform.AVKit.AVPlayerViewController
import platform.Foundation.NSURL

@Composable
actual fun VideoPlayer(videoUrl: String, modifier: Modifier) {
    val player = remember {
        AVPlayer(uRL = NSURL.URLWithString(videoUrl) ?: NSURL())
    }

    val playerViewController = remember {
        AVPlayerViewController().apply {
            this.player = player
            this.showsPlaybackControls = true
        }
    }

    // Nhúng iOS native view vào Compose
    UIKitView(
        factory = {
            playerViewController.view
        },
        modifier = modifier,
        update = { _ ->
            player.play()
        }
    )
}