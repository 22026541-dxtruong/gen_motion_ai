package ie.app.neuragen.data.repository

import ie.app.neuragen.data.network.NeuraGenApi
import ie.app.neuragen.data.network.model.*
import org.koin.core.annotation.Factory
import org.koin.core.annotation.Provided
import org.koin.core.annotation.Single

interface BillingRepository {
    suspend fun getCatalog(): Result<BillingCatalogResponse>
    suspend fun createOrder(type: String, provider: String, packageCode: String? = null): Result<OrderResponse>
    suspend fun getMyOrders(): Result<List<OrderResponse>>
    suspend fun markOrderPaid(id: String, providerOrderId: String? = null): Result<MarkPaidResponse>
    suspend fun confirmPayosWebhook(webhookUrl: String? = null): Result<PayosConfirmResponse>
}

@Single([BillingRepository::class])
class BillingRepositoryImpl(
    @Provided
    private val api: NeuraGenApi
) : BillingRepository {

    override suspend fun getCatalog(): Result<BillingCatalogResponse> = runCatching {
        api.getBillingCatalog()
    }

    override suspend fun createOrder(type: String, provider: String, packageCode: String?): Result<OrderResponse> = runCatching {
        api.createOrder(CreateOrderRequest(type, provider, packageCode))
    }

    override suspend fun getMyOrders(): Result<List<OrderResponse>> = runCatching {
        api.getMyOrders()
    }

    override suspend fun markOrderPaid(id: String, providerOrderId: String?): Result<MarkPaidResponse> = runCatching {
        api.markOrderPaid(id, MarkPaidRequest(providerOrderId))
    }

    override suspend fun confirmPayosWebhook(webhookUrl: String?): Result<PayosConfirmResponse> = runCatching {
        api.confirmPayosWebhook(PayosConfirmRequest(webhookUrl))
    }
}
