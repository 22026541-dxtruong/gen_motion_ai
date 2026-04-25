package ie.app.neuragen.ui.profile

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


import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
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
import ie.app.neuragen.data.network.model.PostDto
import ie.app.neuragen.data.network.model.UserMeDto
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel = koinViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Box(Modifier.fillMaxSize()) {
        LazyColumn(
            modifier = Modifier.fillMaxSize().background(Color(0xFFF8F9FF)),
            contentPadding = PaddingValues(bottom = 16.dp)
        ) {
            item {
                ProfileHeader(
                    user = uiState.user,
                    onEditClick = viewModel::onEditProfileClick
                )
            }

            item {
                UserStatsSection(
                    user = uiState.user,
                    onFollowersClick = viewModel::onFollowersClick
                )
            }

            item {
                BioSection(user = uiState.user)
            }

            item {
                CreditBalanceCard(user = uiState.user)
            }

            item {
                ProfileTabs(
                    selectedIndex = uiState.selectedTab,
                    onTabSelected = viewModel::onTabSelected
                )
            }

            if (uiState.posts.isEmpty() && !uiState.isLoading) {
                item {
                    Box(Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) {
                        Text("No posts yet.", color = Color.Gray)
                    }
                }
            } else {
                items(uiState.posts) { post ->
                    ProfilePostItem(post = post)
                }
            }
        }

        if (uiState.isEditProfileOpen) {
            EditProfileDialog(
                username = uiState.editUsername,
                onUsernameChange = viewModel::onEditUsernameChange,
                bio = uiState.editBio,
                onBioChange = viewModel::onEditBioChange,
                onClose = viewModel::onCloseDialogs,
                onSave = viewModel::onSaveProfile,
                isUpdating = uiState.isUpdating
            )
        }

        if (uiState.isFollowersOpen) {
            FollowersDialog(
                followers = uiState.followers,
                onClose = viewModel::onCloseDialogs,
                onToggleFollow = viewModel::onToggleFollow
            )
        }
    }
}

@Composable
fun ProfileHeader(
    user: UserMeDto?,
    onEditClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp)
    ) {
        // Banner Placeholder
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(160.dp)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color(0xFF6366F1), Color(0xFFA855F7).copy(alpha = 0.5f))
                    )
                )
        )

        // Avatar
        Box(
            modifier = Modifier
                .padding(start = 24.dp)
                .align(Alignment.BottomStart)
                .size(100.dp)
                .clip(RoundedCornerShape(24.dp))
                .background(Color.White)
                .border(4.dp, Color.White, RoundedCornerShape(24.dp))
        ) {
            // Placeholder for AsyncImage
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.LightGray),
                contentAlignment = Alignment.Center
            ) {
                Icon(painterResource(Res.drawable.ic_profile), contentDescription = null, modifier = Modifier.size(48.dp), tint = Color.Gray)
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 12.dp)
    ) {
        Text(
            text = user?.username ?: "Alex Rivera",
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF0D1B3E)
        )
        Text(
            text = "@${user?.username?.lowercase() ?: "erivera_vision"} • Senior AI Prompt Engineer",
            style = MaterialTheme.typography.bodySmall,
            color = Color.Gray
        )

        Spacer(modifier = Modifier.height(16.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Button(
                onClick = onEditClick,
                modifier = Modifier.weight(1f).height(44.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4F46E5))
            ) {
                Text("Edit Profile", fontWeight = FontWeight.Bold)
            }
            IconButton(
                onClick = {},
                modifier = Modifier
                    .size(44.dp)
                    .border(1.dp, Color(0xFFE5E7EB), RoundedCornerShape(12.dp))
            ) {
                Icon(painterResource(Res.drawable.ic_share), contentDescription = "Share", tint = Color.Gray, modifier = Modifier.size(20.dp))
            }
        }
    }
}

