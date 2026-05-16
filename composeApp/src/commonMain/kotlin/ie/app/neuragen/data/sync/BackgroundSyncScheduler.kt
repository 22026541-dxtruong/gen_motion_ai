package ie.app.neuragen.data.sync

/**
 * Platform-specific background data sync scheduler.
 * Android: WorkManager
 * iOS: stub (BGTaskScheduler not implemented yet)
 */
expect class BackgroundSyncScheduler {
    fun schedulePeriodicSync()
    fun cancelSync()
}
