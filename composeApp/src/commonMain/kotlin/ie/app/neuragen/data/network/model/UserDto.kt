package ie.app.neuragen.data.network.model

import kotlinx.serialization.Serializable

@Serializable
data class UserUpdateDto(
    val username: String? = null,
    val bio: String? = null,
    val avatarUrl: String? = null
)

@Serializable
data class UserDto(
    val id: String,
    val email: String,
    val googleId: String? = null,
    val password: String? = null,
    val username: String,
    val bio: String? = null,
    val avatarUrl: String? = null,
    val role: String, // FREE|PRO|ADMIN
    val proExpiresAt: String? = null,
    val createdAt: String
)

@Serializable
data class UserMeDto(
    val id: String,
    val email: String,
    val username: String,
    val avatarUrl: String? = null,
    val bio: String? = null,
    val role: String,
    val proExpiresAt: String? = null,
    val createdAt: String,
    val credits: CreditBalanceDto,
    val counts: UserCountsDto,
    val jobs: JobsPaginationDto
)

@Serializable
data class CreditBalanceDto(
    val balance: Int,
    val updatedAt: String
)

@Serializable
data class UserCountsDto(
    val followers: Int,
    val following: Int,
    val posts: Int,
    val jobs: Int
)

@Serializable
data class CreditTopupRequest(
    val amount: Int,
    val note: String? = null
)

@Serializable
data class CreditTopupResponse(
    val userId: String,
    val amount: Int,
    val balance: Int,
    val reason: String,
    val transactionId: String,
    val note: String? = null,
    val createdAt: String
)

@Serializable
data class UserPublicDto(
    val id: String,
    val username: String,
    val avatarUrl: String? = null,
    val bio: String? = null,
    val credits: CreditBalanceDto? = null
)
