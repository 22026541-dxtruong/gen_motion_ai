package ie.app.neuragen.ui.explore

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.ExploreEventRequest
import ie.app.neuragen.data.network.model.ExploreItemDto
import ie.app.neuragen.data.network.model.JobDto
import ie.app.neuragen.data.repository.ExploreRepository
import ie.app.neuragen.data.repository.JobRepository
import ie.app.neuragen.data.repository.PostRepository
import ie.app.neuragen.data.repository.UserRepository
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

data class ExploreUiState(
    val forYouItems: List<ExploreItemDto> = emptyList(),
    val recentDiscoveries: List<ExploreItemDto> = emptyList(),
    val isLoading: Boolean = false,
    val isFetchingMore: Boolean = false,
    val nextCursor: String? = null,
    val error: String? = null,
    
    // Filters and Modes
    val activeMode: String = "trending", // "for_you", "trending", "top", "new"
    val sortFilter: String = "score", // "score", "newest"
    val trendingOnly: Boolean = false,
    
    // Search State
    val searchQuery: String = "",
    val isSearching: Boolean = false,
    
    // Publish State
    val isAuthenticated: Boolean = false,
    val userJobs: List<JobDto> = emptyList(),
    val isPublishing: Boolean = false,
    val publishError: String? = null,
    val publishSuccess: Boolean = false,

    // Inline Interaction State (optimistic updates)
    val likedPostIds: Set<String> = emptySet(),
    val likeCounts: Map<String, Int> = emptyMap(),
    val commentCounts: Map<String, Int> = emptyMap(),

    // Inline comment expansion
    val expandedCommentPostId: String? = null
)

