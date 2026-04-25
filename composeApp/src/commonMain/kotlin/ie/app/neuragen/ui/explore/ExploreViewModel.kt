package ie.app.neuragen.ui.explore

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.ExploreItemDto
import ie.app.neuragen.data.repository.ExploreRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

data class ExploreUiState(
    val forYouItems: List<ExploreItemDto> = emptyList(),
    val recentDiscoveries: List<ExploreItemDto> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
)


@KoinViewModel
class ExploreViewModel(
    @Provided
    private val exploreRepository: ExploreRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ExploreUiState())
    val uiState: StateFlow<ExploreUiState> = _uiState.asStateFlow()

    init {
        println("ExploreViewModel: Initializing...")
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            println("ExploreViewModel: Refreshing content... Current state: ${_uiState.value}")
            _uiState.update { it.copy(isLoading = true, error = null) }
            
            println("ExploreViewModel: Calling getForYou...")
            val forYouResult = exploreRepository.getForYou(limit = 5)
            println("ExploreViewModel: getForYou result Success: ${forYouResult.isSuccess}")
            
            println("ExploreViewModel: Calling getExplore...")
            val exploreResult = exploreRepository.getExplore(limit = 20)
            println("ExploreViewModel: getExplore result Success: ${exploreResult.isSuccess}")

            if (forYouResult.isSuccess && exploreResult.isSuccess) {
                val forYouItems = forYouResult.getOrThrow().data
                val exploreItems = exploreResult.getOrThrow().data
                println("ExploreViewModel: Successfully loaded ${forYouItems.size} ForYou items and ${exploreItems.size} explore items")
                _uiState.update { 
                    it.copy(
                        forYouItems = forYouItems,
                        recentDiscoveries = exploreItems,
                        isLoading = false
                    )
                }
            } else {
                val forYouError = forYouResult.exceptionOrNull()?.message
                val exploreError = exploreResult.exceptionOrNull()?.message
                val errorMsg = "Failed to load explore content. ForYou error: $forYouError, Explore error: $exploreError"
                println("ExploreViewModel: ERROR: $errorMsg")
                _uiState.update { 
                    it.copy(
                        isLoading = false,
                        error = "Failed to load explore content"
                    )
                }
            }
        }
    }


}
