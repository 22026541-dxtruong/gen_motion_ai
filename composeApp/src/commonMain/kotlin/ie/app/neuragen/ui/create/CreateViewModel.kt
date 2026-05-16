package ie.app.neuragen.ui.create

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.*
import ie.app.neuragen.data.network.model.JobStreamEvent.*
import ie.app.neuragen.data.repository.AssetRepository
import ie.app.neuragen.data.repository.JobRepository
import ie.app.neuragen.data.repository.PostRepository
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

data class CreateUiState(
    val prompt: String = "",
    val negativePrompt: String = "",
    val selectedImageUri: String? = null,
    val selectedPresetId: String = "standard_wan22_ti2v",
    val recentJobs: List<JobDto> = emptyList(),
    val isLoadingJobs: Boolean = false,
    val isGenerating: Boolean = false,
    val error: String? = null,
    // Publish Video
    val isPublishDialogOpen: Boolean = false,
    val publishCaption: String = "",
    val publishingJobId: String? = null,
    val isPublishing: Boolean = false,
    val publishSuccess: Boolean = false,
    val publishError: String? = null
)

@KoinViewModel
class CreateViewModel(
    @Provided private val jobRepository: JobRepository,
    @Provided private val assetRepository: AssetRepository,
    @Provided private val postRepository: PostRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CreateUiState())
    val uiState: StateFlow<CreateUiState> = _uiState.asStateFlow()

    // Theo dõi các job đang được lắng nghe SSE để tránh tạo nhiều kết nối trùng lặp
    private val activeSseConnections = mutableSetOf<String>()

    init {
        println("CreateViewModel: Initializing...")
        // 1. Observe Room cache for instant display
        observeCachedJobs()
        // 2. Refresh from API in background
        refreshJobs()
    }

    private fun observeCachedJobs() {
        viewModelScope.launch {
            jobRepository.observeJobs().collect { cachedJobs ->
                if (cachedJobs.isNotEmpty() && _uiState.value.recentJobs.isEmpty()) {
                    _uiState.update { it.copy(recentJobs = cachedJobs) }
                    println("CreateViewModel: Loaded ${cachedJobs.size} jobs from cache")
                }
            }
        }
    }

    fun onPromptChange(newPrompt: String) {
        _uiState.update { it.copy(prompt = newPrompt) }
    }

    fun onNegativePromptChange(newNegativePrompt: String) {
        _uiState.update { it.copy(negativePrompt = newNegativePrompt) }
    }

    fun onImageSelected(uri: String?) {
        _uiState.update { it.copy(selectedImageUri = uri) }
    }

    fun onPresetSelected(presetId: String) {
        println("CreateViewModel: Preset selected: $presetId")
        _uiState.update { it.copy(selectedPresetId = presetId) }
    }

    // ─── Publish Video ───────────────────────────────────────────────────────

    fun openPublishDialog(job: JobDto) {
        println("CreateViewModel: Opening publish dialog for job ${job.id}")
        _uiState.update {
            it.copy(
                isPublishDialogOpen = true,
                publishingJobId = job.id,
                publishCaption = "",
                publishError = null,
                publishSuccess = false
            )
        }
    }

    fun onPublishCaptionChange(caption: String) {
        _uiState.update { it.copy(publishCaption = caption) }
    }

    fun dismissPublishDialog() {
        _uiState.update {
            it.copy(
                isPublishDialogOpen = false,
                publishingJobId = null,
                publishCaption = "",
                publishError = null,
                publishSuccess = false
            )
        }
    }

    fun publishVideo() {
        val currentState = _uiState.value
        val jobId = currentState.publishingJobId ?: return

        viewModelScope.launch {
            println("CreateViewModel: Publishing job $jobId as post...")
            _uiState.update { it.copy(isPublishing = true, publishError = null) }

            val result = postRepository.publishPost(
                jobId = jobId,
                caption = currentState.publishCaption
            )

            result.onSuccess { post ->
                println("CreateViewModel: Published successfully! Post id: ${post.id}")
                _uiState.update {
                    it.copy(
                        isPublishing = false,
                        publishSuccess = true,
                        isPublishDialogOpen = false,
                        publishingJobId = null,
                        publishCaption = ""
                    )
                }
            }.onFailure { error ->
                println("CreateViewModel: Failed to publish: ${error.message}")
                _uiState.update {
                    it.copy(
                        isPublishing = false,
                        publishError = error.message ?: "Failed to publish video"
                    )
                }
            }
        }
    }

    fun refreshJobs() {
        viewModelScope.launch {
            println("CreateViewModel: Refreshing jobs...")
            // Only show loading if cache is empty
            if (_uiState.value.recentJobs.isEmpty()) {
                _uiState.update { it.copy(isLoadingJobs = true) }
            }
            val result = jobRepository.getJobs()
            result.onSuccess { jobs ->
                println("CreateViewModel: Successfully loaded ${jobs.size} jobs")
                
                _uiState.update { state ->
                    // Merge new jobs with existing data (especially logs and URLs that might be missing in list response)
                    val updatedJobs = jobs.map { newJob ->
                        val existingJob = state.recentJobs.find { it.id == newJob.id }
                        newJob.copy(
                            logs = if (newJob.logs.isNullOrEmpty()) existingJob?.logs else newJob.logs,
                            output = newJob.output ?: existingJob?.output,
                            thumbnail = newJob.thumbnail ?: existingJob?.thumbnail
                        )
                    }
                    state.copy(recentJobs = updatedJobs, isLoadingJobs = false)
                }

                // Save to Room cache for offline access
                try { jobRepository.refreshAndCacheJobs() } catch (_: Exception) {}

                // TỰ ĐỘNG RECONNECT: Nối lại SSE cho các job đang chạy (khi user mở lại app/màn hình)
                jobs.forEach { job ->
                    val status = job.status.lowercase()
                    if (status !in listOf("completed", "failed", "cancelled")) {
                        observeJobEvents(job.id)
                    }
                }
            }.onFailure { error ->
                println("CreateViewModel: Failed to load jobs: ${error.message}")
                _uiState.update { it.copy(isLoadingJobs = false, error = "Failed to load jobs") }
            }
        }
    }

    fun generateVideo(imageBytes: ByteArray? = null) {
        viewModelScope.launch {
            val currentState = _uiState.value
            if (currentState.prompt.isBlank() && imageBytes == null) return@launch

            println("CreateViewModel: Starting video generation...")
            _uiState.update { it.copy(isGenerating = true, error = null) }

            var inputAssetId: String? = null

            // 1. Upload image if provided
            imageBytes?.let { bytes ->
                println("CreateViewModel: Uploading image bytes (${bytes.size} bytes)...")
                val uploadResult = assetRepository.uploadAsset(
                    fileBytes = bytes,
                    fileName = "input_image.jpg",
                    type = "IMAGE",
                    role = "INPUT"
                )
                uploadResult.onSuccess { asset ->
                    val assetId = asset.id
                    println("CreateViewModel: Image uploaded successfully, received assetId: $assetId")
                    inputAssetId = assetId
                }.onFailure { error ->
                    println("CreateViewModel: Failed to upload image: ${error.message}")
                    _uiState.update { it.copy(isGenerating = false, error = "Failed to upload image") }
                    return@launch
                }
            }

            println("CreateViewModel: Proceeding to create job with inputAssetId: $inputAssetId")

            // 2. Create Job
            val request = VideoJobRequest(
                inputAssetId = inputAssetId,
                prompt = currentState.prompt,
                negativePrompt = currentState.negativePrompt.ifBlank { null },
                presetId = currentState.selectedPresetId
            )

            val result = jobRepository.createVideoJob(request)
            result.onSuccess { response ->
                val id = response.jobId ?: response.id
                println("CreateViewModel: Job API call finished, received jobId: $id")

                // Xóa UI state
                _uiState.update { it.copy(isGenerating = false, prompt = "", negativePrompt = "", selectedImageUri = null) }

                refreshJobs()

                // Bắt đầu lắng nghe SSE
                id?.let { observeJobEvents(it) }
            }.onFailure { error ->
                println("CreateViewModel: Failed to create job: ${error.message}")
                _uiState.update { it.copy(isGenerating = false, error = "Failed to generate video") }
            }
        }
    }

    private fun observeJobEvents(jobId: String) {
        // Chặn kết nối trùng lặp
        if (activeSseConnections.contains(jobId)) return
        activeSseConnections.add(jobId)

        viewModelScope.launch {
            println("CreateViewModel: Starting SSE event observation for job: $jobId")
            var isFinished = false
            
            while (!isFinished && isActive) {
                try {
                    jobRepository.streamJobEvents(jobId).collect { event ->
                        when (event) {
                            is Snapshot -> {
                                println("CreateViewModel: SSE Snapshot received")
                                updateJobInState(event.data)
                                
                                val currentStatus = event.data.status.lowercase()
                                if (currentStatus in listOf("completed", "failed", "cancelled")) {
                                    isFinished = true
                                    println("CreateViewModel: Job finished from Snapshot. Closing SSE connection for $jobId.")
                                    activeSseConnections.remove(jobId)
                                    viewModelScope.launch {
                                        kotlinx.coroutines.delay(1500)
                                        refreshJobs()
                                    }
                                    this@launch.cancel() // Hủy coroutine -> Đóng Socket SSE
                                }
                            }
                            is Status -> {
                                println("CreateViewModel: SSE Status update: ${event.data.status}")
                                updateJobStatusInState(event.data)

                                val currentStatus = event.data.status.lowercase()
                                if (currentStatus in listOf("completed", "failed", "cancelled")) {
                                    isFinished = true
                                    println("CreateViewModel: Job finished. Closing SSE connection for $jobId.")
                                    activeSseConnections.remove(jobId)
                                    viewModelScope.launch {
                                        kotlinx.coroutines.delay(1500)
                                        refreshJobs()
                                    }
                                    this@launch.cancel() // Hủy coroutine -> Đóng Socket SSE
                                }
                            }
                            is Log -> {
                                println("CreateViewModel: SSE Log: ${event.data.message}")
                                updateJobLogsInState(event.data)
                            }
                            is Heartbeat -> {
                                // Bỏ qua để log đỡ nhiễu, nó chỉ giúp giữ kết nối
                            }
                        }
                    }
                } catch (e: kotlinx.coroutines.CancellationException) {
                    // Coroutine bị hủy một cách chủ động
                    throw e
                } catch (e: Exception) {
                    // Rớt mạng hoặc server đóng đột ngột
                    println("CreateViewModel: SSE Connection lost for job $jobId: ${e.message}. Reconnecting in 3s...")
                }
                
                if (!isFinished) {
                    kotlinx.coroutines.delay(3000)
                }
            }
            
            activeSseConnections.remove(jobId)
        }
    }

    private fun updateJobInState(snapshot: JobSnapshotEvent) {
        _uiState.update { state ->
            val updatedJobs = state.recentJobs.toMutableList()
            val index = updatedJobs.indexOfFirst { it.id == snapshot.jobId }

            // Tìm job cũ để giữ lại thông tin quan trọng (prompt, url kết quả)
            val existingJob = if (index != -1) updatedJobs[index] else null

            // Lấy prompt cũ nếu có, nếu không thì dùng mã id (FIX LỖI MẤT PROMPT)
            val fallbackPrompt = existingJob?.prompt ?: "Video Job ${snapshot.jobId.take(6)}"

            val jobDto = JobDto(
                id = snapshot.jobId,
                type = existingJob?.type ?: "IMAGE_TO_VIDEO",
                status = snapshot.status,
                progress = if (snapshot.progress > 1f) snapshot.progress / 100f else snapshot.progress,
                prompt = fallbackPrompt,
                errorMessage = snapshot.errorMessage,
                provider = snapshot.provider,
                modelName = snapshot.modelName,
                presetId = snapshot.presetId,
                tier = snapshot.tier,
                estimatedDurationSeconds = snapshot.estimatedDurationSeconds,
                workflow = snapshot.workflow,
                createdAt = snapshot.createdAt,
                updatedAt = snapshot.updatedAt,
                startedAt = snapshot.startedAt,
                completedAt = snapshot.completedAt,
                failedAt = snapshot.failedAt,
                output = existingJob?.output,       // Giữ lại Output URL
                thumbnail = existingJob?.thumbnail,  // Giữ lại Thumbnail URL
                logs = snapshot.logs // Sử dụng logs từ snapshot
            )

            if (index != -1) {
                updatedJobs[index] = jobDto
            } else {
                updatedJobs.add(0, jobDto)
            }
            state.copy(recentJobs = updatedJobs)
        }
    }

    private fun updateJobStatusInState(event: JobStatusEvent) {
        _uiState.update { state ->
            val updatedJobs = state.recentJobs.map {
                if (it.id == event.jobId) {
                    it.copy(
                        status = event.status,
                        progress = if (event.progress > 1f) event.progress / 100f else event.progress,
                        errorMessage = event.errorMessage ?: it.errorMessage,
                        startedAt = event.startedAt ?: it.startedAt,
                        completedAt = event.completedAt ?: it.completedAt,
                        failedAt = event.failedAt ?: it.failedAt
                    )
                } else it
            }
            state.copy(recentJobs = updatedJobs)
        }
    }

    private fun updateJobLogsInState(event: JobLogEvent) {
        _uiState.update { state ->
            val updatedJobs = state.recentJobs.map {
                if (it.id == event.jobId) {
                    val currentLogs = it.logs ?: emptyList()
                    val newLog = JobLogDto(
                        id = null,
                        jobId = event.jobId,
                        message = event.message,
                        createdAt = event.createdAt
                    )
                    it.copy(logs = currentLogs + newLog)
                } else it
            }
            state.copy(recentJobs = updatedJobs)
        }
    }
}
