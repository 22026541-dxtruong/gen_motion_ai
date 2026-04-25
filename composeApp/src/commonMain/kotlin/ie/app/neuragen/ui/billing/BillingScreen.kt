package ie.app.neuragen.ui.billing

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable

import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun BillingScreen(
    viewModel: BillingViewModel = koinViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(Color(0xFFF8F9FF)),
        contentPadding = PaddingValues(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        item {
            BillingHeader()
        }

        item {
            ProPlanCard(onUpgradeClick = viewModel::upgradeToPro)
        }

        item {
            Column(horizontalAlignment = Alignment.Start, modifier = Modifier.fillMaxWidth()) {
                Text(
                    "Credit Top-ups",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0D1B3E)
                )
                Text(
                    "No expiration on top-up credits",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.Gray
                )
            }
        }

        items(uiState.topupPackages) { pkg ->
            TopupPackageCard(
                pkg = pkg,
                isBestValue = pkg.code == "creator_pack", // Assuming based on design
                onBuyClick = { viewModel.buyPackage(pkg.code) }
            )
        }

        item {
            PaymentMethodsFooter()
        }
    }
}

@Composable
fun BillingHeader() {
    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(vertical = 16.dp)) {
        Text(
            "Choose Your Plan",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF0D1B3E)
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            "Elevate your creative potential with AI-powered video generation. Scale your production with flexible credits and premium features.",
            style = MaterialTheme.typography.bodyMedium,
            textAlign = TextAlign.Center,
            color = Color.Gray,
            modifier = Modifier.padding(horizontal = 16.dp)
        )
    }
}

@Composable
fun ProPlanCard(onUpgradeClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Box {
            Column(modifier = Modifier.padding(24.dp)) {
                Text(
                    "PREMIUM EXPERIENCE",
                    style = MaterialTheme.typography.labelSmall,
                    color = Color(0xFF4F46E5),
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    "Pro Monthly",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0D1B3E)
                )
                Row(verticalAlignment = Alignment.Bottom) {
                    Text("$14.99", style = MaterialTheme.typography.headlineLarge, fontWeight = FontWeight.Bold)
                    Text(" /month", style = MaterialTheme.typography.bodyMedium, color = Color.Gray, modifier = Modifier.padding(bottom = 4.dp))
                }

                Spacer(modifier = Modifier.height(24.dp))

                ProFeatureItem(icon = Res.drawable.ic_billing, text = "1,000 Credits", subtext = "Reset every month")
                ProFeatureItem(icon = Res.drawable.ic_for_you, text = "High-Speed Processing", subtext = "Priority render queue")
                ProFeatureItem(icon = Res.drawable.ic_create, text = "Pro-only Presets", subtext = "Exclusive AI styles")
                ProFeatureItem(icon = Res.drawable.ic_explore, text = "4K Upscaling", subtext = "Cinematic resolution")

                Spacer(modifier = Modifier.height(32.dp))

                Button(
                    onClick = onUpgradeClick,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(
                            Brush.horizontalGradient(
                                colors = listOf(Color(0xFF6366F1), Color(0xFFA855F7))
                            )
                        ),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent)
                ) {
                    Text("Upgrade to Pro Monthly", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
            }

            Surface(
                modifier = Modifier.align(Alignment.TopEnd),
                color = Color(0xFF6366F1),
                shape = RoundedCornerShape(bottomStart = 16.dp, topEnd = 24.dp)
            ) {
                Text(
                    "MOST POPULAR",
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                    style = MaterialTheme.typography.labelSmall,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
fun ProFeatureItem(icon: org.jetbrains.compose.resources.DrawableResource, text: String, subtext: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 8.dp)
    ) {
        Surface(
            modifier = Modifier.size(36.dp),
            shape = RoundedCornerShape(10.dp),
            color = Color(0xFFF3F2FF)
        ) {
            Icon(
                painterResource(icon),
                contentDescription = null,
                tint = Color(0xFF4F46E5),
                modifier = Modifier.padding(8.dp)
            )
        }
        Spacer(modifier = Modifier.width(16.dp))
        Column {
            Text(text, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.Bold, color = Color(0xFF0D1B3E))
            Text(subtext, style = MaterialTheme.typography.bodySmall, color = Color.Gray)
        }
    }
}

@Composable
fun TopupPackageCard(
    pkg: ie.app.neuragen.data.network.model.CreditTopupPackageDto,
    isBestValue: Boolean,
    onBuyClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .border(
                width = if (isBestValue) 1.dp else 0.dp,
                color = if (isBestValue) Color(0xFF4F46E5) else Color.Transparent,
                shape = RoundedCornerShape(20.dp)
            ),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
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
                        shape = RoundedCornerShape(12.dp),
                        color = if (isBestValue) Color(0xFFEEF2FF) else Color(0xFFF9FAFB)
                    ) {
                        Icon(
                            painterResource(Res.drawable.ic_billing),
                            contentDescription = null,
                            tint = if (isBestValue) Color(0xFF4F46E5) else Color.Gray,
                            modifier = Modifier.padding(10.dp)
                        )
                    }
                    Text(
                        "$${pkg.amountUsd}",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF0D1B3E)
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text(pkg.label, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                Text("${pkg.credits} Credits for active creators", style = MaterialTheme.typography.bodySmall, color = Color.Gray)

                Spacer(modifier = Modifier.height(20.dp))

                Button(
                    onClick = onBuyClick,
                    modifier = Modifier.fillMaxWidth().height(48.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = if (isBestValue) {
                        ButtonDefaults.buttonColors(containerColor = Color(0xFF4F46E5))
                    } else {
                        ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color(0xFF374151))
                    },
                    border = if (isBestValue) null else ButtonDefaults.outlinedButtonBorder
                ) {

                    Text("Buy Credits", fontWeight = FontWeight.Bold)
                }
            }

            if (isBestValue) {
                Surface(
                    modifier = Modifier.align(Alignment.TopCenter).offset(y = (-10).dp),
                    color = Color(0xFF4F46E5),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text(
                        "BEST VALUE",
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp),
                        style = MaterialTheme.typography.labelSmall,
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 8.sp
                    )
                }
            }
        }
    }
}

