package ie.app.neuragen.di

import ie.app.neuragen.data.network.NetworkConstants
import ie.app.neuragen.data.network.model.AuthResponse
import ie.app.neuragen.data.network.model.RefreshRequest
import ie.app.neuragen.data.repository.SessionRepository
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.auth.*
import io.ktor.client.plugins.auth.providers.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.client.plugins.sse.SSE
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.serialization.json.Json
import org.koin.core.annotation.ComponentScan
import org.koin.core.annotation.Module
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

@Module
@ComponentScan("ie.app.neuragen.data.network")
class NetworkModule {

    @Single
    fun provideJson(): Json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        encodeDefaults = true
        explicitNulls = false
    }

    @Single
    fun provideHttpClient(
        @Provided json: Json,
        @Provided sessionRepository: SessionRepository
    ): HttpClient = HttpClient {
        install(SSE)
        install(ContentNegotiation) {
            json(json)
        }
        install(Logging) {
            level = LogLevel.INFO
            logger = Logger.DEFAULT
        }
        install(Auth) {
            bearer {
                loadTokens {
                    sessionRepository.getSession().firstOrNull()?.let {
                        BearerTokens(it.accessToken, it.refreshToken)
                    }
                }
                refreshTokens {
                    // In Ktor 3, 'oldTokens' is a property of the context
                    val oldTokens = this.oldTokens

                    // 1. Check if token was already refreshed by another concurrent request
                    val currentSession = sessionRepository.getSession().firstOrNull() ?: return@refreshTokens null
                    if (currentSession.accessToken != oldTokens?.accessToken) {
                        return@refreshTokens BearerTokens(currentSession.accessToken, currentSession.refreshToken)
                    }

                    // 2. Perform refresh
                    try {
                        val response = client.post("/auth/refresh") {
                            setBody(RefreshRequest(currentSession.refreshToken))
                            markAsRefreshTokenRequest()
                        }

                        if (response.status == HttpStatusCode.OK || response.status == HttpStatusCode.Created) {
                            val newAuthResponse = response.body<AuthResponse>()
                            sessionRepository.saveSession(newAuthResponse)
                            BearerTokens(newAuthResponse.accessToken, newAuthResponse.refreshToken)
                        } else {
                            // If refresh token is also invalid/expired, log out user
                            sessionRepository.clearSession()
                            null
                        }
                    } catch (e: Exception) {
                        null
                    }
                }
                sendWithoutRequest { request ->
                    // Send token proactively for all requests EXCEPT auth endpoints
                    !request.url.encodedPath.contains("/auth/")
                }
            }
        }
        defaultRequest {
            url(NetworkConstants.BASE_URL)
            contentType(ContentType.Application.Json)
        }
    }
}
