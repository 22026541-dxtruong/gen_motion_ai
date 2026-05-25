package ie.app.neuragen.ui.navigation

import androidx.compose.material3.MaterialTheme

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.DpOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.layout.ContentScale
import coil3.compose.AsyncImage
import org.koin.compose.viewmodel.koinViewModel
import ie.app.neuragen.data.network.model.AuthResponse
import androidx.navigation3.runtime.NavKey
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.ui.NavDisplay
import androidx.savedstate.serialization.SavedStateConfiguration
import ie.app.neuragen.ui.auth.LoginScreen
import ie.app.neuragen.ui.auth.RegisterScreen
import ie.app.neuragen.ui.auth.ForgotPasswordScreen
import ie.app.neuragen.ui.auth.SplashScreen
import ie.app.neuragen.ui.billing.BillingScreen
import ie.app.neuragen.ui.create.CreateScreen
import ie.app.neuragen.ui.explore.ExploreScreen
import ie.app.neuragen.ui.post.PostScreen
import ie.app.neuragen.ui.profile.ProfileScreen
import ie.app.neuragen.ui.help.HelpScreen

import ie.app.neuragen.ui.userprofile.UserProfileScreen
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.modules.SerializersModule
import androidx.compose.material.icons.rounded.SupportAgent
import kotlinx.serialization.modules.polymorphic
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.DrawableResource
import org.jetbrains.compose.resources.painterResource
import kotlin.uuid.ExperimentalUuidApi
import kotlin.uuid.Uuid


@Serializable
sealed interface AppRoute : NavKey

@Serializable
data object Splash : AppRoute

@Serializable
data object Login : AppRoute

@Serializable
data object Register : AppRoute

@Serializable
data object ForgotPassword : AppRoute

@Serializable
data object Explore : AppRoute


@Serializable
data object Create : AppRoute

@Serializable
data object Profile : AppRoute

@Serializable
data object Billing : AppRoute

@Serializable
data object Help : AppRoute

@Serializable
data class PostDetail @OptIn(ExperimentalUuidApi::class) constructor(val id: Uuid) : AppRoute

@Serializable
data class UserProfile @OptIn(ExperimentalUuidApi::class) constructor(val id: Uuid) : AppRoute

@OptIn(ExperimentalSerializationApi::class)
private val config = SavedStateConfiguration {
    serializersModule = SerializersModule {
        polymorphic(NavKey::class) {
            subclassesOfSealed<AppRoute>()
        }
    }
}

