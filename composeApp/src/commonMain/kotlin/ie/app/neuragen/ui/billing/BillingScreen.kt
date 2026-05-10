package ie.app.neuragen.ui.billing

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CreditCard
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material.icons.rounded.Receipt
import androidx.compose.material.icons.rounded.ShoppingCart
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ie.app.neuragen.data.network.model.CreditTopupPackageDto
import ie.app.neuragen.data.network.model.OrderResponse
import ie.app.neuragen.data.network.model.ProPlanDto
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.viewmodel.koinViewModel

// --- Colors ---
private val Indigo600 = Color(0xFF4F46E5)
private val Indigo500 = Color(0xFF635BFF)
private val Violet500 = Color(0xFF8B5CF6)
private val IndigoBg = Color(0xFFF0F0FF)
private val IndigoBgDark = Color(0xFFE0E7FF)
private val CardBg = Color.White
private val SlateText = Color(0xFF0F172A)
private val GrayText = Color(0xFF64748B)
private val LightGray = Color(0xFFF1F5F9)
private val GreenBg = Color(0xFFDCFCE7)
private val GreenText = Color(0xFF15803D)
private val AmberBg = Color(0xFFFEF3C7)
private val AmberText = Color(0xFF92400E)
private val RedBg = Color(0xFFFEE2E2)
private val RedText = Color(0xFFB91C1C)

@Composable
fun BillingScreen(
    viewModel: BillingViewModel = koinViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val uriHandler = LocalUriHandler.current

    // Open payment URL in browser
    LaunchedEffect(uiState.paymentUrl) {
        uiState.paymentUrl?.let { url ->
            uriHandler.openUri(url)
            viewModel.consumePaymentUrl()
        }
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(Color(0xFFF8F9FE)),
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Header
        item {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(top = 8.dp, bottom = 8.dp)
            ) {
                Text(
                    "Choose Your Plan",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold,
                    color = SlateText
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    "Elevate your creative potential with AI-powered video generation.",
                    style = MaterialTheme.typography.bodyMedium,
                    textAlign = TextAlign.Center,
                    color = GrayText
                )
            }
        }

        // Tab selector
        item {
            BillingTabSelector(
                activeTab = uiState.activeTab,
                onTabChange = viewModel::setTab
            )
        }

        // Error
        if (uiState.error != null) {
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = RedBg)
                ) {
                    Text(
                        uiState.error ?: "",
                        modifier = Modifier.padding(16.dp),
                        color = RedText,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
        }

        when (uiState.activeTab) {
            BillingTab.PLANS -> {
                // Loading
                if (uiState.isLoading) {
                    item {
                        Box(
                            modifier = Modifier.fillMaxWidth().height(200.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            CircularProgressIndicator(color = Indigo600)
                        }
                    }
                } else {
                    // Pro Plan Card
                    item {
                        ProPlanCard(
                            proPlan = uiState.proPlan,
                            isLoading = uiState.loadingOrderId == "PRO_SUBSCRIPTION",
                            onUpgradeClick = viewModel::upgradeToPro
                        )
                    }

                    // Credit Top-ups header
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.Bottom
                        ) {
                            Text(
                                "Credit Top-ups",
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.Bold,
                                color = SlateText
                            )
                            Text(
                                "No expiration",
                                style = MaterialTheme.typography.labelMedium,
                                color = GrayText
                            )
                        }
                    }

                    // Top-up packages
                    itemsIndexed(uiState.topupPackages) { index, pkg ->
                        TopupPackageCard(
                            pkg = pkg,
                            isBestValue = index == 1,
                            isLoading = uiState.loadingOrderId == pkg.code,
                            onBuyClick = { viewModel.buyPackage(pkg.code) }
                        )
                    }

                    // Secure payment footer
                    item {
                        PaymentMethodsFooter()
                    }
                }
            }

            BillingTab.ORDERS -> {
                item {
                    OrderHistorySection(
                        orders = uiState.orders,
                        isLoading = uiState.isLoadingOrders
                    )
                }
            }
        }
    }
}

@Composable
fun BillingTabSelector(activeTab: BillingTab, onTabChange: (BillingTab) -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Center
    ) {
        listOf(BillingTab.PLANS to "Plans & Credits", BillingTab.ORDERS to "My Orders").forEach { (tab, label) ->
            val isActive = activeTab == tab
            Button(
                onClick = { onTabChange(tab) },
                modifier = Modifier.padding(horizontal = 6.dp).height(40.dp),
                shape = CircleShape,
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (isActive) Indigo500 else CardBg,
                    contentColor = if (isActive) Color.White else GrayText
                ),
                elevation = ButtonDefaults.buttonElevation(
                    defaultElevation = if (isActive) 2.dp else 0.dp
                )
            ) {
                Text(label, fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
            }
        }
    }
}