@Composable
fun UserStatsSection(
    user: UserMeDto?,
    onFollowersClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        StatItem(
            modifier = Modifier.weight(1f).clickable(onClick = onFollowersClick),
            label = "FOLLOWERS",
            value = user?.counts?.followers?.toString() ?: "12.8k",
            isHighlighted = true
        )
        StatItem(modifier = Modifier.weight(1f), label = "FOLLOWING", value = user?.counts?.following?.toString() ?: "432")
    }
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        StatItem(modifier = Modifier.weight(1f), label = "POSTS", value = user?.counts?.posts?.toString() ?: "156")
        StatItem(modifier = Modifier.weight(1f), label = "JOBS", value = user?.counts?.jobs?.toString() ?: "24", valueColor = Color(0xFFA855F7))
    }
}


@Composable
fun StatItem(
    modifier: Modifier = Modifier,
    label: String,
    value: String,
    isHighlighted: Boolean = false,
    valueColor: Color = if (isHighlighted) Color(0xFF4F46E5) else Color(0xFF0D1B3E)
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.Start
        ) {
            Text(label, style = MaterialTheme.typography.labelSmall, color = Color.Gray, fontSize = 10.sp)
            Text(value, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold, color = valueColor)
        }
    }
}

@Composable
fun BioSection(user: UserMeDto?) {
    Text(
        text = user?.bio ?: "Pushing the boundaries of generative storytelling. Focused on cinematic realism and futuristic architecture. Open for collaborations on high-end commercial AI video projects. ✨",
        style = MaterialTheme.typography.bodyMedium,
        color = Color.DarkGray,
        modifier = Modifier.padding(horizontal = 24.dp, vertical = 16.dp)
    )
}

