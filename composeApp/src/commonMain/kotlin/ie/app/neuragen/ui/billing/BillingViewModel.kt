package ie.app.neuragen.ui.billing

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.CreditTopupPackageDto
import ie.app.neuragen.data.network.model.OrderResponse
import ie.app.neuragen.data.network.model.ProPlanDto
import ie.app.neuragen.data.repository.BillingRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.koin.core.annotation.KoinViewModel
import org.koin.core.annotation.Provided

data class BillingUiState(
    val proPlan: ProPlanDto? = null,
    val topupPackages: List<CreditTopupPackageDto> = emptyList(),
    val orders: List<OrderResponse> = emptyList(),
    val isLoading: Boolean = false,
    val isLoadingOrders: Boolean = false,
    val loadingOrderId: String? = null,
    val error: String? = null,
    val paymentUrl: String? = null,
    val activeTab: BillingTab = BillingTab.PLANS
)

enum class BillingTab { PLANS, ORDERS }

@KoinViewModel
class BillingViewModel(
    @Provided private val billingRepository: BillingRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(BillingUiState())
    val uiState: StateFlow<BillingUiState> = _uiState.asStateFlow()

    init {
        loadCatalog()
    }

    fun loadCatalog() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            val result = billingRepository.getCatalog()
            result.onSuccess { catalog ->
                _uiState.update {
                    it.copy(
                        proPlan = catalog.proPlan,
                        topupPackages = catalog.creditTopupPackages,
                        isLoading = false
                    )
                }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(isLoading = false, error = error.message ?: "Failed to load catalog")
                }
            }
        }
    }

    fun setTab(tab: BillingTab) {
        _uiState.update { it.copy(activeTab = tab) }
        if (tab == BillingTab.ORDERS) {
            loadOrders()
        }
    }

    fun loadOrders() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoadingOrders = true) }
            val result = billingRepository.getMyOrders()
            result.onSuccess { orders ->
                _uiState.update { it.copy(orders = orders, isLoadingOrders = false) }
            }.onFailure {
                _uiState.update { it.copy(isLoadingOrders = false) }
            }
        }
    }

    fun upgradeToPro() {
        createOrder("PRO_SUBSCRIPTION", "PAYOS", null)
    }

    fun buyPackage(packageCode: String) {
        createOrder("CREDIT_TOPUP", "PAYOS", packageCode)
    }

    private fun createOrder(type: String, provider: String, packageCode: String?) {
        viewModelScope.launch {
            val loadingId = packageCode ?: type
            _uiState.update { it.copy(loadingOrderId = loadingId) }
            val result = billingRepository.createOrder(type, provider, packageCode)
            result.onSuccess { order ->
                val url = order.payUrl ?: order.shortLink ?: order.deeplink
                _uiState.update { it.copy(loadingOrderId = null, paymentUrl = url) }
            }.onFailure {
                _uiState.update { it.copy(loadingOrderId = null, error = "Failed to create order") }
            }
        }
    }

    fun consumePaymentUrl() {
        _uiState.update { it.copy(paymentUrl = null) }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }
}
