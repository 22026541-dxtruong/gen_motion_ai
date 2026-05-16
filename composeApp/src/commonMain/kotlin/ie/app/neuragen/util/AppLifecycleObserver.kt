package ie.app.neuragen.util

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Global singleton that tracks app foreground/background state.
 * ViewModels can observe [isInForeground] to refresh data when user returns.
 *
 * Platform entry points call [onForeground] / [onBackground].
 * Compose screens use LifecycleResumeEffect for per-screen refresh.
 */
object AppLifecycleObserver {
    private val _isInForeground = MutableStateFlow(true)
    val isInForeground: StateFlow<Boolean> = _isInForeground.asStateFlow()

    private val _resumeCount = MutableStateFlow(0)
    val resumeCount: StateFlow<Int> = _resumeCount.asStateFlow()

    fun onForeground() {
        _isInForeground.value = true
        _resumeCount.value++
    }

    fun onBackground() {
        _isInForeground.value = false
    }
}
