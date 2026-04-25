package ie.app.neuragen.di

import ie.app.neuragen.data.network.NetworkConstants
import ie.app.neuragen.data.repository.SessionRepository
import io.ktor.client.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.auth.*
import io.ktor.client.plugins.auth.providers.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
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
    }

    @Single
    fun provideHttpClient(
        json: Json,
        @Provided sessionRepository: SessionRepository
    ): HttpClient = HttpClient {
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
            }
        }
        defaultRequest {
            url(NetworkConstants.BASE_URL)
            contentType(ContentType.Application.Json)
        }
    }
}

