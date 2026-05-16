package ie.app.neuragen.data.sync

import ie.app.neuragen.data.local.dao.ExploreDao
import ie.app.neuragen.data.local.dao.JobDao
import ie.app.neuragen.data.local.dao.UserProfileDao
import ie.app.neuragen.data.local.entity.CachedExploreItem
import ie.app.neuragen.data.local.entity.CachedJob
import ie.app.neuragen.data.local.entity.CachedUserProfile
import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.util.currentTimeMillis
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

/**
 * Shared data sync service callable from both Android (WorkManager) and iOS (BGTaskScheduler).
 * Performs the actual API → Room ingestion logic.
 */
@Single
class DataSyncService(
    @Provided private val api: NeuraGenApi,
    @Provided private val exploreDao: ExploreDao,
    @Provided private val jobDao: JobDao,
    @Provided private val userProfileDao: UserProfileDao
) {
    private val json = Json { ignoreUnknownKeys = true }

    /**
     * Performs a full data sync: Explore + Jobs + Profile.
     * Each section is independently try-caught so partial failures don't block others.
     * @return true if at least one sync succeeded, false if all failed.
     */
    suspend fun performSync(): Boolean {
        println("DataSyncService: Starting sync...")
        val now = currentTimeMillis()
        var anySuccess = false

        // 1. Sync Explore feed (trending)
        try {
            val response = api.getExplore(mode = "trending", limit = 20)
            val cached = response.data.mapIndexed { i, item ->
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
            println("DataSyncService: Synced ${cached.size} explore items")
            anySuccess = true
        } catch (e: Exception) {
            println("DataSyncService: Failed to sync explore: ${e.message}")
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
            println("DataSyncService: Synced ${cachedJobs.size} jobs")
            anySuccess = true
        } catch (e: Exception) {
            println("DataSyncService: Failed to sync jobs: ${e.message}")
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
            println("DataSyncService: Synced user profile")
            anySuccess = true
        } catch (e: Exception) {
            println("DataSyncService: Failed to sync profile: ${e.message}")
        }

        // 4. Cleanup stale cache (> 4 hours)
        val fourHoursAgo = now - 4 * 60 * 60 * 1000
        try {
            exploreDao.clearOlderThan(fourHoursAgo)
            jobDao.clearOlderThan(fourHoursAgo)
        } catch (_: Exception) {}

        println("DataSyncService: Sync completed. Success=$anySuccess")
        return anySuccess
    }
}
