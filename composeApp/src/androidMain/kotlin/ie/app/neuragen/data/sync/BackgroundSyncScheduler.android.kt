package ie.app.neuragen.data.sync

import android.content.Context
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

actual class BackgroundSyncScheduler(private val context: Context) {
    actual fun schedulePeriodicSync() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val syncRequest = PeriodicWorkRequestBuilder<DataSyncWorker>(
            30, TimeUnit.MINUTES
        )
            .setConstraints(constraints)
            .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 5, TimeUnit.MINUTES)
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            "neuragen_data_sync",
            ExistingPeriodicWorkPolicy.KEEP,
            syncRequest
        )

        println("BackgroundSyncScheduler: Periodic sync scheduled (30min interval)")
    }

    actual fun cancelSync() {
        WorkManager.getInstance(context).cancelUniqueWork("neuragen_data_sync")
        println("BackgroundSyncScheduler: Sync cancelled")
    }
}
