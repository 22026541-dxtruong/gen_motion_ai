package ie.app.neuragen.ui.create

import androidx.compose.foundation.BorderStroke
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.DialogProperties
import coil3.compose.AsyncImage
import ie.app.neuragen.data.network.model.JobDto
import ie.app.neuragen.data.network.model.JobLogDto
import ie.app.neuragen.ui.common.*
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun CreateScreen(
    viewModel: CreateViewModel = koinViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var selectedJobForWatch by remember { mutableStateOf<JobDto?>(null) }
    val uriHandler = LocalUriHandler.current

    val imagePickerLauncher = rememberImagePickerLauncher { uri ->
        viewModel.onImageSelected(uri)
    }

    val fileBytesLoader = rememberFileBytesLoader()

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(Color(0xFFF8F9FF)),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            GenerationForm(
                prompt = uiState.prompt,
                onPromptChange = viewModel::onPromptChange,
                negativePrompt = uiState.negativePrompt,
                onNegativePromptChange = viewModel::onNegativePromptChange,
                selectedImageUri = uiState.selectedImageUri,
                onImageClick = imagePickerLauncher,
                onRemoveImage = { viewModel.onImageSelected(null) },
                selectedPresetId = uiState.selectedPresetId,
                onPresetSelected = viewModel::onPresetSelected,
                isGenerating = uiState.isGenerating,
                onGenerateClick = {
                    val bytes = uiState.selectedImageUri?.let { fileBytesLoader(it) }
                    viewModel.generateVideo(bytes)
                }
            )
        }

        item {
            RecentJobsHeader()
        }

        if (uiState.recentJobs.isEmpty() && !uiState.isLoadingJobs) {
            item {
                Text(
                    "No recent jobs found.",
                    modifier = Modifier.fillMaxWidth().padding(32.dp),
                    textAlign = TextAlign.Center,
                    color = Color.Gray
                )
            }
        } else {
            items(uiState.recentJobs, key = { it.id }) { job ->
                JobItem(
                    job = job,
                    onWatchClick = { selectedJobForWatch = job },
                    onDownloadClick = { job.output?.downloadUrl?.let { uriHandler.openUri(it) } }
                )
            }
        }
    }

    selectedJobForWatch?.let { job ->
        val videoUrl = job.output?.downloadUrl
        if (videoUrl != null) {
            WatchDialog(
                videoUrl = videoUrl,
                onDismiss = { selectedJobForWatch = null }
            )
        }
    }
}

