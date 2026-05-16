package ie.app.neuragen.data.sync

/**
 * Platform-specific background data sync scheduler.
 * Android: WorkManager (30 min periodic)
 * iOS: BGTaskScheduler / BGAppRefreshTask (30 min periodic)
 */
expect class BackgroundSyncScheduler {
    fun schedulePeriodicSync()
    fun cancelSync()
}
