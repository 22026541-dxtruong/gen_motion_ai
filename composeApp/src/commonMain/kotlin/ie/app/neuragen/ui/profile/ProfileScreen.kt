package ie.app.neuragen.ui.profile

import androidx.compose.material3.MaterialTheme
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.draw.scale
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.Spring
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.PlayArrow
import ie.app.neuragen.data.network.model.UserMeDto
import ie.app.neuragen.ui.common.rememberFileBytesLoader
import ie.app.neuragen.ui.common.rememberImagePickerLauncher
import ie.app.neuragen.util.UserSessionState
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel = koinViewModel(),
    onNavigateToBilling: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()
    val gallery = if (uiState.selectedTab == 0) uiState.publicGallery else uiState.privateGallery

    // Observe shared session for real-time avatar/credit updates (from Topbar singleton)
    val sharedUser by UserSessionState.user.collectAsState()

    // Refresh profile when screen regains focus (e.g., returning from billing)
    LaunchedEffect(Unit) {
        viewModel.loadProfile()
    }

    Box(Modifier.fillMaxSize()) {
        if (uiState.isLoading && uiState.user == null) {
            CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background),
                contentPadding = PaddingValues(bottom = 16.dp)
            ) {
                item { ProfileHeader(user = sharedUser ?: uiState.user, onEditClick = viewModel::onEditProfileClick) }
                item { UserStatsSection(user = sharedUser ?: uiState.user, onFollowersClick = viewModel::onFollowersClick, onFollowingsClick = viewModel::onFollowingsClick) }
                item { BioSection(user = sharedUser ?: uiState.user) }
                item { CreditBalanceCard(user = sharedUser ?: uiState.user, onBuyCredits = onNavigateToBilling) }
                item { ProfileTabs(selectedIndex = uiState.selectedTab, onTabSelected = viewModel::onTabSelected) }

                if (gallery.isEmpty()) {
                    item {
                        Box(Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) {
                            Text(
                                if (uiState.selectedTab == 0) "No items found in public gallery." else "No items found in private workspace.",
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                } else {
                    items(gallery, key = { it.id }) { item ->
                        ProfileGalleryCard(
                            item = item,
                            onPublish = { viewModel.onPublishClick(it) },
                            onEdit = { viewModel.onEditPostClick(it) },
                            onDelete = { viewModel.onDeletePost(it.id) }
                        )
                    }
                }
            }
        }

        // Edit Profile Dialog
        if (uiState.isEditProfileOpen) {
            EditProfileDialog(
                user = uiState.user,
                username = uiState.editUsername,
                onUsernameChange = viewModel::onEditUsernameChange,
                bio = uiState.editBio,
                onBioChange = viewModel::onEditBioChange,
                onClose = viewModel::onCloseDialogs,
                onSave = viewModel::onSaveProfile,
                isUpdating = uiState.isUpdating,
                avatarPreview = uiState.avatarPreview,
                isUploadingAvatar = uiState.isUploadingAvatar,
                onAvatarUpload = viewModel::onAvatarUpload
            )
        }
        // Followers Dialog
        if (uiState.isFollowersOpen) {
            FollowsDialog(title = "Followers", follows = uiState.followers, onClose = viewModel::onCloseDialogs, onToggleFollow = viewModel::onToggleFollow, isFollower = true)
        }
        // Followings Dialog
        if (uiState.isFollowingsOpen) {
            FollowsDialog(title = "Following", follows = uiState.followings, onClose = viewModel::onCloseDialogs, onToggleFollow = viewModel::onToggleFollow, isFollower = false)
        }
        // Edit Post Dialog
        if (uiState.editingPost != null) {
            EditPostDialog(caption = uiState.editPostCaption, onCaptionChange = viewModel::onEditPostCaptionChange, onSave = viewModel::onSavePostEdit, onClose = viewModel::onCloseDialogs, isSaving = uiState.isSavingPostEdit)
        }
        // Publish Dialog
        if (uiState.publishingItem != null) {
            PublishDialog(caption = uiState.publishCaption, onCaptionChange = viewModel::onPublishCaptionChange, onPublish = viewModel::onConfirmPublish, onClose = viewModel::onCloseDialogs, isPublishing = uiState.isPublishing)
        }
    }
}

