package ie.app.neuragen.ui.billing

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.CreditTopupPackageDto
import ie.app.neuragen.data.network.model.OrderResponse
import ie.app.neuragen.data.network.model.ProPlanDto
import ie.app.neuragen.data.repository.BillingRepository
import ie.app.neuragen.data.repository.UserRepository
import ie.app.neuragen.util.AppLifecycleObserver
import ie.app.neuragen.util.UserSessionState
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
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
    val activeTab: BillingTab = BillingTab.PLANS,

    // Payment return polling
    val pendingOrderId: String? = null,
    val isPollingPayment: Boolean = false,
    val paymentConfirmed: Boolean = false,
    val confirmedCredits: Int? = null
)

enum class BillingTab { PLANS, ORDERS }

@KoinViewModel
class BillingViewModel(
    @Provided private val billingRepository: BillingRepository,
    @Provided private val userRepository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(BillingUiState())
    val uiState: StateFlow<BillingUiState> = _uiState.asStateFlow()

    private var pollingJob: Job? = null

    init {
        loadCatalog()

        // Auto-refresh when app returns to foreground (e.g., from payment browser)
        viewModelScope.launch {
            AppLifecycleObserver.resumeCount.collect { count ->
                if (count > 0) {
                    val pendingId = _uiState.value.pendingOrderId
                    if (pendingId != null) {
                        // Returning from payment — start polling
                        startPaymentPolling(pendingId)
                    }
                    // Always reload orders on resume
                    if (_uiState.value.activeTab == BillingTab.ORDERS) {
                        loadOrders()
                    }
                }
            }
        }
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
                _uiState.update {
                    it.copy(
                        loadingOrderId = null,
                        paymentUrl = url,
                        pendingOrderId = order.id // Track for polling on return
                    )
                }
            }.onFailure {
                _uiState.update { it.copy(loadingOrderId = null, error = "Failed to create order") }
            }
        }
    }

    fun consumePaymentUrl() {
        _uiState.update { it.copy(paymentUrl = null) }
    }

    /**
     * Poll the backend every 5s to check if the pending order has been marked PAID.
     * Mirrors the web's payos-return page polling logic.
     * Max 10 attempts (50s total), then stops.
     */
    private fun startPaymentPolling(orderId: String) {
        // Don't start multiple polling loops
        if (_uiState.value.isPollingPayment) return

        pollingJob?.cancel()
        pollingJob = viewModelScope.launch {
            _uiState.update { it.copy(isPollingPayment = true) }

            repeat(10) { attempt ->
                delay(5000) // 5s intervals

                val result = billingRepository.getMyOrders()
                result.onSuccess { orders ->
                    val order = orders.find { it.id == orderId }
                    if (order?.status == "PAID") {
                        _uiState.update {
                            it.copy(
                                orders = orders,
                                isPollingPayment = false,
                                paymentConfirmed = true,
                                confirmedCredits = order.creditAmount,
                                pendingOrderId = null,
                                activeTab = BillingTab.ORDERS
                            )
                        }
                        
                        // Optimistically update credit immediately for Topbar
                        if (order.creditAmount > 0) {
                            ie.app.neuragen.util.UserSessionState.patch { currentUser ->
                                currentUser.copy(
                                    credits = currentUser.credits.copy(
                                        balance = currentUser.credits.balance + order.creditAmount
                                    )
                                )
                            }
                        }

                        // Refresh user profile to update credit balance globally
                        refreshUserProfile()
                        return@launch // Stop polling — confirmed!
                    }
                    // Update orders list in case status changed to FAILED etc.
                    _uiState.update { it.copy(orders = orders) }
                }
            }

            // Max attempts reached — stop polling
            _uiState.update {
                it.copy(
                    isPollingPayment = false,
                    pendingOrderId = null
                )
            }
        }
    }

    fun dismissPaymentConfirmation() {
        _uiState.update { it.copy(paymentConfirmed = false, confirmedCredits = null) }
    }

    /**
     * Fetch fresh user profile after payment and broadcast to all screens.
     * This ensures Topbar credits, ProfileScreen balance, etc. update in real-time.
     */
    private fun refreshUserProfile() {
        viewModelScope.launch {
            val result = userRepository.getMe()
            if (result.isSuccess) {
                UserSessionState.update(result.getOrNull())
            }
        }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    override fun onCleared() {
        super.onCleared()
        pollingJob?.cancel()
    }
}