@Composable
fun ProPlanCard(proPlan: ProPlanDto?, isLoading: Boolean, onUpgradeClick: () -> Unit) {
    val price = proPlan?.amountUsd ?: "14.99"
    val credits = proPlan?.credits ?: 1000

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = CardBg),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Box {
            Column(modifier = Modifier.padding(24.dp)) {
                Text(
                    "PREMIUM EXPERIENCE",
                    style = MaterialTheme.typography.labelSmall,
                    color = Indigo600,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    "Pro Monthly",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold,
                    color = SlateText
                )
                Spacer(modifier = Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        "$$price",
                        style = MaterialTheme.typography.headlineLarge,
                        fontWeight = FontWeight.Bold,
                        color = SlateText
                    )
                    Text(
                        " /month",
                        style = MaterialTheme.typography.bodyMedium,
                        color = GrayText,
                        modifier = Modifier.padding(bottom = 6.dp)
                    )
                }

                Spacer(modifier = Modifier.height(24.dp))

                ProFeatureRow("$credits Credits", "Reset every month")
                ProFeatureRow("High-Speed Processing", "Priority render queue")
                ProFeatureRow("Pro-only Presets", "Exclusive AI styles")
                ProFeatureRow("4K Upscaling", "Cinematic resolution")

                Spacer(modifier = Modifier.height(28.dp))

                Button(
                    onClick = onUpgradeClick,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Violet500),
                    enabled = !isLoading
                ) {
                    if (isLoading) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(22.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Text(
                            "Upgrade to Pro Monthly",
                            fontWeight = FontWeight.Bold,
                            fontSize = 15.sp
                        )
                    }
                }
            }

            // Badge
            Surface(
                modifier = Modifier.align(Alignment.TopEnd),
                color = Indigo500,
                shape = RoundedCornerShape(bottomStart = 16.dp, topEnd = 24.dp)
            ) {
                Text(
                    "MOST POPULAR",
                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.labelSmall,
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp
                )
            }
        }
    }
}

@Composable
private fun ProFeatureRow(title: String, subtitle: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 8.dp)
    ) {
        Surface(
            modifier = Modifier.size(40.dp),
            shape = RoundedCornerShape(12.dp),
            color = IndigoBg
        ) {
            Box(contentAlignment = Alignment.Center) {
                Icon(
                    painterResource(Res.drawable.ic_billing),
                    contentDescription = null,
                    tint = Indigo600,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
        Spacer(modifier = Modifier.width(14.dp))
        Column {
            Text(
                title,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.SemiBold,
                color = SlateText
            )
            Text(
                subtitle,
                style = MaterialTheme.typography.bodySmall,
                color = GrayText
            )
        }
    }
}

@Composable
fun TopupPackageCard(
    pkg: CreditTopupPackageDto,
    isBestValue: Boolean,
    isLoading: Boolean,
    onBuyClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .then(
                if (isBestValue) Modifier.border(
                    2.dp, Indigo600, RoundedCornerShape(24.dp)
                ) else Modifier
            ),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = CardBg),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (isBestValue) 6.dp else 2.dp
        )
    ) {
        Box {
            Column(modifier = Modifier.padding(20.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Top
                ) {
                    Surface(
                        modifier = Modifier.size(44.dp),
                        shape = RoundedCornerShape(14.dp),
                        color = if (isBestValue) IndigoBgDark else LightGray
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Icon(
                                painterResource(Res.drawable.ic_billing),
                                contentDescription = null,
                                tint = if (isBestValue) Indigo600 else GrayText,
                                modifier = Modifier.size(22.dp)
                            )
                        }
                    }
                    Text(
                        "$${pkg.amountUsd}",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = SlateText
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    pkg.label,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = SlateText
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    "${pkg.credits} Credits for your creative projects",
                    style = MaterialTheme.typography.bodySmall,
                    color = GrayText
                )

                Spacer(modifier = Modifier.height(20.dp))

                if (isBestValue) {
                    Button(
                        onClick = onBuyClick,
                        modifier = Modifier.fillMaxWidth().height(48.dp),
                        shape = RoundedCornerShape(12.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = Indigo600),
                        enabled = !isLoading
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(20.dp),
                                color = Color.White,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Text("Buy Credits", fontWeight = FontWeight.Bold)
                        }
                    }
                } else {
                    OutlinedButton(
                        onClick = onBuyClick,
                        modifier = Modifier.fillMaxWidth().height(48.dp),
                        shape = RoundedCornerShape(12.dp),
                        enabled = !isLoading
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(20.dp),
                                color = Indigo600,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Text(
                                "Buy Credits",
                                fontWeight = FontWeight.Bold,
                                color = SlateText
                            )
                        }
                    }
                }
            }

            // Best Value badge
            if (isBestValue) {
                Surface(
                    modifier = Modifier.align(Alignment.TopCenter).offset(y = (-1).dp),
                    color = Indigo600,
                    shape = RoundedCornerShape(bottomStart = 8.dp, bottomEnd = 8.dp)
                ) {
                    Text(
                        "BEST VALUE",
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelSmall,
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 10.sp,
                        letterSpacing = 1.sp
                    )
                }
            }
        }
    }
}

