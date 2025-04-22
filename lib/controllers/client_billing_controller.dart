import 'package:get/get.dart';
import 'package:medimaster/models/client_billing_model.dart';
import 'package:medimaster/services/api_service.dart';

class ClientBillingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final RxBool isLoading = false.obs;
  final RxList<ClientBillingModel> billings = <ClientBillingModel>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClientWiseBillings();
  }

  Future<void> fetchClientWiseBillings() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get('/Lab/GetClientWiseBillings');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        billings.value =
            data.map((json) => ClientBillingModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch client billings: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<ClientBillingModel> get filteredBillings {
    if (searchQuery.value.isEmpty) return billings;

    final query = searchQuery.value.toLowerCase();
    return billings.where((billing) {
      return billing.agentName.toLowerCase().contains(query) ||
          billing.billNo.toLowerCase().contains(query) ||
          billing.clientId.toString().contains(query);
    }).toList();
  }

  double get totalBasicAmount {
    return billings.fold(0, (sum, billing) => sum + billing.basicAmount);
  }

  double get totalDiscount {
    return billings.fold(0, (sum, billing) => sum + billing.discount);
  }

  double get totalNetAmount {
    return billings.fold(0, (sum, billing) => sum + billing.netAmount);
  }

  double get totalReceiptAmount {
    return billings.fold(0, (sum, billing) => sum + billing.receiptAmount);
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