@Composable
fun PaymentMethodsFooter() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 16.dp),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFFF3F4F6).copy(alpha = 0.5f))
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                "SECURE PAYMENT METHODS",
                style = MaterialTheme.typography.labelSmall,
                color = Color.Gray,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
            Spacer(modifier = Modifier.height(20.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                PaymentMethodItem(icon = Res.drawable.ic_billing, label = "Bank Transfer")
                PaymentMethodItem(icon = Res.drawable.ic_notifications, label = "MoMo") // Placeholder icon
            }
            Spacer(modifier = Modifier.height(16.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                PaymentMethodItem(icon = Res.drawable.ic_passworld, label = "PayOS")
                PaymentMethodItem(icon = Res.drawable.ic_share, label = "Visa / Master")
            }

            Spacer(modifier = Modifier.height(24.dp))
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(horizontal = 16.dp)) {
                Icon(painterResource(Res.drawable.ic_passworld), contentDescription = null, modifier = Modifier.size(12.dp), tint = Color.Gray)
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    "All transactions are encrypted and secured by industrial-grade SSL standards.",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.Gray,
                    textAlign = TextAlign.Center,
                    fontSize = 10.sp,
                    lineHeight = 14.sp
                )
            }
        }
    }
}

@Composable
fun PaymentMethodItem(icon: org.jetbrains.compose.resources.DrawableResource, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(painterResource(icon), contentDescription = null, modifier = Modifier.size(18.dp), tint = Color.DarkGray)
        Spacer(modifier = Modifier.width(8.dp))
        Text(label, style = MaterialTheme.typography.bodySmall, color = Color.DarkGray, fontWeight = FontWeight.Medium)
    }
}