@KoinViewModel
class ExploreViewModel(
    @Provided private val exploreRepository: ExploreRepository,
    @Provided private val userRepository: UserRepository,
    @Provided private val jobRepository: JobRepository,
    @Provided private val postRepository: PostRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ExploreUiState())
    val uiState: StateFlow<ExploreUiState> = _uiState.asStateFlow()

    private var searchJob: Job? = null

    // Impression batch queue — mirrors web's 5s batch interval
    private val impressionQueue = mutableListOf<String>()
    private var impressionFlushJob: Job? = null

    init {
        refresh()
        checkAuthAndLoadJobs()
        startImpressionFlushLoop()
    }

    // ──────────────────────────────────────────────────────────────
    // Inline Interactions (Like / Comment / Share)
    // ──────────────────────────────────────────────────────────────

    /**
     * Toggle like on a post with optimistic UI update.
     * Mirrors web's ExploreCard handleLike logic.
     */
    fun toggleLike(postId: String) {
        val currentlyLiked = _uiState.value.likedPostIds.contains(postId)
        val currentCount = getLikeCount(postId)

        // Optimistic update
        if (currentlyLiked) {
            _uiState.update {
                it.copy(
                    likedPostIds = it.likedPostIds - postId,
                    likeCounts = it.likeCounts + (postId to maxOf(0, currentCount - 1))
                )
            }
        } else {
            _uiState.update {
                it.copy(
                    likedPostIds = it.likedPostIds + postId,
                    likeCounts = it.likeCounts + (postId to currentCount + 1)
                )
            }
        }

        // Fire API
        viewModelScope.launch {
            val result = if (currentlyLiked) {
                postRepository.unlikePost(postId)
            } else {
                postRepository.likePost(postId)
            }

            if (result.isFailure) {
                // Revert optimistic update on failure
                if (currentlyLiked) {
                    _uiState.update {
                        it.copy(
                            likedPostIds = it.likedPostIds + postId,
                            likeCounts = it.likeCounts + (postId to currentCount)
                        )
                    }
                } else {
                    _uiState.update {
                        it.copy(
                            likedPostIds = it.likedPostIds - postId,
                            likeCounts = it.likeCounts + (postId to currentCount)
                        )
                    }
                }
            }
        }
    }

    /**
     * Submit a comment on a post from the inline comment box.
     */
    fun addComment(postId: String, content: String) {
        if (content.isBlank()) return
        viewModelScope.launch {
            val result = postRepository.createComment(postId, content.trim())
            if (result.isSuccess) {
                val currentCount = getCommentCount(postId)
                _uiState.update {
                    it.copy(
                        commentCounts = it.commentCounts + (postId to currentCount + 1),
                        expandedCommentPostId = null // Close inline comment
                    )
                }
            }
        }
    }

    fun toggleCommentExpansion(postId: String) {
        _uiState.update {
            it.copy(
                expandedCommentPostId = if (it.expandedCommentPostId == postId) null else postId
            )
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Event Tracking (Impressions & Clicks)
    // ──────────────────────────────────────────────────────────────

    /**
     * Queue an impression event for batch sending.
     * Mirrors web's IntersectionObserver → 5s batch interval.
     */
    fun trackImpression(postId: String) {
        synchronized(impressionQueue) {
            if (!impressionQueue.contains(postId)) {
                impressionQueue.add(postId)
            }
        }
    }

    /**
     * Track a click/open event immediately.
     */
    fun trackClick(postId: String) {
        viewModelScope.launch {
            exploreRepository.recordEvent(
                ExploreEventRequest(
                    postId = postId,
                    eventType = "OPEN_POST",
                    metadata = JsonObject(mapOf("surface" to JsonPrimitive("explore_mobile")))
                )
            )
        }
    }

    private fun startImpressionFlushLoop() {
        impressionFlushJob = viewModelScope.launch {
            while (true) {
                delay(5000) // 5s interval — matches web
                val batch: List<String>
                synchronized(impressionQueue) {
                    batch = impressionQueue.toList()
                    impressionQueue.clear()
                }
                if (batch.isNotEmpty()) {
                    exploreRepository.recordEventsBatch(
                        batch.map { postId ->
                            ExploreEventRequest(
                                postId = postId,
                                eventType = "IMPRESSION",
                                metadata = JsonObject(mapOf("surface" to JsonPrimitive("explore_mobile")))
                            )
                        }
                    )
                }
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // Helper — resolve counts with optimistic overrides
    // ──────────────────────────────────────────────────────────────

    private fun getLikeCount(postId: String): Int {
        return _uiState.value.likeCounts[postId]
            ?: findPost(postId)?.post?.likeCount
            ?: 0
    }

    private fun getCommentCount(postId: String): Int {
        return _uiState.value.commentCounts[postId]
            ?: findPost(postId)?.post?.commentCount
            ?: 0
    }

    private fun findPost(postId: String): ExploreItemDto? {
        val state = _uiState.value
        return state.recentDiscoveries.find { it.postId == postId }
            ?: state.forYouItems.find { it.postId == postId }
    }

    // ──────────────────────────────────────────────────────────────
    // Existing: Feed Loading, Search, Modes, Publish
    // ──────────────────────────────────────────────────────────────

    fun refresh(query: String = _uiState.value.searchQuery) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null, nextCursor = null) }

            val state = _uiState.value
            val mode = state.activeMode
            val sort = state.sortFilter
            val trendingParam = if (state.trendingOnly) true else null
            val topicParam = query.ifBlank { null }

            var fetchedData: List<ExploreItemDto> = emptyList()
            var fetchedNextCursor: String? = null
            var isSuccess = false

            if (topicParam != null && mode != "for_you") {
                exploreRepository.searchExplore(
                    topic = topicParam,
                    trending = trendingParam,
                    sort = sort,
                    limit = 20
                ).onSuccess {
                    fetchedData = it.data
                    fetchedNextCursor = it.nextCursor
                    isSuccess = true
                }
            } else if (mode == "for_you") {
                exploreRepository.getForYou(
                    topic = topicParam,
                    trending = trendingParam,
                    mode = mode,
                    sort = sort,
                    limit = 20
                ).onSuccess {
                    fetchedData = it.data
                    fetchedNextCursor = it.nextCursor
                    isSuccess = true
                }
            } else {
                exploreRepository.getExplore(
                    topic = topicParam,
                    trending = trendingParam,
                    mode = mode,
                    sort = sort,
                    limit = 20
                ).onSuccess {
                    fetchedData = it.data
                    fetchedNextCursor = it.nextCursor
                    isSuccess = true
                }
            }

            // Featured Spotlights ("For You" top carousel) - Only fetch if not searching
            val forYouResult = if (query.isBlank()) {
                exploreRepository.getForYou(limit = 5)
            } else null

            if (isSuccess && (forYouResult == null || forYouResult.isSuccess)) {
                _uiState.update { 
                    it.copy(
                        forYouItems = forYouResult?.getOrNull()?.data ?: emptyList(),
                        recentDiscoveries = fetchedData,
                        nextCursor = fetchedNextCursor,
                        isLoading = false,
                        // Reset interaction state on refresh
                        likedPostIds = emptySet(),
                        likeCounts = emptyMap(),
                        commentCounts = emptyMap()
                    )
                }
                SharedFeedState.updateState(fetchedData, fetchedNextCursor, topicParam)
                SharedFeedState.onLoadMore = { loadMore() }
            } else {
                _uiState.update { 
                    it.copy(
                        isLoading = false,
                        error = "Failed to load explore content"
                    )
                }
            }
        }
    }

    fun loadMore() {
        val currentState = _uiState.value
        if (currentState.isLoading || currentState.isFetchingMore || currentState.nextCursor == null) return

        viewModelScope.launch {
            _uiState.update { it.copy(isFetchingMore = true) }
            val query = currentState.searchQuery
            val mode = currentState.activeMode
            val sort = currentState.sortFilter
            val trendingParam = if (currentState.trendingOnly) true else null
            val topicParam = query.ifBlank { null }
            
            var fetchedData: List<ExploreItemDto> = emptyList()
            var fetchedNextCursor: String? = null
            var isSuccess = false
            
            if (topicParam != null && mode != "for_you") {
                exploreRepository.searchExplore(
                    topic = topicParam,
                    trending = trendingParam,
                    sort = sort,
                    limit = 20,
                    cursor = currentState.nextCursor
                ).onSuccess {
                    fetchedData = it.data
                    fetchedNextCursor = it.nextCursor
                    isSuccess = true
                }
            } else if (mode == "for_you") {
                exploreRepository.getForYou(
                    topic = topicParam,
                    trending = trendingParam,
                    mode = mode,
                    sort = sort,
                    limit = 20,
                    cursor = currentState.nextCursor
                ).onSuccess {
                    fetchedData = it.data
                    fetchedNextCursor = it.nextCursor
                    isSuccess = true
                }
            } else {
                exploreRepository.getExplore(
                    topic = topicParam,
                    trending = trendingParam,
                    mode = mode,
                    sort = sort,
                    limit = 20,
                    cursor = currentState.nextCursor
                ).onSuccess {
                    fetchedData = it.data
                    fetchedNextCursor = it.nextCursor
                    isSuccess = true
                }
            }

            if (isSuccess) {
                _uiState.update { 
                    it.copy(
                        recentDiscoveries = it.recentDiscoveries + fetchedData,
                        nextCursor = fetchedNextCursor,
                        isFetchingMore = false
                    )
                }
                SharedFeedState.appendItems(fetchedData, fetchedNextCursor)
            } else {
                _uiState.update { it.copy(isFetchingMore = false) }
            }
        }
    }

    fun onSearchQueryChange(newQuery: String) {
        _uiState.update { it.copy(searchQuery = newQuery, isSearching = newQuery.isNotBlank()) }
        searchJob?.cancel()
        searchJob = viewModelScope.launch {
            delay(500) // Debounce 500ms
            refresh(newQuery)
        }
    }

    fun clearSearch() {
        _uiState.update { it.copy(searchQuery = "", isSearching = false) }
        searchJob?.cancel()
        refresh("")
    }

    fun setMode(mode: String) {
        if (_uiState.value.activeMode == mode) return
        _uiState.update { it.copy(activeMode = mode) }
        refresh()
    }

    fun setSortFilter(sort: String) {
        if (_uiState.value.sortFilter == sort) return
        _uiState.update { it.copy(sortFilter = sort) }
        refresh()
    }

    fun setTrendingOnly(trendingOnly: Boolean) {
        if (_uiState.value.trendingOnly == trendingOnly) return
        _uiState.update { it.copy(trendingOnly = trendingOnly) }
        refresh()
    }

    private fun checkAuthAndLoadJobs() {
        viewModelScope.launch {
            val userResult = userRepository.getMe()
            if (userResult.isSuccess) {
                _uiState.update { it.copy(isAuthenticated = true) }
                // Fetch completed jobs
                val jobsResult = jobRepository.getJobs()
                if (jobsResult.isSuccess) {
                    val completedJobs = jobsResult.getOrThrow().filter { it.status == "COMPLETED" }
                    _uiState.update { it.copy(userJobs = completedJobs) }
                }
            } else {
                _uiState.update { it.copy(isAuthenticated = false, userJobs = emptyList()) }
            }
        }
    }

    fun publishJob(jobId: String, caption: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isPublishing = true, publishError = null, publishSuccess = false) }
            val result = postRepository.publishPost(jobId = jobId, caption = caption)
            if (result.isSuccess) {
                _uiState.update { it.copy(isPublishing = false, publishSuccess = true) }
                refresh() // Refresh to show new post
            } else {
                _uiState.update { 
                    it.copy(
                        isPublishing = false, 
                        publishError = result.exceptionOrNull()?.message ?: "Failed to publish"
                    )
                }
            }
        }
    }

    fun resetPublishState() {
        _uiState.update { it.copy(publishError = null, publishSuccess = false) }
    }

    override fun onCleared() {
        super.onCleared()
        impressionFlushJob?.cancel()
    }
}
