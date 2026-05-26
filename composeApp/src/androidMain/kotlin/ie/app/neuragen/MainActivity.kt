package ie.app.neuragen

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import ie.app.neuragen.ui.auth.OAuthCallbackHandler
import org.koin.android.ext.android.inject

class MainActivity : ComponentActivity() {
    private val oauthCallbackHandler: OAuthCallbackHandler by inject()

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        handleIntent(intent)

        setContent {
            App()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        ie.app.neuragen.util.AppLifecycleObserver.onForeground()
    }

    override fun onPause() {
        super.onPause()
        ie.app.neuragen.util.AppLifecycleObserver.onBackground()
    }

    private fun handleIntent(intent: Intent?) {
        intent?.data?.let { uri ->
            if (uri.scheme == "neuragen" && uri.host == "auth" && uri.path == "/callback") {
                val queryParams = uri.queryParameterNames.associateWith { name ->
                    uri.getQueryParameter(name) ?: ""
                }
                oauthCallbackHandler.handleCallback(queryParams)
            } else {
                // For payment callbacks, trigger foreground refresh
                ie.app.neuragen.util.AppLifecycleObserver.onForeground()
            }
        }
    }
}

@Preview
@Composable
fun AppAndroidPreview() {
    App()
}