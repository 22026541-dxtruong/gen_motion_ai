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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
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
                                color = Color.Gray
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
    Box(modifier = Modifier.fillMaxWidth().height(200.dp)) {
        Box(
            modifier = Modifier.fillMaxWidth().height(160.dp)
                .background(Brush.verticalGradient(listOf(MaterialTheme.colorScheme.primary, MaterialTheme.colorScheme.secondary.copy(alpha = 0.5f))))
        )
        Box(
            modifier = Modifier.padding(start = 24.dp).align(Alignment.BottomStart).size(100.dp)
                .clip(RoundedCornerShape(24.dp)).background(Color.White).border(4.dp, Color.White, RoundedCornerShape(24.dp))
        ) {
            val avatarUrl = user?.avatarUrl ?: "https://ui-avatars.com/api/?name=${user?.username ?: "U"}&background=e0e7ff&color=4f46e5"
            AsyncImage(model = avatarUrl, contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
        }
    }
    Column(modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 12.dp)) {
        Text(text = user?.username ?: "Unknown User", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onBackground)
        Text(text = "@${user?.username?.lowercase() ?: "unknown"} • Creator", style = MaterialTheme.typography.bodySmall, color = Color.Gray)
        Spacer(modifier = Modifier.height(16.dp))
        Button(
            onClick = onEditClick,
            modifier = Modifier.fillMaxWidth().height(44.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
        ) { Text("Edit Profile", fontWeight = FontWeight.Bold) }
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
    Card(modifier = modifier, shape = RoundedCornerShape(16.dp), colors = CardDefaults.cardColors(containerColor = Color.White), elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)) {
        Column(Modifier.padding(12.dp), horizontalAlignment = Alignment.Start) {
            Text(label, style = MaterialTheme.typography.labelSmall, color = Color.Gray, fontSize = 10.sp)
            Text(value, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold, color = valueColor)
        }
    }
}

@Composable
fun BioSection(user: UserMeDto?) {
    Text(
        text = user?.bio ?: "No bio yet. Update your profile to add one! ✨",
        style = MaterialTheme.typography.bodyMedium, color = Color.DarkGray,
        modifier = Modifier.padding(horizontal = 24.dp, vertical = 16.dp)
    )
}

