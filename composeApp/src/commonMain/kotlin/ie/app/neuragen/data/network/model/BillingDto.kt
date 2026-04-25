package ie.app.neuragen.data.network.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

@Serializable
data class BillingCatalogResponse(
    val proPlan: ProPlanDto,
    val creditTopupPackages: List<CreditTopupPackageDto>
)

@Serializable
data class ProPlanDto(
    val code: String,
    val label: String,
    val amountUsd: String,
    val amountVnd: Long,
    val credits: Int,
    val durationDays: Int,
    val dailyFreePremiumCredits: Int,
    val proOnlyPresets: List<String>
)

@Serializable
data class CreditTopupPackageDto(
    val code: String,
    val label: String,
    val amountUsd: String,
    val amountVnd: Long,
    val credits: Int
)

@Serializable
data class CreateOrderRequest(
    val type: String, // CREDIT_TOPUP|PRO_SUBSCRIPTION
    val provider: String, // MOMO|PAYOS|BANK_TRANSFER
    val packageCode: String? = null
)

@Serializable
data class OrderResponse(
    val id: String,
    val userId: String? = null,
    val provider: String,
    val type: String,
    val status: String,
    val packageCode: String? = null,
    val amountUsd: String,
    val creditAmount: Int,
    val proDurationDays: Int,
    val createdAt: String,
    val expiresAt: String? = null,
    val metadata: JsonObject? = null,
    val amountVnd: Long? = null,
    val note: String? = null,
    // MoMo specific
    val payUrl: String? = null,
    val shortLink: String? = null,
    val deeplink: String? = null,
    val qrCodeUrl: String? = null,
    // PayOS specific
    val qrCode: String? = null,
    val paymentLinkId: String? = null,
    val orderCode: Long? = null,
    // List specific
    val providerOrderId: String? = null,
    val paidAt: String? = null
)

@Serializable
data class MarkPaidRequest(
    val providerOrderId: String? = null
)

@Serializable
data class MarkPaidResponse(
    val id: String? = null,
    val orderId: String? = null,
    val status: String,
    val type: String? = null,
    val packageCode: String? = null,
    val amountUsd: String? = null,
    val creditAmount: Int? = null,
    val proDurationDays: Int? = null,
    val providerOrderId: String? = null,
    val paidAt: String? = null,
    val nextProExpiresAt: String? = null,
    val message: String? = null
)

@Serializable
data class PayosConfirmRequest(
    val webhookUrl: String? = null
)

@Serializable
data class PayosConfirmResponse(
    val webhookUrl: String,
    val response: JsonObject
)
