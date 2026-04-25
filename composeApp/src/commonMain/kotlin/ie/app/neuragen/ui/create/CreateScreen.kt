package ie.app.neuragen.ui.create

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import ie.app.neuragen.data.network.model.JobDto
import neuragen.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun CreateScreen(
    viewModel: CreateViewModel = koinViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

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
                selectedPresetId = uiState.selectedPresetId,
                onPresetSelected = viewModel::onPresetSelected,
                isGenerating = uiState.isGenerating,
                onGenerateClick = viewModel::generateVideo
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
            items(uiState.recentJobs) { job ->
                JobItem(job = job)
            }
        }
    }
}

@Composable
fun GenerationForm(
    prompt: String,
    onPromptChange: (String) -> Unit,
    negativePrompt: String,
    onNegativePromptChange: (String) -> Unit,
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
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp)
                    .border(1.dp, Color(0xFFE5E7EB), RoundedCornerShape(12.dp))
                    .clickable { /* Upload */ },
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        painter = painterResource(Res.drawable.ic_profile), // Use a better icon if available
                        contentDescription = null,
                        tint = Color.Gray,
                        modifier = Modifier.size(32.dp)
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("Click to upload or drag an image", style = MaterialTheme.typography.bodySmall, color = Color.Gray)
                    Text("JPG, PNG up to 10MB", style = MaterialTheme.typography.labelSmall, color = Color.LightGray)
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text("Generation Preset", style = MaterialTheme.typography.labelLarge, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(12.dp))
            
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    PresetItem(
                        modifier = Modifier.weight(1f),
                        id = "preview",
                        title = "Preview",
                        subtitle = "2s • 1 Credit",
                        isSelected = selectedPresetId == "preview",
                        onClick = onPresetSelected
                    )
                    PresetItem(
                        modifier = Modifier.weight(1f),
                        id = "standard",
                        title = "Standard",
                        subtitle = "4s • 5 Credits",
                        isSelected = selectedPresetId == "standard",
                        onClick = onPresetSelected
                    )
                }
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    PresetItem(
                        modifier = Modifier.weight(1f),
                        id = "quality",
                        title = "Quality",
                        subtitle = "6s • 12 Credits",
                        isSelected = selectedPresetId == "quality",
                        onClick = onPresetSelected
                    )
                    PresetItem(
                        modifier = Modifier.weight(1f),
                        id = "turbo",
                        title = "Turbo",
                        subtitle = "4s • 8 Credits",
                        isSelected = selectedPresetId == "turbo",
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
                    .background(
                        Brush.horizontalGradient(
                            colors = listOf(Color(0xFF6366F1), Color(0xFFA855F7))
                        )
                    ),
                colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
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
fun JobItem(job: JobDto) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(60.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(Color.LightGray)
            )
            Spacer(modifier = Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    job.prompt,
                    maxLines = 1,
                    overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp
                )
                Text(
                    if (job.status == "completed") "Completed" else "Processing...",
                    style = MaterialTheme.typography.bodySmall,
                    color = if (job.status == "completed") Color(0xFF10B981) else Color(0xFFF59E0B)
                )
            }
            if (job.status == "completed") {
                Icon(
                    painter = painterResource(Res.drawable.ic_for_you), // Use a better check icon if available
                    contentDescription = null,
                    tint = Color(0xFF10B981),
                    modifier = Modifier.size(20.dp)
                )
            }

        }
    }
}
