package ie.app.neuragen.data.repository

import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import ie.app.neuragen.data.repository.SessionRepository
import org.koin.core.annotation.Factory
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface AuthRepository {
    suspend fun register(request: RegisterRequest): Result<AuthResponse>
    suspend fun login(request: LoginRequest): Result<AuthResponse>
    suspend fun googleCallback(query: Map<String, String>): Result<AuthResponse>
    suspend fun googleExchangeCode(code: String): Result<AuthResponse>
    suspend fun googleTokenLogin(idToken: String, platform: String = "android"): Result<AuthResponse>
    suspend fun refreshTokens(refreshToken: String): Result<AuthResponse>
    suspend fun logout(refreshToken: String): Result<MessageResponse>
    suspend fun logoutAll(): Result<MessageResponse>
    suspend fun changePassword(old: String, new: String): Result<MessageResponse>
    suspend fun forgotPassword(email: String): Result<MessageResponse>
    suspend fun resetPassword(token: String, new: String): Result<MessageResponse>
}

@Single([AuthRepository::class])
class AuthRepositoryImpl(
    @Provided
    private val api: NeuraGenApi,
    @Provided
    private val sessionRepository: SessionRepository
) : AuthRepository {

    override suspend fun register(request: RegisterRequest): Result<AuthResponse> = runCatching {
        api.register(request)
    }

    override suspend fun login(request: LoginRequest): Result<AuthResponse> = runCatching {
        api.login(request)
    }

    override suspend fun googleCallback(query: Map<String, String>): Result<AuthResponse> = runCatching {
        api.googleCallback(query)
    }

    override suspend fun googleExchangeCode(code: String): Result<AuthResponse> = runCatching {
        api.googleExchangeCode(code)
    }

    override suspend fun googleTokenLogin(idToken: String, platform: String): Result<AuthResponse> = runCatching {
        api.googleTokenLogin(idToken, platform)
    }

    override suspend fun refreshTokens(refreshToken: String): Result<AuthResponse> = runCatching {
        api.refreshTokens(RefreshRequest(refreshToken))
    }

    override suspend fun logout(refreshToken: String): Result<MessageResponse> = runCatching {
        val result = api.logout(LogoutRequest(refreshToken))
        sessionRepository.clearSession()
        result
    }

    override suspend fun logoutAll(): Result<MessageResponse> = runCatching {
        val result = api.logoutAll()
        sessionRepository.clearSession()
        result
    }

    override suspend fun changePassword(old: String, new: String): Result<MessageResponse> = runCatching {
        api.changePassword(ChangePasswordRequest(old, new))
    }

    override suspend fun forgotPassword(email: String): Result<MessageResponse> = runCatching {
        api.forgotPassword(ForgotPasswordRequest(email))
    }

    override suspend fun resetPassword(token: String, new: String): Result<MessageResponse> = runCatching {
        api.resetPassword(ResetPasswordRequest(token, new))
    }
}
