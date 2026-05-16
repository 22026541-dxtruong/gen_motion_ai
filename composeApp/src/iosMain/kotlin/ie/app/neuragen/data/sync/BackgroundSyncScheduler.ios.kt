package ie.app.neuragen.data.sync

/**
 * iOS stub — BGTaskScheduler not implemented yet.
 * Background sync on iOS is controlled by the system and requires
 * registration in the iOS AppDelegate (Swift side).
 */
actual class BackgroundSyncScheduler {
    actual fun schedulePeriodicSync() {
        // No-op on iOS for now
        println("BackgroundSyncScheduler: iOS background sync not implemented yet")
    }

    actual fun cancelSync() {
        // No-op on iOS
    }
}
