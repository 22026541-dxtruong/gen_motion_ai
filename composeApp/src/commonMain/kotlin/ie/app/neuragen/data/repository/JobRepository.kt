package ie.app.neuragen.data.repository

import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import kotlinx.coroutines.flow.Flow
import org.koin.core.annotation.Factory
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface JobRepository {
    suspend fun createVideoJob(request: VideoJobRequest): Result<JobResponse>
    suspend fun getJobs(): Result<List<JobDto>>
    suspend fun getJob(id: String): Result<JobDto>
    suspend fun getJobResult(id: String): Result<JobResultResponse>
    suspend fun cancelJob(id: String): Result<CancelJobResponse>
    fun streamJobEvents(jobId: String): Flow<JobStreamEvent>
}

@Single([JobRepository::class])
class JobRepositoryImpl(
    @Provided
    private val api: NeuraGenApi
) : JobRepository {

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
}
