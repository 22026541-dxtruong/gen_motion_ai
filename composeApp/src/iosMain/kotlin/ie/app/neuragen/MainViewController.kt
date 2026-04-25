package ie.app.neuragen

import androidx.compose.ui.window.ComposeUIViewController
import ie.app.neuragen.di.AppModule
import org.koin.plugin.module.dsl.startKoin

fun MainViewController() = ComposeUIViewController(
    configure = {
        startKoin<AppModule>()
    }
) { App() }