@Composable
fun ProfileHeader(user: UserMeDto?, onEditClick: () -> Unit) {
    Box(modifier = Modifier.fillMaxWidth().height(220.dp)) {
        Box(
            modifier = Modifier.fillMaxWidth().height(180.dp)
                .background(Brush.verticalGradient(
                    colors = listOf(
                        MaterialTheme.colorScheme.primary,
                        Color(0xFF38BDF8) // Vibrant Blue
                    )
                ))
        )
        Box(
            modifier = Modifier
                .padding(start = 24.dp)
                .align(Alignment.BottomStart)
                .size(110.dp)
                .shadow(12.dp, RoundedCornerShape(32.dp), spotColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.5f))
                .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(32.dp))
                .border(4.dp, MaterialTheme.colorScheme.surface, RoundedCornerShape(32.dp))
                .clip(RoundedCornerShape(28.dp))
        ) {
            val avatarUrl = user?.avatarUrl ?: "https://ui-avatars.com/api/?name=${user?.username ?: "U"}&background=e0e7ff&color=4f46e5"
            AsyncImage(model = avatarUrl, contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
        }
    }
    Column(modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 16.dp)) {
        Text(text = user?.username ?: "Unknown User", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onBackground)
        Text(text = "@${user?.username?.lowercase() ?: "unknown"} • Creator", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(modifier = Modifier.height(20.dp))
        OutlinedButton(
            onClick = onEditClick,
            modifier = Modifier.fillMaxWidth().height(48.dp),
            shape = RoundedCornerShape(16.dp),
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline)
        ) { Text("Edit Profile", fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.onSurface) }
    }
}

@Composable
fun UserStatsSection(user: UserMeDto?, onFollowersClick: () -> Unit, onFollowingsClick: () -> Unit) {
    Row(Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 8.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        StatItem(Modifier.weight(1f).clickable(onClick = onFollowersClick), "FOLLOWERS", (user?.counts?.followers ?: 0).toString(), isHighlighted = true)
        StatItem(Modifier.weight(1f).clickable(onClick = onFollowingsClick), "FOLLOWING", (user?.counts?.following ?: 0).toString())
    }
    Row(Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 8.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        StatItem(Modifier.weight(1f), "POSTS", (user?.counts?.posts ?: 0).toString())
        StatItem(Modifier.weight(1f), "JOBS", (user?.counts?.jobs ?: 0).toString(), valueColor = MaterialTheme.colorScheme.secondary)
    }
}

@Composable
fun StatItem(modifier: Modifier = Modifier, label: String, value: String, isHighlighted: Boolean = false, valueColor: Color = if (isHighlighted) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onBackground) {
    Box(
        modifier = modifier
            .shadow(
                elevation = 8.dp,
                shape = RoundedCornerShape(20.dp),
                spotColor = Color.Black.copy(alpha = 0.08f)
            )
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(20.dp))
            .border(1.dp, MaterialTheme.colorScheme.surfaceVariant, RoundedCornerShape(20.dp))
    ) {
        Column(Modifier.padding(16.dp), horizontalAlignment = Alignment.Start) {
            Text(label, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 10.sp, fontWeight = FontWeight.SemiBold)
            Spacer(Modifier.height(4.dp))
            Text(value, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold, color = valueColor)
        }
    }
}

@Composable
fun BioSection(user: UserMeDto?) {
    Text(
        text = user?.bio ?: "No bio yet. Update your profile to add one! ✨",
        style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurface,
        modifier = Modifier.padding(horizontal = 24.dp, vertical = 16.dp)
    )
}

