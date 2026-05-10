package ie.app.neuragen.ui.common

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.UIKitView
import kotlinx.cinterop.ExperimentalForeignApi
import platform.AVFoundation.AVLayerVideoGravityResizeAspect
import platform.AVFoundation.AVPlayer
import platform.AVFoundation.AVPlayerItem
import platform.AVFoundation.AVPlayerLayer
import platform.AVFoundation.currentItem
import platform.AVFoundation.play
import platform.AVFoundation.seekToTime
import platform.CoreMedia.kCMTimeZero
import platform.Foundation.NSNotificationCenter
import platform.Foundation.NSURL
import platform.QuartzCore.CALayer
import platform.UIKit.UIView
import platform.darwin.NSObjectProtocol

@OptIn(ExperimentalForeignApi::class)
@Composable
actual fun VideoPlayer(videoUrl: String, modifier: Modifier) {
    val player = remember {
        AVPlayer(uRL = NSURL.URLWithString(videoUrl) ?: NSURL())
    }

    val playerLayer = remember {
        AVPlayerLayer().apply {
            this.player = player
            this.videoGravity = AVLayerVideoGravityResizeAspect
        }
    }

    // Loop: observe end of playback → seek to start
    DisposableEffect(player) {
        val observer: NSObjectProtocol = NSNotificationCenter.defaultCenter.addObserverForName(
            name = platform.AVFoundation.AVPlayerItemDidPlayToEndTimeNotification,
            `object` = player.currentItem,
            queue = null
        ) { _ ->
            player.seekToTime(kCMTimeZero)
            player.play()
        }

        player.play()

        onDispose {
            NSNotificationCenter.defaultCenter.removeObserver(observer)
            player.pause()
        }
    }

    UIKitView(
        factory = {
            val container = UIView()
            container.layer.addSublayer(playerLayer)
            container
        },
        modifier = modifier,
        update = { view ->
            playerLayer.frame = view.bounds
        }
    )
}