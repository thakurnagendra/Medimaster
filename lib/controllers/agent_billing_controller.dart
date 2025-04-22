import 'package:get/get.dart';
import 'package:medimaster/models/agent_billing_model.dart';
import 'package:medimaster/services/agent_billing_service.dart';

class AgentBillingController extends GetxController {
  final AgentBillingService _agentBillingService = AgentBillingService();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<AgentBillingModel> billingData = <AgentBillingModel>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreData = true.obs;

  // Filter variables
  final RxString selectedAgentId = ''.obs;
  final RxString selectedStatus = ''.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);

  // Statistics
  final RxDouble totalBilling = 0.0.obs;
  final RxDouble totalCommission = 0.0.obs;
  final RxInt totalTests = 0.obs;
  final RxInt totalPatients = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAgentBillingData();
  }

  Future<void> loadAgentBillingData({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      billingData.clear();
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;

      // Get billing data
      final result = await _agentBillingService.getAgentBilling(
        pageNumber: currentPage.value,
        pageSize: 10,
        agentId: selectedAgentId.value,
        fromDate: fromDate.value?.toIso8601String(),
        toDate: toDate.value?.toIso8601String(),
        status: selectedStatus.value,
      );

      if (isRefresh) {
        billingData.clear();
      }

      billingData.addAll(result.items);
      totalPages.value = result.totalPages;
      hasMoreData.value = result.hasNextPage;

      // Get statistics
      final stats = await _agentBillingService.getAgentBillingStatistics(
        agentId: selectedAgentId.value,
        fromDate: fromDate.value?.toIso8601String(),
        toDate: toDate.value?.toIso8601String(),
      );

      totalBilling.value = (stats['totalBilling'] as num?)?.toDouble() ?? 0.0;
      totalCommission.value =
          (stats['totalCommission'] as num?)?.toDouble() ?? 0.0;
      totalTests.value = (stats['totalTests'] as num?)?.toInt() ?? 0;
      totalPatients.value = (stats['totalPatients'] as num?)?.toInt() ?? 0;
    } catch (e) {
      print('Error loading agent billing data: $e');
      Get.snackbar(
        'Error',
        'Failed to load agent billing data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    await loadAgentBillingData();
  }

  void setAgentFilter(String agentId) {
    selectedAgentId.value = agentId;
    loadAgentBillingData(isRefresh: true);
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    loadAgentBillingData(isRefresh: true);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    fromDate.value = start;
    toDate.value = end;
    loadAgentBillingData(isRefresh: true);
  }

  void clearFilters() {
    selectedAgentId.value = '';
    selectedStatus.value = '';
    fromDate.value = null;
    toDate.value = null;
    loadAgentBillingData(isRefresh: true);
  }

  String formatCurrency(double amount) {
    if (amount >= 100000) {
      return 'Rs. ${(amount / 100000).toStringAsFixed(2)}L';
    } else {
      return 'Rs. ${amount.toStringAsFixed(0)}';
    }
  }
}
