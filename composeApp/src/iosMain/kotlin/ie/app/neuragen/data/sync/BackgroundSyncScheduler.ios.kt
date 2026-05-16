package ie.app.neuragen.data.sync

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.launch
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject
import platform.BackgroundTasks.BGAppRefreshTaskRequest
import platform.BackgroundTasks.BGTask
import platform.BackgroundTasks.BGTaskScheduler
import platform.Foundation.NSDate
import platform.Foundation.dateByAddingTimeInterval

@OptIn(ExperimentalForeignApi::class)
actual class BackgroundSyncScheduler : KoinComponent {
    private val syncService: DataSyncService by inject()

    actual fun schedulePeriodicSync() {
        scheduleNextRefresh()
        println("BackgroundSyncScheduler [iOS]: Scheduled BGAppRefreshTask")
    }

    actual fun cancelSync() {
        BGTaskScheduler.sharedScheduler.cancelTaskRequestWithIdentifier(TASK_IDENTIFIER)
        println("BackgroundSyncScheduler [iOS]: Cancelled background sync")
    }

    fun handleBackgroundTask(task: BGTask) {
        println("BackgroundSyncScheduler [iOS]: BGTask triggered, starting sync...")

        val scope = CoroutineScope(Dispatchers.IO)
        scope.launch {
            try {
                val success = syncService.performSync()
                task.setTaskCompletedWithSuccess(success)
                println("BackgroundSyncScheduler [iOS]: BGTask completed. Success=$success")
            } catch (e: Exception) {
                println("BackgroundSyncScheduler [iOS]: BGTask failed: ${e.message}")
                task.setTaskCompletedWithSuccess(false)
            }
        }

        // Schedule the next occurrence
        scheduleNextRefresh()
    }

    private fun scheduleNextRefresh() {
        try {
            val request = BGAppRefreshTaskRequest(identifier = TASK_IDENTIFIER)
            // Request earliest begin date: 30 minutes from now
            request.earliestBeginDate = NSDate().dateByAddingTimeInterval(30.0 * 60.0)
            BGTaskScheduler.sharedScheduler.submitTaskRequest(request, error = null)
            println("BackgroundSyncScheduler [iOS]: Next sync scheduled in ~30 minutes")
        } catch (e: Exception) {
            println("BackgroundSyncScheduler [iOS]: Failed to schedule: ${e.message}")
        }
    }

    companion object {
        const val TASK_IDENTIFIER = "ie.app.neuragen.data-sync"
    }
}