@Composable
fun CreditBalanceCard(user: UserMeDto?, onBuyCredits: () -> Unit = {}) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 12.dp)
            .shadow(
                elevation = 12.dp,
                shape = RoundedCornerShape(24.dp),
                spotColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.6f)
            )
            .background(
                brush = Brush.linearGradient(
                    colors = listOf(
                        Color(0xFF4F46E5), // Indigo 600
                        Color(0xFFA855F7)  // Purple 500
                    )
                ),
                shape = RoundedCornerShape(24.dp)
            )
            .clickable { onBuyCredits() }
    ) {
        Row(
            Modifier.padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Surface(
                Modifier.size(48.dp),
                shape = RoundedCornerShape(16.dp),
                color = Color.White.copy(alpha = 0.2f)
            ) {
                Icon(
                    painterResource(Res.drawable.ic_billing),
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.padding(12.dp)
                )
            }
            Spacer(Modifier.width(16.dp))
            Column(Modifier.weight(1f)) {
                Text("CREDIT BALANCE", style = MaterialTheme.typography.labelSmall, color = Color.White.copy(alpha = 0.8f), fontSize = 10.sp, fontWeight = FontWeight.Medium)
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        (user?.credits?.balance ?: 0).toString(),
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        " Available",
                        style = MaterialTheme.typography.bodySmall,
                        color = Color.White.copy(alpha = 0.8f),
                        modifier = Modifier.padding(bottom = 6.dp, start = 4.dp)
                    )
                }
            }
            Button(
                onClick = onBuyCredits,
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                    contentColor = Color(0xFF4F46E5)
                ),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                modifier = Modifier.height(40.dp)
            ) {
                Text("Get More", fontWeight = FontWeight.Bold, fontSize = 13.sp)
            }
        }
    }
}

@Composable
fun ProfileTabs(selectedIndex: Int, onTabSelected: (Int) -> Unit) {
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
        divider = {}
    ) {
        Tab(
            selected = selectedIndex == 0,
            onClick = { onTabSelected(0) },
            text = {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(painterResource(Res.drawable.ic_explore), contentDescription = null, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Public Gallery", style = MaterialTheme.typography.labelLarge, fontWeight = if (selectedIndex == 0) FontWeight.Bold else FontWeight.Normal)
                }
            }
        )
        Tab(
            selected = selectedIndex == 1,
            onClick = { onTabSelected(1) },
            text = {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(painterResource(Res.drawable.ic_passworld), contentDescription = null, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Private Workspace", style = MaterialTheme.typography.labelLarge, fontWeight = if (selectedIndex == 1) FontWeight.Bold else FontWeight.Normal)
                }
            }
        )
    }
}