@Composable
fun CreditBalanceCard(user: UserMeDto?, onBuyCredits: () -> Unit = {}) {
    Card(Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 8.dp), shape = RoundedCornerShape(20.dp), colors = CardDefaults.cardColors(containerColor = Color.White), elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Surface(Modifier.size(40.dp), shape = RoundedCornerShape(12.dp), color = MaterialTheme.colorScheme.primary) {
                Icon(painterResource(Res.drawable.ic_billing), contentDescription = null, tint = Color.White, modifier = Modifier.padding(8.dp))
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text("CREDIT BALANCE", style = MaterialTheme.typography.labelSmall, color = Color.Gray, fontSize = 9.sp)
                Row(verticalAlignment = Alignment.Bottom) {
                    Text((user?.credits?.balance ?: 0).toString(), style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                    Text(" Available Credits", style = MaterialTheme.typography.bodySmall, color = Color.Gray, modifier = Modifier.padding(bottom = 2.dp, start = 4.dp))
                }
            }
            Button(onClick = onBuyCredits, shape = RoundedCornerShape(12.dp), colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primaryContainer, contentColor = MaterialTheme.colorScheme.primary), contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)) {
                Text("Buy Credits", fontWeight = FontWeight.Bold, fontSize = 12.sp)
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
fun ProfileGalleryCard(item: GalleryItem, onPublish: (GalleryItem) -> Unit, onEdit: (GalleryItem) -> Unit, onDelete: (GalleryItem) -> Unit) {
    var menuExpanded by remember { mutableStateOf(false) }
    val mediaUrl = item.thumbnailUrl ?: item.mediaUrl

    fun formatDuration(ms: Int): String {
        if (ms <= 0) return "0:00"
        val totalSec = ms / 1000; val m = totalSec / 60; val s = totalSec % 60
        return "$m:${s.toString().padStart(2, '0')}"
    }

    Card(Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 12.dp), shape = RoundedCornerShape(20.dp), colors = CardDefaults.cardColors(containerColor = Color.White), elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)) {
        Column {
            Box(Modifier.fillMaxWidth().height(180.dp)) {
                if (mediaUrl != null) {
                    AsyncImage(model = mediaUrl, contentDescription = item.title, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
                } else {
                    Box(Modifier.fillMaxSize().background(Color.LightGray))
                }
                Surface(color = Color.Black.copy(alpha = 0.5f), shape = RoundedCornerShape(8.dp), modifier = Modifier.align(Alignment.BottomEnd).padding(8.dp)) {
                    Text(formatDuration(item.durationMs), color = Color.White, modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp), fontSize = 10.sp)
                }
            }
            Column(Modifier.padding(16.dp)) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                    Text(item.title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
                    if (!item.isJob) {
                        Box {
                            IconButton(onClick = { menuExpanded = true }, modifier = Modifier.size(24.dp)) {
                                Icon(painterResource(Res.drawable.ic_search), contentDescription = "Menu", tint = Color.Gray, modifier = Modifier.size(18.dp))
                            }
                            DropdownMenu(expanded = menuExpanded, onDismissRequest = { menuExpanded = false }, shape = RoundedCornerShape(12.dp), containerColor = Color.White) {
                                DropdownMenuItem(text = { Text("Edit") }, onClick = { menuExpanded = false; onEdit(item) })
                                DropdownMenuItem(text = { Text("Delete", color = Color.Red) }, onClick = { menuExpanded = false; onDelete(item) })
                            }
                        }
                    }
                }
                Spacer(Modifier.height(8.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                    if (item.isPublic && !item.isJob) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(painterResource(Res.drawable.ic_play), contentDescription = null, modifier = Modifier.size(14.dp), tint = Color.Gray)
                            Spacer(Modifier.width(4.dp))
                            Text(item.viewCount.toString(), style = MaterialTheme.typography.bodySmall, color = Color.Gray)
                            Spacer(Modifier.width(12.dp))
                            Icon(painterResource(Res.drawable.ic_like), contentDescription = null, modifier = Modifier.size(14.dp), tint = Color.Gray)
                            Spacer(Modifier.width(4.dp))
                            Text(item.likeCount.toString(), style = MaterialTheme.typography.bodySmall, color = Color.Gray)
                        }
                    } else {
                        Surface(color = Color(0xFFF5F5F5), shape = RoundedCornerShape(8.dp)) {
                            Text("Private", modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp), style = MaterialTheme.typography.labelSmall, color = Color.Gray, fontWeight = FontWeight.Bold)
                        }
                    }
                    if (!item.isPublic || item.isJob) {
                        Button(onClick = { onPublish(item) }, shape = RoundedCornerShape(8.dp), colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFEEF2FF), contentColor = MaterialTheme.colorScheme.primary), contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp), modifier = Modifier.height(30.dp)) {
                            Text("Publish", fontSize = 12.sp, fontWeight = FontWeight.Bold)
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

    BasicAlertDialog(onDismissRequest = onClose, modifier = Modifier.fillMaxWidth().padding(16.dp).clip(RoundedCornerShape(24.dp)).background(Color.White)) {
        Column(Modifier.padding(24.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text("Edit Profile", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onClose) { Icon(painterResource(Res.drawable.ic_close), contentDescription = "Close") }
            }
            Spacer(Modifier.height(24.dp))
            Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.fillMaxWidth()) {
                // Priority: local file preview → current server avatar → fallback placeholder
                val displayAvatar = localPreviewUri ?: user?.avatarUrl ?: "https://ui-avatars.com/api/?name=${username.ifBlank { "U" }}&background=e0e7ff&color=4f46e5"
                Box(Modifier.size(80.dp).clip(CircleShape).background(Color.LightGray), contentAlignment = Alignment.Center) {
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
                Text("${bio.length}/150", style = MaterialTheme.typography.labelSmall, color = Color.Gray)
            }
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(value = bio, onValueChange = { if (it.length <= 150) onBioChange(it) }, modifier = Modifier.fillMaxWidth().height(100.dp), shape = RoundedCornerShape(12.dp), colors = OutlinedTextFieldDefaults.colors(unfocusedBorderColor = MaterialTheme.colorScheme.outline))
            Spacer(Modifier.height(32.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedButton(onClick = onClose, modifier = Modifier.weight(1f).height(48.dp), shape = RoundedCornerShape(24.dp), border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline)) { Text("Cancel", color = Color.Gray) }
                Button(onClick = onSave, modifier = Modifier.weight(1f).height(48.dp), shape = RoundedCornerShape(24.dp), colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary), enabled = !isUpdating) {
                    if (isUpdating) CircularProgressIndicator(Modifier.size(20.dp), color = Color.White, strokeWidth = 2.dp) else Text("Save", fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

// ─── Unified Follows Dialog (Followers / Following) ──────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FollowsDialog(title: String, follows: List<ie.app.neuragen.data.network.model.FollowDto>, onClose: () -> Unit, onToggleFollow: (String) -> Unit, isFollower: Boolean) {
    BasicAlertDialog(onDismissRequest = onClose, modifier = Modifier.fillMaxWidth().padding(16.dp).clip(RoundedCornerShape(24.dp)).background(Color.White)) {
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
                    item { Box(Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) { Text("No $title yet.", color = Color.Gray) } }
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
        Box(Modifier.size(44.dp).clip(CircleShape).background(Color.LightGray), contentAlignment = Alignment.Center) {
            AsyncImage(model = avatarUrl, contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(name, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.bodyMedium)
            Text("@${name.lowercase()}", style = MaterialTheme.typography.bodySmall, color = Color.Gray)
        }
        Button(onClick = onToggleClick, shape = RoundedCornerShape(20.dp), colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.surfaceVariant, contentColor = Color.DarkGray), contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp), modifier = Modifier.height(32.dp)) {
            Text("Following", fontSize = 12.sp, fontWeight = FontWeight.Medium)
        }
    }
}

// ─── Edit Post Dialog ────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditPostDialog(caption: String, onCaptionChange: (String) -> Unit, onSave: () -> Unit, onClose: () -> Unit, isSaving: Boolean) {
    BasicAlertDialog(onDismissRequest = onClose, modifier = Modifier.fillMaxWidth().padding(16.dp).clip(RoundedCornerShape(24.dp)).background(Color.White)) {
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
                    if (isSaving) CircularProgressIndicator(Modifier.size(20.dp), color = Color.White, strokeWidth = 2.dp) else Text("Save", fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

// ─── Publish Dialog ──────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PublishDialog(caption: String, onCaptionChange: (String) -> Unit, onPublish: () -> Unit, onClose: () -> Unit, isPublishing: Boolean) {
    BasicAlertDialog(onDismissRequest = onClose, modifier = Modifier.fillMaxWidth().padding(16.dp).clip(RoundedCornerShape(24.dp)).background(Color.White)) {
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
                    if (isPublishing) CircularProgressIndicator(Modifier.size(20.dp), color = Color.White, strokeWidth = 2.dp) else Text("Publish", fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

