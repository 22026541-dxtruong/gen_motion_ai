package ie.app.neuragen.ui.billing

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ie.app.neuragen.data.network.model.BillingCatalogResponse
import ie.app.neuragen.data.network.model.CreditTopupPackageDto
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
    val isLoading: Boolean = false,
    val error: String? = null
)

@KoinViewModel
class BillingViewModel(
    @Provided private val billingRepository: BillingRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(BillingUiState())
    val uiState: StateFlow<BillingUiState> = _uiState.asStateFlow()

    init {
        println("BillingViewModel: Initializing...")
        loadCatalog()
    }

    fun loadCatalog() {
        viewModelScope.launch {
            println("BillingViewModel: Loading catalog...")
            _uiState.update { it.copy(isLoading = true, error = null) }
            
            val result = billingRepository.getCatalog()
            result.onSuccess { catalog ->
                println("BillingViewModel: Successfully loaded catalog")
                _uiState.update { 
                    it.copy(
                        proPlan = catalog.proPlan,
                        topupPackages = catalog.creditTopupPackages,
                        isLoading = false
                    )
                }
            }.onFailure { error ->
                println("BillingViewModel: ERROR: Failed to load catalog: ${error.message}")
                _uiState.update { 
                    it.copy(
                        isLoading = false,
                        error = "Failed to load billing catalog"
                    )
                }
            }
        }
    }

    fun upgradeToPro() {
        println("BillingViewModel: Upgrading to Pro...")
        // Order creation logic would go here
    }

    fun buyPackage(packageCode: String) {
        println("BillingViewModel: Buying package $packageCode...")
        // Order creation logic would go here
    }
}
