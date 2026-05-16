package ie.app.neuragen.data.sync

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class DataSyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params), KoinComponent {

    private val syncService: DataSyncService by inject()

    override suspend fun doWork(): Result {
        println("DataSyncWorker: Starting background sync...")

        return try {
            val success = syncService.performSync()
            if (success) {
                println("DataSyncWorker: Background sync completed successfully")
                Result.success()
            } else {
                if (runAttemptCount < 3) Result.retry() else Result.failure()
            }
        } catch (e: Exception) {
            println("DataSyncWorker: Sync failed: ${e.message}")
            if (runAttemptCount < 3) Result.retry() else Result.failure()
        }
    }
}
