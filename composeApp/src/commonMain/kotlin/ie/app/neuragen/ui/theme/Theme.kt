package ie.app.neuragen.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val NeuraGenLightColorScheme = lightColorScheme(
    primary = LightPrimary,
    onPrimary = LightOnPrimary,
    secondary = LightSecondary,
    onSecondary = LightOnSecondary,
    background = LightBackground,
    onBackground = LightOnBackground,
    surface = LightSurface,
    onSurface = LightOnSurface,
    surfaceVariant = LightSurfaceVariant,
    onSurfaceVariant = LightOnSurfaceVariant,
    error = LightError,
    onError = LightOnError,
    outline = LightOutline
)

@Composable
fun NeuraGenTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    // For now, we enforce light theme matching the Web's Indigo/Slate palette
    // A separate DarkColorScheme can be added in the future.
    val colorScheme = NeuraGenLightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = NeuraGenTypography,
        shapes = NeuraGenShapes,
        content = content
    )
}
