package ie.app.neuragen.ui.userprofile

import androidx.compose.material3.MaterialTheme

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
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
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.AnnotatedString
import coil3.compose.AsyncImage
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.network.model.UserPublicDto
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun UserProfileScreen(
    userId: String,
    viewModel: UserProfileViewModel = koinViewModel(),
    onBackClick: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(userId) {
        viewModel.loadProfile(userId)
    }

    Scaffold { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(Color.White),
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

            item {
                UserProfileTabs(
                    selectedIndex = uiState.selectedTab,
                    onTabSelected = viewModel::onTabSelected
                )
            }

            // Grid of videos
            // Chunking posts into rows of 3
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
                            post = post
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
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("No videos shared yet.", color = Color.Gray)
                    }
                }
            }
        }
    }
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
                    .background(Color.White)
                    .padding(4.dp)
            ) {
                val usernameStr = user?.username ?: "U"
                val avatarUrl = user?.avatarUrl ?: "https://ui-avatars.com/api/?name=$usernameStr&background=random"
                
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(CircleShape)
                        .background(Color.LightGray),
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
            color = Color.DarkGray,
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
        Text(label, style = MaterialTheme.typography.bodySmall, color = Color.Gray)
    }
}

@Composable
fun UserProfileActions(
    userId: String,
    isFollowing: Boolean = false,
    isTogglingFollow: Boolean = false,
    onToggleFollow: () -> Unit = {}
) {
    val clipboardManager = LocalClipboardManager.current
    val uriHandler = LocalUriHandler.current

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Button(
            onClick = onToggleFollow,
            modifier = Modifier
                .weight(1f)
                .height(48.dp)
                .clip(RoundedCornerShape(12.dp))
                .then(
                    if (!isFollowing) Modifier.background(
                        Brush.horizontalGradient(
                            colors = listOf(MaterialTheme.colorScheme.primary, MaterialTheme.colorScheme.secondary)
                        )
                    ) else Modifier.background(MaterialTheme.colorScheme.surfaceVariant)
                ),
            colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
            enabled = !isTogglingFollow
        ) {
            if (isTogglingFollow) {
                CircularProgressIndicator(
                    modifier = Modifier.size(18.dp),
                    color = if (isFollowing) MaterialTheme.colorScheme.primary else Color.White,
                    strokeWidth = 2.dp
                )
            } else {
                Text(
                    if (isFollowing) "Following" else "Follow",
                    fontWeight = FontWeight.Bold,
                    color = if (isFollowing) MaterialTheme.colorScheme.primary else Color.White
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
                tint = Color.Gray,
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
                tint = Color.Gray,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

@Composable
fun UserProfileTabs(selectedIndex: Int, onTabSelected: (Int) -> Unit) {
    TabRow(
        selectedTabIndex = selectedIndex,
        containerColor = Color.Transparent,
        contentColor = MaterialTheme.colorScheme.primary,
        indicator = { tabPositions ->
            if (selectedIndex < tabPositions.size) {
                TabRowDefaults.SecondaryIndicator(
                    Modifier.tabIndicatorOffset(tabPositions[selectedIndex]),
                    color = MaterialTheme.colorScheme.primary,
                    height = 2.dp
                )
            }
        },
        divider = {
            HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
        }
    ) {
        Tab(
            selected = selectedIndex == 0,
            onClick = { onTabSelected(0) },
            text = { Text("Videos", style = MaterialTheme.typography.labelLarge) }
        )
        Tab(
            selected = selectedIndex == 1,
            onClick = { onTabSelected(1) },
            text = { Text("Collections", style = MaterialTheme.typography.labelLarge) }
        )
    }
}

@Composable
fun VideoThumbnail(modifier: Modifier = Modifier, post: PostDto) {
    Box(
        modifier = modifier
            .aspectRatio(0.7f)
            .clip(RoundedCornerShape(12.dp))
            .background(Color.Black)
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
                    text = "${(post.viewCount / 1000f)}k", // Simple formatting
                    color = Color.White,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