@Composable
fun ProfileGalleryCard(
    item: GalleryItem,
    onPublish: (GalleryItem) -> Unit,
    onEdit: (GalleryItem) -> Unit,
    onDelete: (GalleryItem) -> Unit
) {
    var menuExpanded by remember { mutableStateOf(false) }
    val mediaUrl = item.thumbnailUrl ?: item.mediaUrl

    fun formatDuration(ms: Int): String {
        if (ms <= 0) return "0:00"
        val totalSec = ms / 1000
        val m = totalSec / 60
        val s = totalSec % 60
        return "$m:${s.toString().padStart(2, '0')}"
    }

    fun formatCount(n: Int): String {
        return when {
            n >= 1_000_000 -> "${((n / 1_000_000.0 * 10).toInt() / 10.0)}M"
            n >= 1_000 -> "${((n / 1_000.0 * 10).toInt() / 10.0)}k"
            else -> n.toString()
        }
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 10.dp)
            .shadow(12.dp, RoundedCornerShape(28.dp), spotColor = Color.Black.copy(alpha = 0.08f)),
        shape = RoundedCornerShape(28.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp) // Handled by shadow
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            // ── Thumbnail ──
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp)
                    .background(Color.DarkGray)
            ) {
                if (mediaUrl != null) {
                    AsyncImage(
                        model = mediaUrl,
                        contentDescription = item.title,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Box(
                        Modifier.fillMaxSize().background(MaterialTheme.colorScheme.surfaceVariant),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.PlayArrow,
                            contentDescription = null,
                            tint = Color.White.copy(alpha = 0.5f),
                            modifier = Modifier.size(48.dp)
                        )
                    }
                }

                // Duration badge
                if (item.durationMs > 0) {
                    Surface(
                        color = Color.Black.copy(alpha = 0.7f),
                        shape = RoundedCornerShape(6.dp),
                        modifier = Modifier
                            .align(Alignment.BottomEnd)
                            .padding(12.dp)
                    ) {
                        Text(
                            formatDuration(item.durationMs),
                            color = Color.White,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                            style = MaterialTheme.typography.labelSmall,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                // Visibility badge
                Surface(
                    color = if (item.isPublic) MaterialTheme.colorScheme.primary.copy(alpha = 0.9f)
                    else Color.Black.copy(alpha = 0.6f),
                    shape = RoundedCornerShape(6.dp),
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(12.dp)
                ) {
                    Text(
                        if (item.isPublic) "PUBLIC" else "PRIVATE",
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelSmall,
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            // ── Content ──
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp)
            ) {
                // Title + View count
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Top
                ) {
                    Text(
                        item.title,
                        style = MaterialTheme.typography.titleLarge,
                        color = MaterialTheme.colorScheme.onSurface,
                        fontWeight = FontWeight.Bold,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f).padding(end = 8.dp)
                    )
                    if (item.isPublic) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier
                                .background(
                                    MaterialTheme.colorScheme.surfaceVariant,
                                    RoundedCornerShape(6.dp)
                                )
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Visibility,
                                contentDescription = "Views",
                                modifier = Modifier.size(14.dp),
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                formatCount(item.viewCount),
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Stats + Actions row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Like count
                    if (item.isPublic && !item.isJob) {
                        var isLiked by remember { mutableStateOf(false) }
                        val heartScale by animateFloatAsState(
                            targetValue = if (isLiked) 1.3f else 1f,
                            animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessLow)
                        )
                        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier
                                    .clip(RoundedCornerShape(8.dp))
                                    .clickable { isLiked = !isLiked }
                                    .padding(4.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Favorite,
                                    contentDescription = "Likes",
                                    modifier = Modifier.size(20.dp).scale(heartScale),
                                    tint = if (isLiked) Color.Red else Color.Red.copy(alpha = 0.7f)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    formatCount(item.likeCount + if (isLiked) 1 else 0),
                                    style = MaterialTheme.typography.labelMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    } else {
                        Spacer(Modifier.width(1.dp))
                    }

                    // Action buttons
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        if (!item.isPublic || item.isJob) {
                            Button(
                                onClick = { onPublish(item) },
                                shape = RoundedCornerShape(12.dp),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = MaterialTheme.colorScheme.primary,
                                    contentColor = Color.White
                                ),
                                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                                modifier = Modifier.height(34.dp)
                            ) {
                                Text("Publish", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                            }
                        }

                        if (!item.isJob) {
                            Box {
                                IconButton(
                                    onClick = { menuExpanded = true },
                                    modifier = Modifier.size(34.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.MoreVert,
                                        contentDescription = "Menu",
                                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                                DropdownMenu(
                                    expanded = menuExpanded,
                                    onDismissRequest = { menuExpanded = false },
                                    shape = RoundedCornerShape(12.dp),
                                    containerColor = MaterialTheme.colorScheme.surface
                                ) {
                                    DropdownMenuItem(
                                        text = { Text("Edit") },
                                        onClick = { menuExpanded = false; onEdit(item) }
                                    )
                                    DropdownMenuItem(
                                        text = { Text("Delete", color = MaterialTheme.colorScheme.error) },
                                        onClick = { menuExpanded = false; onDelete(item) }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// ─── Edit Profile Dialog ──────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileDialog(user: UserMeDto?, username: String, onUsernameChange: (String) -> Unit, bio: String, onBioChange: (String) -> Unit, onClose: () -> Unit, onSave: () -> Unit, isUpdating: Boolean, avatarPreview: String?, isUploadingAvatar: Boolean, onAvatarUpload: (ByteArray, String) -> Unit) {
    val loadFileBytes = rememberFileBytesLoader()
    // Local preview — shows immediately after picking (matches web's URL.createObjectURL)
    var localPreviewUri by remember { mutableStateOf<String?>(null) }

    val launchPicker = rememberImagePickerLauncher { uri ->
        if (uri != null) {
            // Show local preview immediately
            localPreviewUri = uri
            // Store bytes for deferred upload on Save (no upload yet!)
            val bytes = loadFileBytes(uri)
            if (bytes != null) onAvatarUpload(bytes, "avatar.jpg")
        }
    }

    BasicAlertDialog(onDismissRequest = onClose, modifier = Modifier.fillMaxWidth().padding(16.dp).clip(RoundedCornerShape(24.dp)).background(MaterialTheme.colorScheme.surface)) {
        Column(Modifier.padding(24.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text("Edit Profile", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onClose) { Icon(painterResource(Res.drawable.ic_close), contentDescription = "Close") }
            }
            Spacer(Modifier.height(24.dp))
            Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.fillMaxWidth()) {
                // Priority: local file preview → current server avatar → fallback placeholder
                val displayAvatar = localPreviewUri ?: user?.avatarUrl ?: "https://ui-avatars.com/api/?name=${username.ifBlank { "U" }}&background=e0e7ff&color=4f46e5"
                Box(Modifier.size(80.dp).clip(CircleShape).background(MaterialTheme.colorScheme.surfaceVariant), contentAlignment = Alignment.Center) {
                    AsyncImage(model = displayAvatar, contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
                    if (isUploadingAvatar) CircularProgressIndicator(Modifier.size(28.dp), color = MaterialTheme.colorScheme.primary, strokeWidth = 2.dp)
                }
                TextButton(onClick = { launchPicker() }, enabled = !isUpdating) {
                    Text("Change Photo", color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                }
            }
            Spacer(Modifier.height(24.dp))
            Text("Username", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(value = username, onValueChange = onUsernameChange, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp), colors = OutlinedTextFieldDefaults.colors(unfocusedBorderColor = MaterialTheme.colorScheme.outline))
            Spacer(Modifier.height(20.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("Bio", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
                Text("${bio.length}/150", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(value = bio, onValueChange = { if (it.length <= 150) onBioChange(it) }, modifier = Modifier.fillMaxWidth().height(100.dp), shape = RoundedCornerShape(12.dp), colors = OutlinedTextFieldDefaults.colors(unfocusedBorderColor = MaterialTheme.colorScheme.outline))
            Spacer(Modifier.height(32.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedButton(onClick = onClose, modifier = Modifier.weight(1f).height(48.dp), shape = RoundedCornerShape(24.dp), border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline)) { Text("Cancel", color = MaterialTheme.colorScheme.onSurfaceVariant) }
                Button(onClick = onSave, modifier = Modifier.weight(1f).height(48.dp), shape = RoundedCornerShape(24.dp), colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary), enabled = !isUpdating) {
                    if (isUpdating) CircularProgressIndicator(Modifier.size(20.dp), color = MaterialTheme.colorScheme.onPrimary, strokeWidth = 2.dp) else Text("Save", fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

// ─── Unified Follows Dialog (Followers / Following) ──────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FollowsDialog(title: String, follows: List<ie.app.neuragen.data.network.model.FollowDto>, onClose: () -> Unit, onToggleFollow: (String) -> Unit, isFollower: Boolean) {
    BasicAlertDialog(onDismissRequest = onClose, modifier = Modifier.fillMaxWidth().padding(16.dp).clip(RoundedCornerShape(24.dp)).background(MaterialTheme.colorScheme.surface)) {
        Column(Modifier.padding(24.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text(title, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onClose) { Icon(painterResource(Res.drawable.ic_close), contentDescription = "Close") }
            }
            Spacer(Modifier.height(16.dp))
            LazyColumn(Modifier.heightIn(max = 400.dp)) {
                items(follows) { follow ->
                    val user = if (isFollower) follow.follower else follow.following
                    val userId = if (isFollower) follow.followerId else follow.followingId
                    FollowItem(user = user, onToggleClick = { userId?.let { onToggleFollow(it) } })
                }
                if (follows.isEmpty()) {
                    item { Box(Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) { Text("No $title yet.", color = MaterialTheme.colorScheme.onSurfaceVariant) } }
                }
            }
        }
    }
}

@Composable
fun FollowItem(user: ie.app.neuragen.data.network.model.UserPublicDto?, onToggleClick: () -> Unit) {
    Row(Modifier.fillMaxWidth().padding(vertical = 12.dp), verticalAlignment = Alignment.CenterVertically) {
        val name = user?.username ?: "User"
        val avatarUrl = user?.avatarUrl ?: "https://ui-avatars.com/api/?name=$name&background=random"
        Box(Modifier.size(44.dp).clip(CircleShape).background(MaterialTheme.colorScheme.surfaceVariant), contentAlignment = Alignment.Center) {
            AsyncImage(model = avatarUrl, contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(name, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.bodyMedium)
            Text("@${name.lowercase()}", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        Button(onClick = onToggleClick, shape = RoundedCornerShape(20.dp), colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.surfaceVariant, contentColor = MaterialTheme.colorScheme.onSurfaceVariant), contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp), modifier = Modifier.height(32.dp)) {
            Text("Following", fontSize = 12.sp, fontWeight = FontWeight.Medium)
        }
    }
}

// ─── Edit Post Dialog ────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditPostDialog(caption: String, onCaptionChange: (String) -> Unit, onSave: () -> Unit, onClose: () -> Unit, isSaving: Boolean) {
    BasicAlertDialog(onDismissRequest = onClose, modifier = Modifier.fillMaxWidth().padding(16.dp).clip(RoundedCornerShape(24.dp)).background(MaterialTheme.colorScheme.surface)) {
        Column(Modifier.padding(24.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text("Edit Post", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onClose) { Icon(painterResource(Res.drawable.ic_close), contentDescription = "Close") }
            }
            Spacer(Modifier.height(16.dp))
            Text("Caption", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(value = caption, onValueChange = onCaptionChange, modifier = Modifier.fillMaxWidth().height(120.dp), shape = RoundedCornerShape(12.dp), placeholder = { Text("Write a caption...") })
            Spacer(Modifier.height(24.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedButton(onClick = onClose, modifier = Modifier.weight(1f).height(48.dp), shape = RoundedCornerShape(24.dp)) { Text("Cancel") }
                Button(onClick = onSave, modifier = Modifier.weight(1f).height(48.dp), shape = RoundedCornerShape(24.dp), enabled = !isSaving) {
                    if (isSaving) CircularProgressIndicator(Modifier.size(20.dp), color = MaterialTheme.colorScheme.onPrimary, strokeWidth = 2.dp) else Text("Save", fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

// ─── Publish Dialog ──────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PublishDialog(caption: String, onCaptionChange: (String) -> Unit, onPublish: () -> Unit, onClose: () -> Unit, isPublishing: Boolean) {
    BasicAlertDialog(onDismissRequest = onClose, modifier = Modifier.fillMaxWidth().padding(16.dp).clip(RoundedCornerShape(24.dp)).background(MaterialTheme.colorScheme.surface)) {
        Column(Modifier.padding(24.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text("Publish Post", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onClose) { Icon(painterResource(Res.drawable.ic_close), contentDescription = "Close") }
            }
            Spacer(Modifier.height(16.dp))
            Text("Caption", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(value = caption, onValueChange = onCaptionChange, modifier = Modifier.fillMaxWidth().height(120.dp), shape = RoundedCornerShape(12.dp), placeholder = { Text("Add a caption for your post...") })
            Spacer(Modifier.height(24.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedButton(onClick = onClose, modifier = Modifier.weight(1f).height(48.dp), shape = RoundedCornerShape(24.dp)) { Text("Cancel") }
                Button(onClick = onPublish, modifier = Modifier.weight(1f).height(48.dp), shape = RoundedCornerShape(24.dp), enabled = !isPublishing) {
                    if (isPublishing) CircularProgressIndicator(Modifier.size(20.dp), color = MaterialTheme.colorScheme.onPrimary, strokeWidth = 2.dp) else Text("Publish", fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