@Composable
fun GenerationForm(
    prompt: String,
    onPromptChange: (String) -> Unit,
    negativePrompt: String,
    onNegativePromptChange: (String) -> Unit,
    selectedImageUri: String?,
    onImageClick: () -> Unit,
    onRemoveImage: () -> Unit,
    selectedPresetId: String,
    onPresetSelected: (String) -> Unit,
    isGenerating: Boolean,
    onGenerateClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        painter = painterResource(Res.drawable.ic_create),
                        contentDescription = null,
                        tint = Color(0xFF4F46E5),
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        "Generate Video",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF0D1B3E)
                    )
                }
                Surface(
                    color = Color(0xFFEEF2FF),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text(
                        "AI v2.5 Active",
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelSmall,
                        color = Color(0xFF4F46E5),
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text("Video Prompt", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(
                value = prompt,
                onValueChange = onPromptChange,
                modifier = Modifier.fillMaxWidth().height(100.dp),
                placeholder = { Text("Describe the scene you want to bring to life...") },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(unfocusedBorderColor = Color(0xFFE5E7EB))
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text("Negative Prompt (Optional)", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(
                value = negativePrompt,
                onValueChange = onNegativePromptChange,
                modifier = Modifier.fillMaxWidth().height(80.dp),
                placeholder = { Text("Low quality, blurry, distorted faces...") },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(unfocusedBorderColor = Color(0xFFE5E7EB))
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text("Image Reference (I2V)", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))

            if (selectedImageUri != null) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(160.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFFF3F4F6))
                ) {
                    AsyncImage(
                        model = selectedImageUri,
                        contentDescription = "Selected reference image",
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                    IconButton(
                        onClick = onRemoveImage,
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(8.dp)
                            .background(Color.Black.copy(alpha = 0.5f), RoundedCornerShape(12.dp))
                            .size(32.dp)
                    ) {
                        Icon(
                            painter = painterResource(Res.drawable.ic_close),
                            contentDescription = "Remove image",
                            tint = Color.White,
                            modifier = Modifier.size(16.dp)
                        )
                    }
                }
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(120.dp)
                        .border(1.dp, Color(0xFFE5E7EB), RoundedCornerShape(12.dp))
                        .clickable { onImageClick() },
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            painter = painterResource(Res.drawable.ic_add_image),
                            contentDescription = null,
                            tint = Color.Gray,
                            modifier = Modifier.size(32.dp)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("Click to upload or drag an image", style = MaterialTheme.typography.bodySmall, color = Color.Gray)
                        Text("JPG, PNG up to 10MB", style = MaterialTheme.typography.labelSmall, color = Color.LightGray)
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text("Generation Preset", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(12.dp))

            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    PresetItem(
                        modifier = Modifier.weight(1f),
                        id = "preview_ltx_i2v",
                        title = "Preview",
                        subtitle = "2s • 1 Credit",
                        isSelected = selectedPresetId == "preview_ltx_i2v",
                        onClick = onPresetSelected
                    )
                    PresetItem(
                        modifier = Modifier.weight(1f),
                        id = "standard_wan22_ti2v",
                        title = "Standard",
                        subtitle = "4s • 5 Credits",
                        isSelected = selectedPresetId == "standard_wan22_ti2v",
                        onClick = onPresetSelected
                    )
                }
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    PresetItem(
                        modifier = Modifier.weight(1f),
                        id = "quality_hunyuan_i2v",
                        title = "Quality",
                        subtitle = "8s • 12 Credits",
                        isSelected = selectedPresetId == "quality_hunyuan_i2v",
                        onClick = onPresetSelected
                    )
                    PresetItem(
                        modifier = Modifier.weight(1f),
                        id = "turbo_wan22_i2v_a14b",
                        title = "Turbo",
                        subtitle = "4s • 8 Credits",
                        isSelected = selectedPresetId == "turbo_wan22_i2v_a14b",
                        onClick = onPresetSelected
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = onGenerateClick,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .then(
                        if (isGenerating || prompt.isBlank()) {
                            Modifier.background(Color.LightGray.copy(alpha = 0.5f))
                        } else {
                            Modifier.background(
                                Brush.horizontalGradient(
                                    colors = listOf(Color(0xFF6366F1), Color(0xFFA855F7))
                                )
                            )
                        }
                    ),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.Transparent,
                    disabledContainerColor = Color.Transparent
                ),
                enabled = !isGenerating && prompt.isNotBlank()
            ) {
                if (isGenerating) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(painterResource(Res.drawable.ic_create), contentDescription = null, modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Generate Video", fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

@Composable
fun PresetItem(
    modifier: Modifier = Modifier,
    id: String,
    title: String,
    subtitle: String,
    isSelected: Boolean,
    onClick: (String) -> Unit
) {
    Box(
        modifier = modifier
            .border(
                width = 1.dp,
                color = if (isSelected) Color(0xFF4F46E5) else Color(0xFFE5E7EB),
                shape = RoundedCornerShape(12.dp)
            )
            .background(
                color = if (isSelected) Color(0xFFEEF2FF) else Color.White,
                shape = RoundedCornerShape(12.dp)
            )
            .clickable { onClick(id) }
            .padding(12.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(title, fontWeight = FontWeight.Bold, color = if (isSelected) Color(0xFF4F46E5) else Color.DarkGray)
            Text(subtitle, style = MaterialTheme.typography.labelSmall, color = Color.Gray)
        }
    }
}

@Composable
fun RecentJobsHeader() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text("My Recent Jobs", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
        TextButton(onClick = {}) {
            Text("View All", color = Color(0xFF4F46E5))
        }
    }
}

@Composable
fun JobItem(
    job: JobDto,
    onWatchClick: () -> Unit,
    onDownloadClick: () -> Unit
) {
    val status = job.status.uppercase()
    val isProcessing = listOf("PENDING", "QUEUED", "PROCESSING").contains(status)
    val isFailed = status == "FAILED" || status == "CANCELLED"

    when {
        isProcessing -> ProcessingJobItem(job)
        isFailed -> FailedJobItem(job)
        else -> CompletedJobItem(job, onWatchClick, onDownloadClick)
    }
}

@Composable
fun ProcessingJobItem(job: JobDto) {
    val gradientBrush = Brush.horizontalGradient(
        colors = listOf(Color(0xFF6366F1), Color(0xFFA855F7))
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .border(1.dp, gradientBrush, RoundedCornerShape(16.dp)),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Top Status Bar
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(Color(0xFF10B981))
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        "LIVE SSE CONNECTION",
                        style = MaterialTheme.typography.labelSmall,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF6B7280),
                        letterSpacing = 0.5.sp
                    )
                }
                Surface(
                    color = Color(0xFFEEF2FF),
                    shape = RoundedCornerShape(6.dp)
                ) {
                    Text(
                        job.status.uppercase(),
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelSmall,
                        color = Color(0xFF4F46E5),
                        fontWeight = FontWeight.ExtraBold
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Main Info Row
            Row(modifier = Modifier.fillMaxWidth()) {
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFFF3F4F6))
                ) {
                    if (job.thumbnail?.downloadUrl != null) {
                        AsyncImage(
                            model = job.thumbnail.downloadUrl,
                            contentDescription = null,
                            modifier = Modifier.fillMaxSize(),
                            contentScale = ContentScale.Crop
                        )
                    }
                    // Frame overlay
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .align(Alignment.BottomCenter)
                            .background(Color.Black.copy(alpha = 0.6f))
                            .padding(4.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                "Frame: 156/240",
                                style = MaterialTheme.typography.labelSmall,
                                color = Color.White,
                                fontSize = 8.sp
                            )
                            Box(
                                modifier = Modifier
                                    .size(4.dp)
                                    .clip(CircleShape)
                                    .background(Color(0xFF10B981))
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.width(16.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        job.prompt,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp,
                        color = Color(0xFF111827)
                    )
                    Text(
                        "ID: #VGEN-${job.id.take(4).uppercase()}",
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF9CA3AF)
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    val animatedProgress by animateFloatAsState(
                        targetValue = job.progress,
                        animationSpec = tween(durationMillis = 500),
                        label = "progress_animation"
                    )

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            "Synthesizing frames ...",
                            style = MaterialTheme.typography.labelSmall,
                            color = Color(0xFF6B7280),
                            fontWeight = FontWeight.Medium
                        )
                        Text(
                            "${(animatedProgress * 100).toInt()}%",
                            style = MaterialTheme.typography.labelSmall,
                            color = Color(0xFF4F46E5),
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    LinearProgressIndicator(
                        progress = { animatedProgress },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(8.dp)
                            .clip(RoundedCornerShape(4.dp)),
                        color = Color(0xFF6366F1), // Should be gradient if possible, but LinearProgressIndicator doesn't support Brush easily without custom drawing
                        trackColor = Color(0xFFF3F4F6)
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Log Console
            JobLogConsole(logs = job.logs ?: emptyList())
        }
    }
}

@Composable
fun JobLogConsole(logs: List<JobLogDto>) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(130.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(Color(0xFF0F172A))
            .padding(12.dp)
    ) {
        val displayLogs = logs.takeLast(6)
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            if (displayLogs.isEmpty()) {
                Text(
                    "Connecting to job stream...",
                    color = Color(0xFF64748B),
                    style = MaterialTheme.typography.labelSmall
                )
            } else {
                displayLogs.forEach { log ->
                    Row(verticalAlignment = Alignment.Top) {
                        // Extract time from ISO string
                        val timeStr = remember(log.createdAt) {
                            try {
                                log.createdAt.substring(11, 19)
                            } catch (e: Exception) {
                                "--:--:--"
                            }
                        }
                        
                        Text(
                            text = timeStr,
                            color = Color(0xFF475569),
                            style = MaterialTheme.typography.labelSmall,
                            fontSize = 10.sp,
                            fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        
                        // Simple tag extraction logic
                        val (tag, message) = remember(log.message) {
                            val msg = log.message.uppercase()
                            when {
                                msg.contains("QUEUED") -> "[QUEUED]" to log.message
                                msg.contains("ASSET") -> "[ASSETS]" to log.message
                                msg.contains("MODEL") -> "[MODEL]" to log.message
                                msg.contains("PROGRESS") -> "[STATUS]" to log.message
                                else -> "[INFO]" to log.message
                            }
                        }
                        
                        Text(
                            text = tag,
                            color = when(tag) {
                                "[QUEUED]" -> Color(0xFF10B981)
                                "[ASSETS]" -> Color(0xFF38BDF8)
                                "[MODEL]" -> Color(0xFFA855F7)
                                else -> Color(0xFF6366F1)
                            },
                            style = MaterialTheme.typography.labelSmall,
                            fontWeight = FontWeight.Bold,
                            fontSize = 10.sp,
                            fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            text = message,
                            color = Color(0xFF94A3B8),
                            style = MaterialTheme.typography.labelSmall,
                            fontSize = 10.sp,
                            maxLines = 2,
                            overflow = TextOverflow.Ellipsis,
                            fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun FailedJobItem(job: JobDto) {
    val status = job.status.uppercase()
    val isCancelled = status == "CANCELLED"
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFFFEF2F2)) // Light red background
                ) {
                    Icon(
                        painter = painterResource(if (isCancelled) Res.drawable.ic_close else Res.drawable.ic_create),
                        contentDescription = null,
                        modifier = Modifier.align(Alignment.Center).size(24.dp),
                        tint = Color(0xFFEF4444)
                    )
                }
                Spacer(modifier = Modifier.width(16.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        job.prompt.ifBlank { "Video Generation" },
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp,
                        color = Color(0xFF111827)
                    )
                    Text(
                        if (isCancelled) "Cancelled" else "Generation Failed",
                        style = MaterialTheme.typography.labelSmall,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFFEF4444)
                    )
                }
                Icon(
                    painter = painterResource(Res.drawable.ic_close),
                    contentDescription = null,
                    tint = Color(0xFFEF4444),
                    modifier = Modifier.size(20.dp)
                )
            }

            if (!job.errorMessage.isNullOrBlank()) {
                Spacer(modifier = Modifier.height(12.dp))
                Surface(
                    color = Color(0xFFFEF2F2),
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = job.errorMessage,
                        modifier = Modifier.padding(12.dp),
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF991B1B)
                    )
                }
            }
        }
    }
}

