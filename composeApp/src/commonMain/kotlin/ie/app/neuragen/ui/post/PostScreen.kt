package ie.app.neuragen.ui.post

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.VerticalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.Favorite
import androidx.compose.material.icons.rounded.FavoriteBorder
import androidx.compose.material.icons.rounded.ModeComment
import androidx.compose.material.icons.rounded.Send
import androidx.compose.material.icons.rounded.Visibility
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.Spring
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.ui.graphics.graphicsLayer
import coil3.compose.AsyncImage
import ie.app.neuragen.data.network.model.CommentDto
import ie.app.neuragen.ui.common.VideoPlayer
import ie.app.neuragen.ui.explore.SharedFeedState
import org.koin.compose.viewmodel.koinViewModel

// Colors matching web
private val Indigo600 = Color(0xFF4F46E5)
private val SlateText = Color(0xFF0F172A)
private val GrayText = Color(0xFF94A3B8)

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun PostScreen(
    postId: String,
    onBackClick: () -> Unit = {},
    onUserClick: (userId: String) -> Unit = {}
) {
    val items by SharedFeedState.itemsFlow.collectAsState()

    val initialIndex = remember(items, postId) {
        val idx = items.indexOfFirst { it.postId == postId || it.post?.id == postId }
        if (idx != -1) idx else 0
    }

    val pagerState = rememberPagerState(
        initialPage = initialIndex,
        pageCount = { items.size.coerceAtLeast(1) }
    )

    LaunchedEffect(pagerState.currentPage) {
        if (pagerState.currentPage >= items.size - 2 && items.isNotEmpty()) {
            SharedFeedState.onLoadMore?.invoke()
        }
    }

    if (items.isEmpty()) {
        PostDetailContent(
            postId = postId,
            onBackClick = onBackClick,
            onUserClick = onUserClick,
            isFocused = true
        )
    } else {
        VerticalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize()
        ) { page ->
            val item = items[page]
            val actualPostId = item.postId ?: item.post?.id ?: postId

            PostDetailContent(
                postId = actualPostId,
                onBackClick = onBackClick,
                onUserClick = onUserClick,
                isFocused = pagerState.currentPage == page
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PostDetailContent(
    postId: String,
    viewModel: PostViewModel = koinViewModel(key = postId),
    onBackClick: () -> Unit = {},
    onUserClick: (userId: String) -> Unit = {},
    isFocused: Boolean = true
) {
    val uiState by viewModel.uiState.collectAsState()
    var showComments by remember { mutableStateOf(false) }

    LaunchedEffect(postId) {
        viewModel.loadPost(postId)
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        // Video / Thumbnail
        val videoUrl = uiState.post?.videoUrl ?: uiState.post?.assetVersion?.fileUrl
        val thumbUrl = uiState.post?.thumbnailUrl

        if (isFocused && videoUrl != null) {
            VideoPlayer(
                videoUrl = videoUrl,
                modifier = Modifier.fillMaxSize()
            )
        } else if (thumbUrl != null) {
            AsyncImage(
                model = thumbUrl,
                contentDescription = null,
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Fit
            )
        } else {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color(0xFF0F0F23))
            )
        }

        // Loading
        if (uiState.isLoading) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = Color.White)
            }
        }

        // Gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.Black.copy(alpha = 0.4f),
                            Color.Transparent,
                            Color.Transparent,
                            Color.Black.copy(alpha = 0.6f)
                        )
                    )
                )
        )

        // Top bar: AI badge + close
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .statusBarsPadding()
                .padding(horizontal = 16.dp, vertical = 12.dp)
                .align(Alignment.TopCenter),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // AI Generated badge
            Surface(
                color = Color.White.copy(alpha = 0.15f),
                shape = RoundedCornerShape(20.dp)
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("✨", fontSize = 14.sp)
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        "AI Generated",
                        style = MaterialTheme.typography.labelMedium,
                        color = Color.White.copy(alpha = 0.9f),
                        fontWeight = FontWeight.Medium
                    )
                }
            }

            // Close button
            IconButton(
                onClick = onBackClick,
                modifier = Modifier
                    .size(40.dp)
                    .background(Color.White.copy(alpha = 0.15f), CircleShape)
            ) {
                Icon(
                    Icons.Rounded.Close,
                    contentDescription = "Close",
                    tint = Color.White,
                    modifier = Modifier.size(22.dp)
                )
            }
        }

        // Right side interaction buttons
        Column(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(bottom = 120.dp, end = 12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // Like
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                val heartScale by animateFloatAsState(
                    targetValue = if (uiState.isLiked) 1.4f else 1f,
                    animationSpec = spring(
                        dampingRatio = Spring.DampingRatioMediumBouncy,
                        stiffness = Spring.StiffnessLow
                    ),
                    label = "heartScale"
                )
                
                IconButton(
                    onClick = viewModel::toggleLike,
                    modifier = Modifier
                        .size(48.dp)
                        .background(
                            if (uiState.isLiked) Color.Red.copy(alpha = 0.8f)
                            else Color.Black.copy(alpha = 0.4f),
                            CircleShape
                        )
                ) {
                    Icon(
                        if (uiState.isLiked) Icons.Rounded.Favorite else Icons.Rounded.FavoriteBorder,
                        contentDescription = "Like",
                        tint = Color.White,
                        modifier = Modifier
                            .size(24.dp)
                            .graphicsLayer {
                                scaleX = heartScale
                                scaleY = heartScale
                            }
                    )
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    formatCount(uiState.post?.likeCount ?: 0),
                    color = Color.White,
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.SemiBold
                )
            }

            // Comment
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                val commentInteractionSource = remember { MutableInteractionSource() }
                val isCommentPressed by commentInteractionSource.collectIsPressedAsState()
                val commentScale by animateFloatAsState(
                    targetValue = if (isCommentPressed) 0.8f else 1f,
                    animationSpec = spring(
                        dampingRatio = Spring.DampingRatioMediumBouncy,
                        stiffness = Spring.StiffnessLow
                    ),
                    label = "commentScale"
                )

                IconButton(
                    onClick = { showComments = true },
                    interactionSource = commentInteractionSource,
                    modifier = Modifier
                        .size(48.dp)
                        .background(Color.Black.copy(alpha = 0.4f), CircleShape)
                        .graphicsLayer {
                            scaleX = commentScale
                            scaleY = commentScale
                        }
                ) {
                    Icon(
                        Icons.Rounded.ModeComment,
                        contentDescription = "Comments",
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    formatCount(uiState.post?.commentCount ?: 0),
                    color = Color.White,
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.SemiBold
                )
            }

            // Views
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                IconButton(
                    onClick = {},
                    modifier = Modifier
                        .size(48.dp)
                        .background(Color.Black.copy(alpha = 0.4f), CircleShape)
                ) {
                    Icon(
                        Icons.Rounded.Visibility,
                        contentDescription = "Views",
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    formatCount(uiState.post?.viewCount ?: 0),
                    color = Color.White,
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }

        // Bottom info overlay
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.BottomStart)
                .padding(start = 16.dp, end = 72.dp, bottom = 24.dp)
                .navigationBarsPadding()
        ) {
            // Author row
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.clickable {
                    uiState.post?.userId?.let { onUserClick(it) }
                }
            ) {
                val username = uiState.post?.user?.username ?: "U"
                val avatarUrl = "https://ui-avatars.com/api/?name=$username&background=e0e7ff&color=4f46e5"

                AsyncImage(
                    model = avatarUrl,
                    contentDescription = null,
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape),
                    contentScale = ContentScale.Crop
                )

                Spacer(modifier = Modifier.width(10.dp))

                Column {
                    Text(
                        text = "@${uiState.post?.user?.username ?: "user"}",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = timeAgo(uiState.post?.createdAt ?: ""),
                        style = MaterialTheme.typography.labelSmall,
                        color = Color.White.copy(alpha = 0.6f)
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Caption
            if (!uiState.post?.caption.isNullOrBlank()) {
                Text(
                    text = uiState.post?.caption ?: "",
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color.White,
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis,
                    lineHeight = 20.sp
                )
            }
        }

        // Comments bottom sheet
        if (showComments) {
            ModalBottomSheet(
                onDismissRequest = { showComments = false },
                sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
                containerColor = MaterialTheme.colorScheme.surface,
                shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
            ) {
                CommentsContent(
                    comments = uiState.comments,
                    onAddComment = viewModel::addComment,
                    isAdding = uiState.isCommenting,
                    onUserClick = onUserClick
                )
            }
        }
    }
}

