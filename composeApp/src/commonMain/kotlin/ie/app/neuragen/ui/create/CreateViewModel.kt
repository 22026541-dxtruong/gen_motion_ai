package ie.app.neuragen.ui.create

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.JobDto
import ie.app.neuragen.data.network.model.VideoJobRequest
import ie.app.neuragen.data.repository.JobRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

data class CreateUiState(
    val prompt: String = "",
    val negativePrompt: String = "",
    val selectedPresetId: String = "standard",
    val includeBackgroundAudio: Boolean = false,
    val recentJobs: List<JobDto> = emptyList(),
    val isLoadingJobs: Boolean = false,
    val isGenerating: Boolean = false,
    val error: String? = null
)

@KoinViewModel
class CreateViewModel(
    @Provided private val jobRepository: JobRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CreateUiState())
    val uiState: StateFlow<CreateUiState> = _uiState.asStateFlow()

    init {
        println("CreateViewModel: Initializing...")
        refreshJobs()
    }

    fun onPromptChange(newPrompt: String) {
        _uiState.update { it.copy(prompt = newPrompt) }
    }

    fun onNegativePromptChange(newNegativePrompt: String) {
        _uiState.update { it.copy(negativePrompt = newNegativePrompt) }
    }

    fun onPresetSelected(presetId: String) {
        println("CreateViewModel: Preset selected: $presetId")
        _uiState.update { it.copy(selectedPresetId = presetId) }
    }

    fun refreshJobs() {
        viewModelScope.launch {
            println("CreateViewModel: Refreshing jobs...")
            _uiState.update { it.copy(isLoadingJobs = true) }
            val result = jobRepository.getJobs()
            result.onSuccess { jobs ->
                println("CreateViewModel: Successfully loaded ${jobs.size} jobs")
                _uiState.update { it.copy(recentJobs = jobs, isLoadingJobs = false) }
            }.onFailure { error ->
                println("CreateViewModel: Failed to load jobs: ${error.message}")
                _uiState.update { it.copy(isLoadingJobs = false, error = "Failed to load jobs") }
            }
        }
    }

    fun generateVideo() {
        viewModelScope.launch {
            val currentState = _uiState.value
            println("CreateViewModel: Starting video generation with prompt: ${currentState.prompt}")
            _uiState.update { it.copy(isGenerating = true, error = null) }
            
            val request = VideoJobRequest(
                prompt = currentState.prompt,
                negativePrompt = currentState.negativePrompt,
                presetId = currentState.selectedPresetId,
                includeBackgroundAudio = currentState.includeBackgroundAudio
            )

            val result = jobRepository.createVideoJob(request)
            result.onSuccess { response ->
                println("CreateViewModel: Job created successfully: ${response.jobId}")
                _uiState.update { it.copy(isGenerating = false, prompt = "", negativePrompt = "") }
                refreshJobs()
            }.onFailure { error ->
                println("CreateViewModel: Failed to create job: ${error.message}")
                _uiState.update { it.copy(isGenerating = false, error = "Failed to generate video") }
            }
        }
    }
}