@OptIn(ExperimentalUuidApi::class, ExperimentalMaterial3Api::class)
@Composable
fun AppNav(modifier: Modifier = Modifier) {

    val backStack = rememberNavBackStack(config, Splash)
    val currentDestination = backStack.lastOrNull()

    val isMainScreen = (currentDestination is Explore ||
            currentDestination is Create ||
            currentDestination is Profile ||
            currentDestination is Billing)

    Scaffold(
        modifier = modifier,
        topBar = {
            if (isMainScreen) {
                NeuraGenTopBar(
                    onLogout = {
                        backStack.clear()
                        backStack.add(Login)
                    },
                    onNavigateToHelp = {
                        backStack.add(Help)
                    }
                )
            }
        },
        bottomBar = {
            if (isMainScreen) {
                NeuraGenBottomBar(currentDestination = currentDestination) { route ->
                    if (currentDestination != route) {
                        backStack.add(route)
                    }
                }
            }
        }
    )
 { innerPadding ->
        NavDisplay(
            modifier = Modifier.fillMaxSize().padding(innerPadding),
            backStack = backStack,
            onBack = { backStack.removeLastOrNull() },
            entryProvider = entryProvider {
                entry<Splash> {
                    SplashScreen(
                        onAuthenticated = {
                            backStack.clear()
                            backStack.add(Explore)
                        },
                        onNotAuthenticated = {
                            backStack.clear()
                            backStack.add(Login)
                        }
                    )
                }
                entry<Login> {
                    LoginScreen(
                        onLoginSuccess = {
                            backStack.clear()
                            backStack.add(Explore)
                        },
                        onRegisterClick = {
                            backStack.add(Register)
                        },
                        onForgotPasswordClick = {
                            backStack.add(ForgotPassword)
                        }
                    )
                }
                entry<ForgotPassword> {
                    ForgotPasswordScreen(
                        onBackToLogin = {
                            backStack.removeLastOrNull()
                        }
                    )
                }
                entry<Register> {
                    RegisterScreen(
                        onRegisterSuccess = {
                            backStack.clear()
                            backStack.add(Explore)
                        },
                        onLoginClick = {
                            backStack.removeLastOrNull()
                        }
                    )
                }
                entry<Explore> {
                    ExploreScreen(
                        onPostClick = { id -> backStack.add(PostDetail(Uuid.parse(id))) }
                    ) { id ->
                        backStack.add(UserProfile(Uuid.parse(id)))
                    }
                }
                entry<Create> {
                    CreateScreen()
                }

                entry<Profile> {
                    ProfileScreen(
                        onNavigateToBilling = { backStack.add(Billing) }
                    )
                }

                entry<Billing> {
                    BillingScreen()
                }

                entry<Help> {
                    HelpScreen(onBackClick = { backStack.removeLastOrNull() })
                }

                entry<PostDetail> { route ->
                    PostScreen(
                        postId = route.id.toString(),
                        onBackClick = { backStack.removeLastOrNull() },
                        onUserClick = { userId ->
                            backStack.add(UserProfile(Uuid.parse(userId)))
                        }
                    )
                }

                entry<UserProfile> { route ->
                    UserProfileScreen(
                        userId = route.id.toString(),
                        onBackClick = { backStack.removeLastOrNull() },
                        onPostClick = { id -> backStack.add(PostDetail(Uuid.parse(id))) }
                    )
                }

            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NeuraGenTopBar(
    viewModel: NavigationViewModel = koinViewModel(),
    onLogout: () -> Unit,
    onNavigateToHelp: () -> Unit = {}
) {
    val sessionStatus by viewModel.sessionStatus.collectAsState()
    val session = (sessionStatus as? SessionStatus.Authenticated)?.response
    val userProfile by viewModel.userProfile.collectAsState()
    val notifications by viewModel.notifications.collectAsState()
    var expanded by remember { mutableStateOf(false) }

    LaunchedEffect(sessionStatus) {
        if (sessionStatus is SessionStatus.Anonymous) {
            onLogout()
        }
    }

    if (viewModel.showLogoutConfirm) {
        LogoutConfirmationDialog(
            onConfirm = { viewModel.logout() },
            onDismiss = { viewModel.showLogoutConfirm = false }
        )
    }

    if (viewModel.showChangePassword) {
        ChangePasswordDialog(
            error = viewModel.changePasswordError,
            isLoading = viewModel.isChangingPassword,
            onConfirm = { old, new -> viewModel.changePassword(old, new) },
            onDismiss = { viewModel.showChangePassword = false }
        )
    }

    if (viewModel.showSwitchAccount) {
        SwitchAccountDialog(
            error = viewModel.switchAccountError,
            isLoading = viewModel.isSwitchingAccount,
            onConfirm = { email, password -> viewModel.switchAccount(email, password) },
            onDismiss = { viewModel.showSwitchAccount = false }
        )
    }

    TopAppBar(
        title = {
            Text(
                "Neura Gen",
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold
            )
        },
        actions = {
            ie.app.neuragen.ui.common.NotificationBell(
                notifications = notifications,
                onMarkAllAsRead = { viewModel.markAllNotificationsAsRead() },
                onMarkAsRead = { viewModel.markNotificationAsRead(it) },
                onRemove = { viewModel.removeNotification(it) },
                onClearAll = { viewModel.clearNotifications() }
            )
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 8.dp)
            ) {
                Icon(
                    painterResource(Res.drawable.ic_credit_card),
                    contentDescription = "Credits",
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = userProfile?.credits?.balance?.toString() ?: "0",
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Medium,
                    fontSize = 14.sp
                )
            }
            Box {
                IconButton(onClick = { expanded = true }) {
                    val usernameStr = userProfile?.username ?: session?.username ?: "U"
                    val avatarUrl = userProfile?.avatarUrl 
                        ?: "https://ui-avatars.com/api/?name=$usernameStr&background=e0e7ff&color=4f46e5"
                    
                    AsyncImage(
                        model = avatarUrl,
                        contentDescription = "Avatar",
                        modifier = Modifier.size(28.dp).clip(CircleShape),
                        contentScale = ContentScale.Crop
                    )
                }
                DropdownMenu(
                    expanded = expanded,
                    onDismissRequest = { expanded = false },
                    offset = DpOffset(0.dp, 8.dp),
                    shape = RoundedCornerShape(16.dp),
                    containerColor = MaterialTheme.colorScheme.surface
                ) {
                    // Header: User Info
                    Column(
                        modifier = Modifier
                            .padding(horizontal = 16.dp, vertical = 12.dp)
                            .fillMaxWidth()
                    ) {
                        Text(
                            session?.username ?: "Guest",
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 16.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Text(
                            session?.email ?: "",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            fontSize = 12.sp
                        )
                    }
                    HorizontalDivider(
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                        color = MaterialTheme.colorScheme.surfaceVariant
                    )
                    // Change Password
                    DropdownMenuItem(
                        text = { Text("Change Password", fontSize = 14.sp) },
                        leadingIcon = {
                            Icon(
                                painterResource(Res.drawable.ic_change_password),
                                contentDescription = null,
                                modifier = Modifier.size(18.dp),
                                tint = Color(0xFF4B5563)
                            )
                        },
                        onClick = {
                            expanded = false
                            viewModel.showChangePassword = true
                        },
                        modifier = Modifier.height(48.dp)
                    )
                    // Help
                    DropdownMenuItem(
                        text = { Text("Help & Support", fontSize = 14.sp) },
                        leadingIcon = {
                            Icon(
                                androidx.compose.material.icons.Icons.Rounded.SupportAgent,
                                contentDescription = null,
                                modifier = Modifier.size(18.dp),
                                tint = Color(0xFF4B5563)
                            )
                        },
                        onClick = {
                            expanded = false
                            onNavigateToHelp()
                        },
                        modifier = Modifier.height(48.dp)
                    )
                    // Switch Account
                    DropdownMenuItem(
                        text = { Text("Switch Account", fontSize = 14.sp) },
                        leadingIcon = {
                            Icon(
                                painterResource(Res.drawable.ic_switch_account),
                                contentDescription = null,
                                modifier = Modifier.size(18.dp),
                                tint = Color(0xFF4B5563)
                            )
                        },
                        onClick = {
                            expanded = false
                            viewModel.showSwitchAccount = true
                        },
                        modifier = Modifier.height(48.dp)
                    )
                    HorizontalDivider(
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                        color = MaterialTheme.colorScheme.surfaceVariant
                    )
                    // Logout
                    DropdownMenuItem(
                        text = {
                            Text(
                                "Logout",
                                color = MaterialTheme.colorScheme.error,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        },
                        leadingIcon = {
                            Icon(
                                painterResource(Res.drawable.ic_logout),
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.error,
                                modifier = Modifier.size(18.dp)
                            )
                        },
                        onClick = {
                            expanded = false
                            viewModel.showLogoutConfirm = true
                        },
                        modifier = Modifier.height(48.dp)
                    )
                }
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    )
}

@Composable
fun NeuraGenBottomBar(
    currentDestination: AppRoute?,
    onNavigate: (AppRoute) -> Unit,
) {

    NavigationBar(
        containerColor = MaterialTheme.colorScheme.surface,
        tonalElevation = 8.dp
    ) {
        val items = listOf(
            BottomNavItem("EXPLORE", Res.drawable.ic_explore, Explore),
            BottomNavItem("CREATE", Res.drawable.ic_create, Create),
            BottomNavItem("PROFILE", Res.drawable.ic_profile, Profile),
            BottomNavItem("BILLING", Res.drawable.ic_billing, Billing)
        )

        items.forEach { item ->
            val isSelected = currentDestination == item.route
            NavigationBarItem(
                selected = isSelected,
                onClick = { onNavigate(item.route) },
                icon = {
                    Box(
                        modifier = Modifier
                            .size(if (isSelected) 48.dp else 24.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(if (isSelected) MaterialTheme.colorScheme.surfaceVariant else Color.Transparent),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            painterResource(item.icon),
                            contentDescription = item.label,
                            tint = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                },
                label = {
                    Text(
                        item.label,
                        style = MaterialTheme.typography.labelSmall,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant,
                        fontSize = 10.sp
                    )
                },
                colors = NavigationBarItemDefaults.colors(
                    indicatorColor = Color.Transparent
                )
            )
        }
    }
}


@Composable
fun LogoutConfirmationDialog(onConfirm: () -> Unit, onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Log out of your account?") },
        text = { Text("Are you sure you want to log out? You will need to sign in again to access your Neura Gen workspace.") },
        confirmButton = {
            Button(
                onClick = onConfirm,
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
            ) {
                Text("Logout")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel", color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        },
        containerColor = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(16.dp)
    )
}

@Composable
fun ChangePasswordDialog(
    error: String?,
    isLoading: Boolean,
    onConfirm: (String, String) -> Unit,
    onDismiss: () -> Unit
) {
    var oldPassword by remember { mutableStateOf("") }
    var newPassword by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Change Password", fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("Enter your current password and a new one to update your security.", fontSize = 14.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                OutlinedTextField(
                    value = oldPassword,
                    onValueChange = { oldPassword = it },
                    label = { Text("Old Password") },
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(8.dp)
                )
                OutlinedTextField(
                    value = newPassword,
                    onValueChange = { newPassword = it },
                    label = { Text("New Password") },
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(8.dp)
                )
                if (error != null) {
                    Text(error, color = MaterialTheme.colorScheme.error, fontSize = 12.sp)
                }
            }
        },
        confirmButton = {
            Button(
                onClick = { onConfirm(oldPassword, newPassword) },
                enabled = !isLoading && oldPassword.isNotBlank() && newPassword.isNotBlank(),
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(modifier = Modifier.size(18.dp), color = MaterialTheme.colorScheme.onPrimary, strokeWidth = 2.dp)
                } else {
                    Text("Update Password")
                }
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
        containerColor = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(16.dp)
    )
}

@Composable
fun SwitchAccountDialog(
    error: String?,
    isLoading: Boolean,
    onConfirm: (String, String) -> Unit,
    onDismiss: () -> Unit
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Switch Account", fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("Log in with a different account. Successful login will replace your current session.", fontSize = 14.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                OutlinedTextField(
                    value = email,
                    onValueChange = { email = it },
                    label = { Text("Email Address") },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(8.dp)
                )
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Password") },
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(8.dp)
                )
                if (error != null) {
                    Text(error, color = MaterialTheme.colorScheme.error, fontSize = 12.sp)
                }
            }
        },
        confirmButton = {
            Button(
                onClick = { onConfirm(email, password) },
                enabled = !isLoading && email.isNotBlank() && password.isNotBlank(),
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(modifier = Modifier.size(18.dp), color = MaterialTheme.colorScheme.onPrimary, strokeWidth = 2.dp)
                } else {
                    Text("Sign In")
                }
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
        containerColor = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(16.dp)
    )
}

data class BottomNavItem(
    val label: String,
    val icon: DrawableResource,
    val route: AppRoute
)
