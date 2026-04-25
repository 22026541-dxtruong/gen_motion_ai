package ie.app.neuragen.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation3.runtime.NavKey
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.ui.NavDisplay
import androidx.savedstate.serialization.SavedStateConfiguration
import ie.app.neuragen.ui.auth.LoginScreen
import ie.app.neuragen.ui.auth.RegisterScreen
import ie.app.neuragen.ui.auth.SplashScreen
import ie.app.neuragen.ui.billing.BillingScreen
import ie.app.neuragen.ui.create.CreateScreen
import ie.app.neuragen.ui.explore.ExploreScreen
import ie.app.neuragen.ui.post.PostScreen
import ie.app.neuragen.ui.profile.ProfileScreen

import ie.app.neuragen.ui.userprofile.UserProfileScreen
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.modules.SerializersModule
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
data object Explore : AppRoute


@Serializable
data object Create : AppRoute

@Serializable
data object Profile : AppRoute

@Serializable
data object Billing : AppRoute

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
                NeuraGenTopBar()
            }
        },
        floatingActionButton = {
            if (currentDestination is Explore) {
                ExploreFAB()
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
                    ProfileScreen()
                }

                entry<Billing> {
                    BillingScreen()
                }

                entry<PostDetail> { route ->
                    PostScreen(
                        postId = route.id.toString(),
                        onBackClick = { backStack.removeLastOrNull() }
                    )
                }

                entry<UserProfile> { route ->
                    UserProfileScreen(
                        userId = route.id.toString(),
                        onBackClick = { backStack.removeLastOrNull() }
                    )
                }

            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NeuraGenTopBar() {
    TopAppBar(
        title = {
            Text(
                "Neura Gen",
                style = MaterialTheme.typography.titleLarge,
                color = Color(0xFF4F46E5),
                fontWeight = FontWeight.Bold
            )
        },
        actions = {
            IconButton(onClick = {}) {
                Icon(
                    painterResource(Res.drawable.ic_notifications),
                    contentDescription = "Notifications",
                    tint = Color(0xFF6B7280)
                )
            }
            IconButton(onClick = {}) {
                Icon(
                    painterResource(Res.drawable.ic_billing),
                    contentDescription = "Billing",
                    tint = Color(0xFF6B7280)
                )
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = Color.White
        )
    )
}

@Composable
fun NeuraGenBottomBar(
    currentDestination: AppRoute?,
    onNavigate: (AppRoute) -> Unit,
) {

    NavigationBar(
        containerColor = Color.White,
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
                            .background(if (isSelected) Color(0xFFF3F2FF) else Color.Transparent),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            painterResource(item.icon),
                            contentDescription = item.label,
                            tint = if (isSelected) Color(0xFF4F46E5) else Color(0xFF9CA3AF),
                            modifier = Modifier.size(24.dp)
                        )
                    }
                },
                label = {
                    Text(
                        item.label,
                        style = MaterialTheme.typography.labelSmall,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        color = if (isSelected) Color(0xFF4F46E5) else Color(0xFF9CA3AF),
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
fun ExploreFAB() {
    FloatingActionButton(
        onClick = {},
        containerColor = Color(0xFF4F46E5),
        contentColor = Color.White,
        shape = CircleShape,
        modifier = Modifier.padding(bottom = 16.dp)
    ) {
        Icon(
            painterResource(Res.drawable.iic_film),
            contentDescription = "Create",
            modifier = Modifier.size(24.dp)
        )
    }
}

data class BottomNavItem(
    val label: String,
    val icon: DrawableResource,
    val route: AppRoute
)
