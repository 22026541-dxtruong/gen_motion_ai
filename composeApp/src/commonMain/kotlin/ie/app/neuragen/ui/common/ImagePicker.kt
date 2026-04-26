package ie.app.neuragen.ui.common

import androidx.compose.runtime.Composable

@Composable
expect fun rememberImagePickerLauncher(
    onResult: (String?) -> Unit
): () -> Unit