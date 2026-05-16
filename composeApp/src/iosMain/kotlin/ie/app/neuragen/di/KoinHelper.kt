package ie.app.neuragen.di

import ie.app.neuragen.data.sync.BackgroundSyncScheduler
import ie.app.neuragen.data.sync.DataSyncService
import ie.app.neuragen.ui.auth.OAuthCallbackHandler
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.launch
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject
import platform.BackgroundTasks.BGTaskScheduler

@OptIn(ExperimentalForeignApi::class)
object KoinHelper : KoinComponent {
    private val oauthCallbackHandler: OAuthCallbackHandler by inject()
    private val syncService: DataSyncService by inject()

    fun getOAuthCallbackHandler(): OAuthCallbackHandler = oauthCallbackHandler

    /**
     * Called from Swift AppDelegate.didFinishLaunching to register the BGTask handler.
     * This MUST be called before the app finishes launching.
     */
    fun registerBGTaskHandler() {
        BGTaskScheduler.sharedScheduler.registerForTaskWithIdentifier(
            identifier = BackgroundSyncScheduler.TASK_IDENTIFIER,
            usingQueue = null
        ) { task ->
            if (task != null) {
                val scheduler = BackgroundSyncScheduler()
                scheduler.handleBackgroundTask(task)
            }
        }
        println("KoinHelper: BGTask handler registered for ${BackgroundSyncScheduler.TASK_IDENTIFIER}")
    }

    /**
     * Called after Koin is initialized to schedule the first background sync.
     */
    fun startBackgroundSync() {
        val scheduler = BackgroundSyncScheduler()
        scheduler.schedulePeriodicSync()
        println("KoinHelper: Background sync started")
    }

    /**
     * Perform an immediate foreground sync (e.g., on app launch).
     */
    fun performImmediateSync() {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                syncService.performSync()
                println("KoinHelper: Immediate sync completed")
            } catch (e: Exception) {
                println("KoinHelper: Immediate sync failed: ${e.message}")
            }
        }
    }
}
