package ie.app.neuragen.ui.common

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.DpOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import ie.app.neuragen.data.network.model.JobNotificationPayload
import neuragen.composeapp.generated.resources.Res
import neuragen.composeapp.generated.resources.ic_notifications
import org.jetbrains.compose.resources.painterResource

@Composable
fun NotificationBell(
    notifications: List<JobNotificationPayload>,
    onMarkAllAsRead: () -> Unit,
    onMarkAsRead: (String) -> Unit,
    onRemove: (String) -> Unit,
    onClearAll: () -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    val unreadCount = notifications.count { !it.read }

    Box {
        IconButton(
            onClick = {
                expanded = !expanded
                if (expanded && unreadCount > 0) {
                    onMarkAllAsRead()
                }
            }
        ) {
            Icon(
                painterResource(Res.drawable.ic_notifications),
                contentDescription = "Notifications",
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
            if (unreadCount > 0) {
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .clip(CircleShape)
                        .background(Color.Red)
                        .align(Alignment.TopEnd)
                        .offset(x = (-8).dp, y = 8.dp)
                )
            }
        }

        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
            offset = DpOffset(0.dp, 8.dp),
            shape = RoundedCornerShape(16.dp),
            containerColor = Color.White,
            modifier = Modifier.width(320.dp).heightIn(max = 400.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Notifications", fontWeight = FontWeight.Bold, color = Color(0xFF1F2937))
                if (notifications.isNotEmpty()) {
                    TextButton(
                        onClick = {
                            onClearAll()
                            expanded = false
                        },
                        contentPadding = PaddingValues(0.dp)
                    ) {
                        Text("Clear all", fontSize = 12.sp, color = Color.Gray)
                    }
                }
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)

            if (notifications.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxWidth().padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            painterResource(Res.drawable.ic_notifications),
                            contentDescription = null,
                            tint = Color(0xFFD1D5DB),
                            modifier = Modifier.size(32.dp)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("No notifications yet.", color = Color.Gray, fontSize = 14.sp)
                    }
                }
            } else {
                notifications.forEach { notif ->
                    NotificationItem(
                        notif = notif,
                        onClick = { onMarkAsRead(notif.id) },
                        onRemove = { onRemove(notif.id) }
                    )
                    HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
                }
            }
        }
    }
}

@Composable
fun NotificationItem(
    notif: JobNotificationPayload,
    onClick: () -> Unit,
    onRemove: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .background(if (!notif.read) Color(0xFFF3F2FF) else Color.White)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Left: Severity icon or thumbnail
        Box(modifier = Modifier.size(40.dp)) {
            if (notif.thumbnailUrl != null) {
                AsyncImage(
                    model = notif.thumbnailUrl,
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize().clip(RoundedCornerShape(8.dp)),
                    contentScale = ContentScale.Crop
                )
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .offset(x = 4.dp, y = 4.dp)
                        .background(Color.White, CircleShape)
                        .padding(2.dp)
                ) {
                    SeverityIcon(notif.severity, 12)
                }
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(8.dp))
                        .background(severityBgColor(notif.severity)),
                    contentAlignment = Alignment.Center
                ) {
                    SeverityIcon(notif.severity, 20)
                }
            }
        }

        // Middle: Content
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = notif.title,
                fontSize = 14.sp,
                fontWeight = if (!notif.read) FontWeight.SemiBold else FontWeight.Medium,
                color = Color(0xFF1F2937),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = notif.message,
                fontSize = 13.sp,
                color = Color.Gray,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                lineHeight = 18.sp
            )

            // Progress bar for in-progress notifications
            if (notif.kind == "JOB_RETRYING" || notif.kind == "JOB_PROVIDER_FALLBACK") {
                Spacer(modifier = Modifier.height(6.dp))
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        Icons.Default.Refresh,
                        contentDescription = null,
                        tint = Color(0xFFF59E0B),
                        modifier = Modifier.size(12.dp)
                    )
                    Text(
                        text = "Retrying${notif.provider?.let { " ($it)" } ?: ""}...",
                        fontSize = 11.sp,
                        color = Color(0xFFF59E0B),
                        fontWeight = FontWeight.Medium
                    )
                }
            }

            // Status badge for completed/failed
            if (notif.resultReady && notif.kind == "JOB_COMPLETED") {
                Spacer(modifier = Modifier.height(4.dp))
                Box(
                    modifier = Modifier
                        .background(Color(0xFFDCFCE7), RoundedCornerShape(4.dp))
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text("Ready to view", fontSize = 10.sp, color = Color(0xFF16A34A), fontWeight = FontWeight.Medium)
                }
            }

            // Timestamp
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = formatNotificationTime(notif.displayTimestamp),
                fontSize = 11.sp,
                color = Color(0xFF9CA3AF)
            )
        }

        // Right: Close button
        IconButton(onClick = onRemove, modifier = Modifier.size(24.dp)) {
            Icon(Icons.Default.Close, contentDescription = "Remove", modifier = Modifier.size(14.dp), tint = Color(0xFFD1D5DB))
        }
    }
}

@Composable
fun SeverityIcon(severity: String, size: Int) {
    when (severity) {
        "success" -> Icon(Icons.Default.CheckCircle, null, tint = Color(0xFF22C55E), modifier = Modifier.size(size.dp))
        "error" -> Icon(Icons.Default.Close, null, tint = Color(0xFFEF4444), modifier = Modifier.size(size.dp))
        "warning" -> Icon(Icons.Default.Warning, null, tint = Color(0xFFF59E0B), modifier = Modifier.size(size.dp))
        else -> Icon(Icons.Default.Info, null, tint = Color(0xFF3B82F6), modifier = Modifier.size(size.dp))
    }
}

fun severityBgColor(severity: String): Color {
    return when (severity) {
        "success" -> Color(0xFFF0FDF4)
        "error" -> Color(0xFFFEF2F2)
        "warning" -> Color(0xFFFFFBEB)
        else -> Color(0xFFEFF6FF)
    }
}

/** Format ISO timestamp to relative or short time */
fun formatNotificationTime(isoTimestamp: String): String {
    if (isoTimestamp.isBlank()) return ""
    return try {
        // Simple extraction: "2026-05-10T05:33:29.891Z" -> "05:33"
        val timeMatch = Regex("""T(\d{2}):(\d{2})""").find(isoTimestamp)
        if (timeMatch != null) {
            val (hours, minutes) = timeMatch.destructured
            val h = hours.toInt()
            val amPm = if (h < 12) "AM" else "PM"
            val displayH = if (h == 0) 12 else if (h > 12) h - 12 else h
            "$displayH:$minutes $amPm"
        } else {
            isoTimestamp
        }
    } catch (_: Exception) {
        isoTimestamp
    }
}
