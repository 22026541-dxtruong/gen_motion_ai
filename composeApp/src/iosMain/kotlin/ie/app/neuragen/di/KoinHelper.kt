package ie.app.neuragen.di

import ie.app.neuragen.ui.auth.OAuthCallbackHandler
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

object KoinHelper : KoinComponent {
    private val oauthCallbackHandler: OAuthCallbackHandler by inject()
    
    fun getOAuthCallbackHandler(): OAuthCallbackHandler = oauthCallbackHandler
}