@Composable
fun CompletedJobItem(
    job: JobDto,
    onWatchClick: () -> Unit,
    onDownloadClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFFF3F4F6))
                ) {
                    if (job.thumbnail?.downloadUrl != null) {
                        AsyncImage(
                            model = job.thumbnail.downloadUrl,
                            contentDescription = null,
                            modifier = Modifier.fillMaxSize(),
                            contentScale = ContentScale.Crop
                        )
                    } else {
                        Icon(
                            painter = painterResource(Res.drawable.ic_add_image),
                            contentDescription = null,
                            modifier = Modifier.align(Alignment.Center).size(24.dp),
                            tint = Color.Gray
                        )
                    }
                }
                Spacer(modifier = Modifier.width(16.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        job.prompt.ifBlank { "Completed Video" },
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp,
                        color = Color(0xFF111827)
                    )
                    Text(
                        "Completed",
                        style = MaterialTheme.typography.labelSmall,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF10B981)
                    )
                }
                Icon(
                    painter = painterResource(Res.drawable.ic_for_you), // Replace with checkmark icon if available
                    contentDescription = null,
                    tint = Color(0xFF10B981),
                    modifier = Modifier.size(20.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedButton(
                    onClick = onDownloadClick,
                    modifier = Modifier.weight(1f).height(44.dp),
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color(0xFF374151)),
                    border = BorderStroke(1.dp, Color(0xFFE5E7EB))
                ) {
                    Text("Download", fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                }

                OutlinedButton(
                    onClick = onWatchClick,
                    modifier = Modifier.weight(1f).height(44.dp),
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color(0xFF374151)),
                    border = BorderStroke(1.dp, Color(0xFFE5E7EB))
                ) {
                    Text("Watch", fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WatchDialog(
    videoUrl: String,
    onDismiss: () -> Unit
) {
    BasicAlertDialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false),
        content = {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.8f))
            ) {
                VideoPlayer(
                    videoUrl = videoUrl,
                    modifier = Modifier.fillMaxWidth().align(Alignment.Center).aspectRatio(16f / 9f)
                )
                IconButton(
                    onClick = onDismiss,
                    modifier = Modifier.align(Alignment.TopEnd).padding(16.dp)
                ) {
                    Icon(
                        painter = painterResource(Res.drawable.ic_close),
                        contentDescription = "Close",
                        tint = Color.White
                    )
                }
            }
        }
    )
}