package ie.app.neuragen.data.sync

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import ie.app.neuragen.data.local.dao.ExploreDao
import ie.app.neuragen.data.local.dao.JobDao
import ie.app.neuragen.data.local.dao.UserProfileDao
import ie.app.neuragen.data.local.entity.CachedExploreItem
import ie.app.neuragen.data.local.entity.CachedJob
import ie.app.neuragen.data.local.entity.CachedUserProfile
import ie.app.neuragen.data.network.NeuraGenApi
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class DataSyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params), KoinComponent {

    private val api: NeuraGenApi by inject()
    private val exploreDao: ExploreDao by inject()
    private val jobDao: JobDao by inject()
    private val userProfileDao: UserProfileDao by inject()

    private val json = Json { ignoreUnknownKeys = true }

    override suspend fun doWork(): Result {
        println("DataSyncWorker: Starting background sync...")

        return try {
            val now = System.currentTimeMillis()

            // 1. Sync Explore feed (trending mode)
            try {
                val exploreResponse = api.getExplore(mode = "trending", limit = 20)
                val cached = exploreResponse.data.mapIndexed { i, item ->
                    CachedExploreItem(
                        id = item.id,
                        jsonData = json.encodeToString(item),
                        mode = "trending",
                        cachedAt = now,
                        sortOrder = i
                    )
                }
                exploreDao.clearByMode("trending")
                exploreDao.insertAll(cached)
                println("DataSyncWorker: Synced ${cached.size} explore items")
            } catch (e: Exception) {
                println("DataSyncWorker: Failed to sync explore: ${e.message}")
            }

            // 2. Sync user jobs
            try {
                val jobs = api.getJobs()
                val cachedJobs = jobs.mapIndexed { i, job ->
                    CachedJob(
                        id = job.id,
                        jsonData = json.encodeToString(job),
                        cachedAt = now,
                        sortOrder = i
                    )
                }
                jobDao.clearAll()
                jobDao.insertAll(cachedJobs)
                println("DataSyncWorker: Synced ${cachedJobs.size} jobs")
            } catch (e: Exception) {
                println("DataSyncWorker: Failed to sync jobs: ${e.message}")
            }

            // 3. Sync user profile
            try {
                val user = api.getMe()
                userProfileDao.insert(
                    CachedUserProfile(
                        id = user.id,
                        jsonData = json.encodeToString(user),
                        cachedAt = now
                    )
                )
                println("DataSyncWorker: Synced user profile")
            } catch (e: Exception) {
                println("DataSyncWorker: Failed to sync profile: ${e.message}")
            }

            // 4. Cleanup old cache (> 4 hours)
            val fourHoursAgo = now - 4 * 60 * 60 * 1000
            exploreDao.clearOlderThan(fourHoursAgo)
            jobDao.clearOlderThan(fourHoursAgo)

            println("DataSyncWorker: Background sync completed successfully")
            Result.success()
        } catch (e: Exception) {
            println("DataSyncWorker: Sync failed: ${e.message}")
            if (runAttemptCount < 3) Result.retry() else Result.failure()
        }
    }
}
