package ie.app.neuragen.ui.userprofile

import androidx.compose.material3.MaterialTheme

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable

import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.unit.sp
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.Spring
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.AnnotatedString
import coil3.compose.AsyncImage
import ie.app.neuragen.data.network.model.ExploreItemDto
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.network.model.UserPublicDto
import ie.app.neuragen.ui.explore.SharedFeedState
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun UserProfileScreen(
    userId: String,
    viewModel: UserProfileViewModel = koinViewModel(),
    onBackClick: () -> Unit = {},
    onPostClick: (String) -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(userId) {
        viewModel.loadProfile(userId)
    }

    Scaffold { padding ->
        if (uiState.isLoading && uiState.user == null) {
            Box(
                modifier = Modifier.fillMaxSize().padding(padding),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .background(MaterialTheme.colorScheme.background),
                contentPadding = PaddingValues(bottom = 16.dp)
            ) {
                item {
                    UserProfileHeader(user = uiState.user, onBackClick = onBackClick)
                }

                item {
                    UserProfileStats(uiState = uiState)
                }

                item {
                    UserProfileActions(
                        userId = userId,
                        isFollowing = uiState.isFollowing,
                        isTogglingFollow = uiState.isTogglingFollow,
                        onToggleFollow = viewModel::toggleFollow
                    )
                }

                // Section title instead of tabs (Collection removed)
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .width(3.dp)
                                .height(20.dp)
                                .background(
                                    MaterialTheme.colorScheme.primary,
                                    RoundedCornerShape(2.dp)
                                )
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            "Videos",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            "(${uiState.posts.size})",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
                }

                // Grid of videos (chunked into rows of 3)
                val rows = uiState.posts.chunked(3)
                items(rows) { rowPosts ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 8.dp, vertical = 4.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        rowPosts.forEach { post ->
                            VideoThumbnail(
                                modifier = Modifier.weight(1f),
                                post = post,
                                onClick = {
                                    // Set SharedFeedState to user's posts only for vertical swiping
                                    setUserFeedState(uiState.posts, post.id)
                                    onPostClick(post.id)
                                }
                            )
                        }
                        // Filling empty spots if any
                        repeat(3 - rowPosts.size) {
                            Spacer(modifier = Modifier.weight(1f))
                        }
                    }
                }

                if (uiState.posts.isEmpty() && !uiState.isLoading) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(48.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(
                                    painterResource(Res.drawable.ic_play),
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.outlineVariant,
                                    modifier = Modifier.size(48.dp)
                                )
                                Spacer(modifier = Modifier.height(12.dp))
                                Text(
                                    "No videos shared yet.",
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    style = MaterialTheme.typography.bodyMedium
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 * Sets up SharedFeedState with user's posts so the PostScreen's VerticalPager
 * only shows this user's videos when swiping up/down.
 */
private fun setUserFeedState(posts: List<PostDto>, tappedPostId: String) {
    val exploreItems = posts.map { post ->
        ExploreItemDto(
            id = post.id,
            assetVersionId = post.assetVersionId,
            title = post.caption ?: "Untitled",
            topic = null,
            isTrending = false,
            score = 0.0f,
            createdAt = post.createdAt,
            postId = post.id,
            assetVersion = post.assetVersion,
            post = post
        )
    }
    SharedFeedState.updateState(exploreItems, null, null)
    SharedFeedState.onLoadMore = null // No pagination for user profiles
}

@Composable
fun UserProfileHeader(user: UserPublicDto?, onBackClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp)
        ) {
            // Gradient Banner
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(140.dp)
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(MaterialTheme.colorScheme.primary, MaterialTheme.colorScheme.secondary)
                        )
                    )
            )
            
            // Back Button
            IconButton(
                onClick = onBackClick,
                modifier = Modifier
                    .align(Alignment.TopStart)
                    .padding(top = 48.dp, start = 16.dp)
                    .background(Color.White.copy(alpha = 0.2f), CircleShape)
                    .size(36.dp)
            ) {
                Icon(
                    painterResource(Res.drawable.ic_close),
                    contentDescription = "Back",
                    tint = Color.White,
                    modifier = Modifier.size(20.dp)
                )
            }

            // Avatar
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .size(110.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.surface)
                    .padding(4.dp)
            ) {
                val usernameStr = user?.username ?: "U"
                val avatarUrl = user?.avatarUrl ?: "https://ui-avatars.com/api/?name=$usernameStr&background=random"
                
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.surfaceVariant),
                    contentAlignment = Alignment.Center
                ) {
                    AsyncImage(
                        model = avatarUrl,
                        contentDescription = null,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                }
                
                // PRO Badge
                Surface(
                    color = MaterialTheme.colorScheme.primary,
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .offset(x = (-4).dp, y = (-4).dp)
                ) {
                    Text(
                        "PRO",
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp),
                        style = MaterialTheme.typography.labelSmall,
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 8.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = user?.username ?: "Alex Rivera",
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = "@${user?.username?.lowercase() ?: "alex_vision"}",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.Medium
        )

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = user?.bio ?: "AI Artist exploring the future of cinematography. 🎬",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurface,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 32.dp)
        )
    }
}

