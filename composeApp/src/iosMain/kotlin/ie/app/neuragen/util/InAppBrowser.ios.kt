package ie.app.neuragen.util

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import platform.Foundation.NSURL
import platform.SafariServices.SFSafariViewController
import platform.SafariServices.SFSafariViewControllerDelegateProtocol
import platform.UIKit.UIApplication
import platform.UIKit.UIViewController
import platform.darwin.NSObject

@Composable
actual fun rememberInAppBrowser(): InAppBrowser {
    return remember { IOSInAppBrowser() }
}

class IOSInAppBrowser : InAppBrowser {
    private val delegate = object : NSObject(), SFSafariViewControllerDelegateProtocol {
        override fun safariViewControllerDidFinish(controller: SFSafariViewController) {
            AppLifecycleObserver.onForeground()
        }
    }

    override fun openUrl(url: String) {
        val nsUrl = NSURL(string = url) ?: return
        val safariVC = SFSafariViewController(uRL = nsUrl)
        safariVC.delegate = delegate
        
        var topController: UIViewController? = UIApplication.sharedApplication.keyWindow?.rootViewController
        while (topController?.presentedViewController != null) {
            topController = topController.presentedViewController
        }
        
        topController?.presentViewController(safariVC, animated = true, completion = null)
    }
}