@Composable
fun CreditBalanceCard(user: UserMeDto?) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 8.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Surface(
                modifier = Modifier.size(40.dp),
                shape = RoundedCornerShape(12.dp),
                color = Color(0xFF4F46E5)
            ) {
                Icon(
                    painterResource(Res.drawable.ic_billing),
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.padding(8.dp)
                )
            }
            Spacer(modifier = Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text("CREDIT BALANCE", style = MaterialTheme.typography.labelSmall, color = Color.Gray, fontSize = 9.sp)
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(user?.credits?.balance?.toString() ?: "1,240", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                    Text(" / 2,000 this month", style = MaterialTheme.typography.bodySmall, color = Color.Gray, modifier = Modifier.padding(bottom = 2.dp, start = 4.dp))
                }
            }
            Button(
                onClick = {},
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFEEF2FF), contentColor = Color(0xFF4F46E5)),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)
            ) {
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
        contentColor = Color(0xFF4F46E5),
        indicator = { tabPositions ->
            if (selectedIndex < tabPositions.size) {
                TabRowDefaults.SecondaryIndicator(
                    Modifier.tabIndicatorOffset(tabPositions[selectedIndex]),
                    color = Color(0xFF4F46E5),
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
fun ProfilePostItem(post: PostDto) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 12.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp)
            ) {
                // Image Placeholder
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.LightGray)
                )
                
                Surface(
                    color = Color.Black.copy(alpha = 0.5f),
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier.align(Alignment.BottomEnd).padding(8.dp)
                ) {
                    Text("0:15", color = Color.White, modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp), fontSize = 10.sp)
                }
            }

            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        post.caption ?: "Neon Dreams: Tokyo 2077",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )
                    Icon(painterResource(Res.drawable.ic_search), contentDescription = null, tint = Color.Gray, modifier = Modifier.size(20.dp))
                }

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(painterResource(Res.drawable.ic_play), contentDescription = null, modifier = Modifier.size(14.dp), tint = Color.Gray)
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(post.viewCount.toString(), style = MaterialTheme.typography.bodySmall, color = Color.Gray)
                        Spacer(modifier = Modifier.width(12.dp))
                        Icon(painterResource(Res.drawable.ic_like), contentDescription = null, modifier = Modifier.size(14.dp), tint = Color.Gray)
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(post.likeCount.toString(), style = MaterialTheme.typography.bodySmall, color = Color.Gray)
                    }

                    Surface(
                        color = Color(0xFFF3F2FF),
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Text(
                            "CYBERPUNK",
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                            style = MaterialTheme.typography.labelSmall,
                            color = Color(0xFF4F46E5),
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileDialog(
    username: String,
    onUsernameChange: (String) -> Unit,
    bio: String,
    onBioChange: (String) -> Unit,
    onClose: () -> Unit,
    onSave: () -> Unit,
    isUpdating: Boolean
) {
    BasicAlertDialog(
        onDismissRequest = onClose,
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
            .clip(RoundedCornerShape(24.dp))
            .background(Color.White)
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Edit Profile", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onClose) {
                    Icon(painter = painterResource(Res.drawable.ic_close), contentDescription = "Close")
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.fillMaxWidth()) {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(Color.LightGray),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(painterResource(Res.drawable.ic_profile), contentDescription = null, modifier = Modifier.size(40.dp), tint = Color.Gray)
                }
                TextButton(onClick = {}) {
                    Text("Change Photo", color = Color(0xFF4F46E5), fontWeight = FontWeight.Bold)
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text("Username", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(
                value = username,
                onValueChange = onUsernameChange,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(unfocusedBorderColor = Color(0xFFE5E7EB))
            )

            Spacer(modifier = Modifier.height(20.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("Bio", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
                Text("${bio.length}/150", style = MaterialTheme.typography.labelSmall, color = Color.Gray)
            }
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(
                value = bio,
                onValueChange = { if (it.length <= 150) onBioChange(it) },
                modifier = Modifier.fillMaxWidth().height(100.dp),
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(unfocusedBorderColor = Color(0xFFE5E7EB))
            )

            Spacer(modifier = Modifier.height(32.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedButton(
                    onClick = onClose,
                    modifier = Modifier.weight(1f).height(48.dp),
                    shape = RoundedCornerShape(24.dp),
                    border = BorderStroke(1.dp, Color(0xFFE5E7EB))
                ) {
                    Text("Cancel", color = Color.Gray)
                }
                Button(
                    onClick = onSave,
                    modifier = Modifier.weight(1f).height(48.dp),
                    shape = RoundedCornerShape(24.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4F46E5)),
                    enabled = !isUpdating
                ) {
                    if (isUpdating) {
                        CircularProgressIndicator(modifier = Modifier.size(20.dp), color = Color.White, strokeWidth = 2.dp)
                    } else {
                        Text("Save Changes", fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FollowersDialog(
    followers: List<ie.app.neuragen.data.network.model.FollowDto>,
    onClose: () -> Unit,
    onToggleFollow: (String) -> Unit
) {
    BasicAlertDialog(
        onDismissRequest = onClose,
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
            .clip(RoundedCornerShape(24.dp))
            .background(Color.White)
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Followers", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onClose) {
                    Icon(painterResource(Res.drawable.ic_close), contentDescription = "Close")
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            LazyColumn(modifier = Modifier.heightIn(max = 400.dp)) {
                items(followers) { follow ->
                    FollowerItem(
                        follow = follow,
                        onToggleClick = { onToggleFollow(follow.followerId) }
                    )
                }
                if (followers.isEmpty()) {
                    item {
                        Box(Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) {
                            Text("No followers yet.", color = Color.Gray)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun FollowerItem(
    follow: ie.app.neuragen.data.network.model.FollowDto,
    onToggleClick: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier.size(44.dp).clip(CircleShape).background(Color.LightGray),
            contentAlignment = Alignment.Center
        ) {
            Icon(painterResource(Res.drawable.ic_profile), contentDescription = null, modifier = Modifier.size(24.dp), tint = Color.Gray)
        }
        Spacer(modifier = Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(follow.follower?.username ?: "User", fontWeight = FontWeight.Bold, style = MaterialTheme.typography.bodyMedium)
            Text("@${follow.follower?.username?.lowercase() ?: "user"}", style = MaterialTheme.typography.bodySmall, color = Color.Gray)
        }
        Button(
            onClick = onToggleClick,
            shape = RoundedCornerShape(20.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF3F4F6), contentColor = Color.DarkGray),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp),
            modifier = Modifier.height(32.dp)
        ) {
            Text("Following", fontSize = 12.sp, fontWeight = FontWeight.Medium)
        }
    }
}