@Composable
fun OrderHistorySection(orders: List<OrderResponse>, isLoading: Boolean) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = CardBg),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column {
            // Header
            Text(
                "Order History",
                modifier = Modifier.padding(20.dp),
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = SlateText
            )
            HorizontalDivider(color = LightGray)

            if (isLoading) {
                Box(
                    modifier = Modifier.fillMaxWidth().height(160.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = Indigo600)
                }
            } else if (orders.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxWidth().height(160.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Rounded.Receipt,
                            contentDescription = null,
                            modifier = Modifier.size(40.dp),
                            tint = GrayText.copy(alpha = 0.4f)
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            "You haven't made any purchases yet.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = GrayText
                        )
                    }
                }
            } else {
                orders.forEachIndexed { index, order ->
                    OrderRow(order)
                    if (index < orders.lastIndex) {
                        HorizontalDivider(color = LightGray)
                    }
                }
            }
        }
    }
}

@Composable
fun OrderRow(order: OrderResponse) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.Top
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                if (order.type == "PRO_SUBSCRIPTION") "Pro Monthly Subscription" else "Credit Top-up",
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.SemiBold,
                color = SlateText
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                formatDate(order.createdAt),
                style = MaterialTheme.typography.bodySmall,
                color = GrayText
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                "#${order.id.take(8)}...",
                style = MaterialTheme.typography.labelSmall,
                color = GrayText.copy(alpha = 0.6f),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }

        Column(horizontalAlignment = Alignment.End) {
            Text(
                "$${order.amountUsd}",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = SlateText
            )
            Spacer(modifier = Modifier.height(6.dp))
            OrderStatusChip(order.status)
        }
    }
}

@Composable
fun OrderStatusChip(status: String) {
    val (bg, text) = when (status) {
        "PAID" -> GreenBg to GreenText
        "PENDING" -> AmberBg to AmberText
        "CANCELLED", "EXPIRED" -> RedBg to RedText
        else -> LightGray to GrayText
    }
    Surface(
        shape = CircleShape,
        color = bg
    ) {
        Text(
            status,
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 3.dp),
            style = MaterialTheme.typography.labelSmall,
            fontWeight = FontWeight.Bold,
            color = text,
            fontSize = 10.sp
        )
    }
}

@Composable
fun PaymentMethodsFooter() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFFF8FAFC))
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                "SECURE PAYMENT METHODS",
                style = MaterialTheme.typography.labelSmall,
                color = GrayText,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.5.sp
            )
            Spacer(modifier = Modifier.height(20.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                PaymentMethodItem(Icons.Rounded.CreditCard, "Bank Transfer")
                PaymentMethodItem(Icons.Rounded.ShoppingCart, "MoMo")
            }
            Spacer(modifier = Modifier.height(12.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                PaymentMethodItem(Icons.Rounded.Lock, "PayOS")
                PaymentMethodItem(Icons.Rounded.CreditCard, "Visa / Master")
            }

            Spacer(modifier = Modifier.height(20.dp))
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 8.dp)
            ) {
                Icon(
                    Icons.Rounded.Lock,
                    contentDescription = null,
                    modifier = Modifier.size(14.dp),
                    tint = GrayText
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    "All transactions are encrypted and secured by industrial-grade SSL standards.",
                    style = MaterialTheme.typography.bodySmall,
                    color = GrayText,
                    fontSize = 11.sp,
                    lineHeight = 15.sp
                )
            }
        }
    }
}

@Composable
fun PaymentMethodItem(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(18.dp), tint = Color.DarkGray)
        Spacer(modifier = Modifier.width(8.dp))
        Text(label, style = MaterialTheme.typography.bodySmall, color = Color.DarkGray, fontWeight = FontWeight.Medium)
    }
}

private fun formatDate(isoDate: String): String {
    return try {
        // Simple ISO date formatting: "2026-05-10T10:30:00Z" -> "May 10, 2026"
        val parts = isoDate.take(10).split("-")
        if (parts.size == 3) {
            val months = listOf(
                "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
            )
            val month = months.getOrElse(parts[1].toInt() - 1) { parts[1] }
            val day = parts[2].toInt()
            val year = parts[0]
            "$month $day, $year"
        } else isoDate
    } catch (e: Exception) {
        isoDate
    }
}
