package ie.app.neuragen.ui.explore

import ie.app.neuragen.data.network.model.ExploreItemDto
import kotlinx.coroutines.flow.MutableStateFlow

/**
 * A lightweight singleton to share feed context between the ExploreScreen and PostScreen,
 * allowing the PostScreen to initialize a VerticalPager with the current feed state.
 */
object SharedFeedState {
    var items: List<ExploreItemDto> = emptyList()
    var cursor: String? = null
    var topic: String? = null
    
    // A callback that PostScreen can trigger when reaching the end of the pager.
    // ExploreViewModel sets this when available.
    var onLoadMore: (() -> Unit)? = null
    
    // Use StateFlow to allow PostScreen to observe changes when new items are appended.
    val itemsFlow = MutableStateFlow<List<ExploreItemDto>>(emptyList())

    fun updateState(newItems: List<ExploreItemDto>, newCursor: String?, newTopic: String?) {
        items = newItems
        cursor = newCursor
        topic = newTopic
        itemsFlow.value = newItems
    }
    
    fun appendItems(newItems: List<ExploreItemDto>, newCursor: String?) {
        val updatedList = items + newItems
        items = updatedList
        cursor = newCursor
        itemsFlow.value = updatedList
    }

    fun clear() {
        items = emptyList()
        cursor = null
        topic = null
        onLoadMore = null
        itemsFlow.value = emptyList()
    }
}