@Composable
fun UserProfileStats(uiState: ie.app.neuragen.ui.userprofile.UserProfileUiState) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(24.dp),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically
    ) {
        UserStatItem(label = "Posts", value = uiState.posts.size.toString())
        VerticalDivider(modifier = Modifier.height(24.dp), color = MaterialTheme.colorScheme.outline)
        UserStatItem(label = "Followers", value = uiState.followersCount.toString())
        VerticalDivider(modifier = Modifier.height(24.dp), color = MaterialTheme.colorScheme.outline)
        UserStatItem(label = "Following", value = uiState.followingCount.toString())
    }
}

@Composable
fun UserStatItem(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onBackground)
        Text(label, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
fun UserProfileActions(
    userId: String,
    isFollowing: Boolean = false,
    isTogglingFollow: Boolean = false,
    onToggleFollow: () -> Unit = {}
) {
    val clipboardManager = androidx.compose.ui.platform.LocalClipboardManager.current
    val uriHandler = androidx.compose.ui.platform.LocalUriHandler.current

    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    
    val buttonScale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "followButtonScale"
    )

    val targetColor = if (isFollowing) MaterialTheme.colorScheme.surfaceVariant else MaterialTheme.colorScheme.primary
    val buttonColor by animateColorAsState(targetValue = targetColor, label = "followButtonColor")

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Button(
            onClick = onToggleFollow,
            interactionSource = interactionSource,
            modifier = Modifier
                .weight(1f)
                .height(48.dp)
                .graphicsLayer {
                    scaleX = buttonScale
                    scaleY = buttonScale
                }
                .clip(RoundedCornerShape(12.dp))
                .background(buttonColor),
            colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
            enabled = !isTogglingFollow
        ) {
            if (isTogglingFollow) {
                CircularProgressIndicator(
                    modifier = Modifier.size(18.dp),
                    color = if (isFollowing) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onPrimary,
                    strokeWidth = 2.dp
                )
            } else {
                Text(
                    if (isFollowing) "Following" else "Follow",
                    fontWeight = FontWeight.Bold,
                    color = if (isFollowing) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onPrimary
                )
            }
        }

        IconButton(
            onClick = {
                clipboardManager.setText(AnnotatedString("https://neuragen.app/user/${userId}"))
            },
            modifier = Modifier
                .size(48.dp)
                .border(1.dp, MaterialTheme.colorScheme.outline, RoundedCornerShape(12.dp))
        ) {
            Icon(
                painterResource(Res.drawable.ic_share),
                contentDescription = "Share",
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(20.dp)
            )
        }

        IconButton(
            onClick = {
                try {
                    uriHandler.openUri("mailto:?subject=Check out this Neura Gen profile&body=https://neuragen.app/user/${userId}")
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            },
            modifier = Modifier
                .size(48.dp)
                .border(1.dp, MaterialTheme.colorScheme.outline, RoundedCornerShape(12.dp))
        ) {
            Icon(
                painterResource(Res.drawable.ic_mail),
                contentDescription = "Mail",
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

@Composable
fun VideoThumbnail(modifier: Modifier = Modifier, post: PostDto, onClick: () -> Unit = {}) {
    Box(
        modifier = modifier
            .aspectRatio(0.7f)
            .clip(RoundedCornerShape(12.dp))
            .background(Color.Black)
            .clickable(onClick = onClick)
    ) {
        // Load actual thumbnail image
        val thumbnailUrl = post.thumbnailUrl ?: post.videoUrl ?: post.assetVersion?.fileUrl
        if (!thumbnailUrl.isNullOrBlank()) {
            AsyncImage(
                model = thumbnailUrl,
                contentDescription = post.caption,
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
        }

        // Gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.6f))
                    )
                )
        )
        
        Icon(
            painterResource(Res.drawable.ic_play),
            contentDescription = null,
            tint = Color.White,
            modifier = Modifier
                .align(Alignment.Center)
                .size(32.dp)
        )
        
        Surface(
            color = Color.White.copy(alpha = 0.2f),
            shape = RoundedCornerShape(8.dp),
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(8.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
            ) {
                Icon(
                    painterResource(Res.drawable.ic_play),
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(10.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = formatViewCount(post.viewCount),
                    color = Color.White,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

private fun formatViewCount(count: Int): String {
    return when {
        count >= 1_000_000 -> "${((count / 1_000_000.0 * 10).toInt() / 10.0)}M"
        count >= 1_000 -> "${((count / 1_000.0 * 10).toInt() / 10.0)}k"
        else -> count.toString()
    }
}