@Composable
fun CommentsContent(
    comments: List<CommentDto>,
    onAddComment: (String) -> Unit,
    isAdding: Boolean,
    onUserClick: (userId: String) -> Unit = {}
) {
    var commentText by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxHeight(0.7f)
    ) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Comments",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = SlateText
            )
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = "(${comments.size})",
                style = MaterialTheme.typography.titleMedium,
                color = GrayText
            )
        }

        HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

        // Comments list
        LazyColumn(
            modifier = Modifier.weight(1f),
            contentPadding = PaddingValues(vertical = 8.dp)
        ) {
            if (comments.isEmpty()) {
                item {
                    Box(
                        Modifier.fillMaxWidth().padding(48.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            "No comments yet. Be the first!",
                            color = GrayText,
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            }
            items(comments) { comment ->
                CommentItem(comment = comment, onUserClick = onUserClick)
            }
        }

        // Input bar
        HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Avatar
            Surface(
                modifier = Modifier.size(32.dp),
                shape = CircleShape,
                color = Color(0xFFE0E7FF)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Text("Me", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Indigo600)
                }
            }
            Spacer(modifier = Modifier.width(10.dp))
            OutlinedTextField(
                value = commentText,
                onValueChange = { commentText = it },
                placeholder = {
                    Text("Add a comment...", style = MaterialTheme.typography.bodySmall, color = GrayText)
                },
                modifier = Modifier.weight(1f).height(44.dp),
                shape = RoundedCornerShape(22.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MaterialTheme.colorScheme.outline,
                    unfocusedBorderColor = MaterialTheme.colorScheme.outlineVariant,
                    focusedContainerColor = MaterialTheme.colorScheme.surface,
                    unfocusedContainerColor = MaterialTheme.colorScheme.surface,
                    focusedTextColor = SlateText,
                    unfocusedTextColor = SlateText
                ),
                singleLine = true,
                textStyle = MaterialTheme.typography.bodySmall
            )
            Spacer(modifier = Modifier.width(8.dp))
            IconButton(
                onClick = {
                    if (commentText.isNotBlank()) {
                        onAddComment(commentText)
                        commentText = ""
                    }
                },
                enabled = commentText.isNotBlank() && !isAdding,
                modifier = Modifier
                    .size(36.dp)
                    .background(
                        if (commentText.isNotBlank() && !isAdding) Indigo600
                        else MaterialTheme.colorScheme.surfaceVariant,
                        CircleShape
                    )
            ) {
                if (isAdding) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        color = Color.White,
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(
                        Icons.Rounded.Send,
                        contentDescription = "Send",
                        tint = if (commentText.isNotBlank()) Color.White else GrayText,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun CommentItem(
    comment: CommentDto,
    onUserClick: (userId: String) -> Unit = {}
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        val username = comment.user?.username ?: "U"
        val avatarUrl = "https://ui-avatars.com/api/?name=$username&background=e0e7ff&color=4f46e5"

        AsyncImage(
            model = avatarUrl,
            contentDescription = null,
            modifier = Modifier
                .size(32.dp)
                .clip(CircleShape)
                .clickable { comment.user?.id?.let { onUserClick(it) } },
            contentScale = ContentScale.Crop
        )

        Column(modifier = Modifier.weight(1f)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "@${comment.user?.username ?: "user"}",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.SemiBold,
                    color = SlateText,
                    modifier = Modifier.clickable {
                        comment.user?.id?.let { onUserClick(it) }
                    }
                )
                Text(
                    text = timeAgo(comment.createdAt),
                    style = MaterialTheme.typography.labelSmall,
                    color = GrayText
                )
            }
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = comment.content,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                lineHeight = 18.sp
            )
        }
    }
}

// --- Helpers ---

private fun formatCount(n: Int): String {
    if (n >= 1_000_000) {
        val v = n / 1_000_000.0
        return "${((v * 10).toInt() / 10.0)}M"
    }
    if (n >= 1000) {
        val v = n / 1000.0
        return "${((v * 10).toInt() / 10.0)}k"
    }
    return n.toString()
}

private fun timeAgo(dateStr: String): String {
    if (dateStr.isBlank()) return ""
    return try {
        val datePart = dateStr.take(10)
        val timePart = dateStr.substringAfter("T").take(5)
        "$datePart $timePart"
    } catch (e: Exception) {
        dateStr.take(10)
    }
}
