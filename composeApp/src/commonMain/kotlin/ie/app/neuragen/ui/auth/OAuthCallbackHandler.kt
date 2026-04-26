package ie.app.neuragen.ui.auth

import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import org.koin.core.annotation.Single

@Single
class OAuthCallbackHandler {
    private val _callbacks = MutableSharedFlow<Map<String, String>>(extraBufferCapacity = 1)
    val callbacks: SharedFlow<Map<String, String>> = _callbacks.asSharedFlow()

    fun handleCallback(query: Map<String, String>) {
        _callbacks.tryEmit(query)
    }
}
