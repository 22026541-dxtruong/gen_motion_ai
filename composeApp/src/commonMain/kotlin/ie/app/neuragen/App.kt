package ie.app.neuragen

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import ie.app.neuragen.ui.navigation.AppNav

import ie.app.neuragen.ui.theme.NeuraGenTheme

@Composable
@Preview
fun App() {
    NeuraGenTheme {
        AppNav(modifier = Modifier.fillMaxSize())
    }
}