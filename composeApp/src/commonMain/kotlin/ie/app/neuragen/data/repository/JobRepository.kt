package ie.app.neuragen.data.repository

import ie.app.neuragen.data.local.dao.JobDao
import ie.app.neuragen.data.local.entity.CachedJob
import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import ie.app.neuragen.util.currentTimeMillis
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface JobRepository {
    suspend fun createVideoJob(request: VideoJobRequest): Result<JobResponse>
    suspend fun getJobs(): Result<List<JobDto>>
    suspend fun getJob(id: String): Result<JobDto>
    suspend fun getJobResult(id: String): Result<JobResultResponse>
    suspend fun cancelJob(id: String): Result<CancelJobResponse>
    fun streamJobEvents(jobId: String): Flow<JobStreamEvent>

    // ── Cache-first API ──
    fun observeJobs(): Flow<List<JobDto>>
    suspend fun refreshAndCacheJobs(): Result<List<JobDto>>
}

@Single([JobRepository::class])
class JobRepositoryImpl(
    @Provided private val api: NeuraGenApi,
    @Provided private val jobDao: JobDao
) : JobRepository {

    private val json = Json { ignoreUnknownKeys = true }

    override suspend fun createVideoJob(request: VideoJobRequest): Result<JobResponse> = runCatching {
        api.createVideoJob(request)
    }

    override suspend fun getJobs(): Result<List<JobDto>> = runCatching {
        api.getJobs()
    }

    override suspend fun getJob(id: String): Result<JobDto> = runCatching {
        api.getJob(id)
    }

    override suspend fun getJobResult(id: String): Result<JobResultResponse> = runCatching {
        api.getJobResult(id)
    }

    override suspend fun cancelJob(id: String): Result<CancelJobResponse> = runCatching {
        api.cancelJob(id)
    }

    override fun streamJobEvents(jobId: String): Flow<JobStreamEvent> = api.streamJobEvents(jobId)

    // ── Cache-first ──

    override fun observeJobs(): Flow<List<JobDto>> {
        return jobDao.getAll().map { cachedList ->
            cachedList.mapNotNull { cached ->
                try {
                    json.decodeFromString<JobDto>(cached.jsonData)
                } catch (e: Exception) {
                    null
                }
            }
        }
    }

    override suspend fun refreshAndCacheJobs(): Result<List<JobDto>> {
        val result = runCatching { api.getJobs() }
        result.getOrNull()?.let { jobs ->
            val now = currentTimeMillis()
            val cached = jobs.mapIndexed { i, job ->
                CachedJob(
                    id = job.id,
                    jsonData = json.encodeToString(job),
                    cachedAt = now,
                    sortOrder = i
                )
            }
            jobDao.clearAll()
            jobDao.insertAll(cached)
        }
        return result
    }
}
