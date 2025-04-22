import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/models/agent_billing_summary_model.dart';
import 'package:medimaster/services/agent_billing_summary_service.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:intl/intl.dart';

class AgentWiseBillingScreen extends StatefulWidget {
  const AgentWiseBillingScreen({super.key});

  @override
  State<AgentWiseBillingScreen> createState() => _AgentWiseBillingScreenState();
}

class _AgentWiseBillingScreenState extends State<AgentWiseBillingScreen> {
  final RxBool isLoading = false.obs;
  final RxList<AgentBillingSummaryModel> billingData =
      <AgentBillingSummaryModel>[].obs;
  final numberFormat = NumberFormat("0", "en_US");

  // Filter variables
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  late final AgentBillingSummaryService _billingSummaryService;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _billingSummaryService = AgentBillingSummaryService(dio);
    _loadBillingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterSection(),
            Expanded(
              child: Obx(() {
                final filteredData = getFilteredData();

                if (isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading billing data...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.value.isEmpty
                              ? Icons.error_outline
                              : Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.value.isEmpty
                              ? 'No billing entries available'
                              : 'No matching billing entries found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (searchQuery.value.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _loadBillingData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry Loading'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstantColors.labAccent,
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadBillingData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      return _buildBillingCard(filteredData[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agent Wise Billing Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final filteredData = getFilteredData();
            return Text(
              'Showing ${filteredData.length} records',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by agent name...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: Obx(
                () => searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchQuery.value = '';
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppConstantColors.labAccent,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              searchQuery.value = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCard(AgentBillingSummaryModel billing) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    billing.agentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!, width: 0.5),
                  ),
                  child: Text(
                    '#${billing.bBillNo}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
            // Amounts Section
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 300;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left side amounts
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            // Basic and Discount
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAmountRow(
                                    'Basic',
                                    billing.bBasicAmt,
                                    Colors.blue[700]!,
                                    isNarrow,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildAmountRow(
                                    'Net',
                                    billing.bNetAmt,
                                    Colors.orange[700]!,
                                    isNarrow,
                                  ),
                                ],
                              ),
                            ),
                            VerticalDivider(
                              width: 12,
                              thickness: 0.5,
                              color: Colors.grey[200],
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAmountRow(
                                    'Disc',
                                    billing.discount,
                                    Colors.green[700]!,
                                    isNarrow,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildAmountRow(
                                    'Rcpt',
                                    billing.bRecieptAmt,
                                    Colors.purple[700]!,
                                    isNarrow,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Vertical divider
                      VerticalDivider(
                        width: 12,
                        thickness: 0.5,
                        color: Colors.grey[300],
                      ),
                      // Total
                      Container(
                        width: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstantColors.labAccent
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'NPR ${numberFormat.format(billing.recieptAmount)}',
                                  style: const TextStyle(
                                    color: AppConstantColors.labAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
      String label, double amount, Color color, bool isNarrow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'NPR ${numberFormat.format(amount)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadBillingData() async {
    try {
      isLoading.value = true;
      developer.log('Loading billing data...');
      final data = await _billingSummaryService.getAgentBillingSummary();
      developer.log('Received data: ${data.length} items');
      if (data.isNotEmpty) {
        developer.log('First item: ${data.first.agentName}');
      }
      billingData.assignAll(data);
      developer.log('Data assigned to billingData');
    } catch (e) {
      developer.log('Error in _loadBillingData: $e');
      String errorMessage = 'Failed to load billing data';
      String errorDetails = '';
      bool shouldRedirectToLogin = false;

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Connection Timeout';
            errorDetails = 'Please check your internet connection';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'No Internet Connection';
            errorDetails = 'Please check your internet connection';
            break;
          case DioExceptionType.badResponse:
            if (e.response?.statusCode == 401) {
              errorMessage = 'Session Expired';
              errorDetails = 'Please login again';
              shouldRedirectToLogin = true;
            } else if (e.response?.statusCode == 403) {
              errorMessage = 'Access Denied';
              errorDetails =
                  'You don\'t have permission to access this feature';
            } else {
              errorMessage = 'Server Error';
              errorDetails = 'Something went wrong. Please try again later.';
            }
            break;
          default:
            if (e.toString().contains('Authentication token not found')) {
              errorMessage = 'Not Logged In';
              errorDetails = 'Please login to continue';
              shouldRedirectToLogin = true;
            } else {
              errorMessage = 'Error';
              errorDetails = 'Something went wrong. Please try again.';
            }
        }
      }

      Get.snackbar(
        errorMessage,
        errorDetails,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );

      if (shouldRedirectToLogin) {
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed('/login');
        });
      }

      // Add test data in case of error for development
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        billingData.add(AgentBillingSummaryModel(
          id: 16,
          agentName: "MediMaster6",
          clientId: 27,
          bBillNo: "42",
          bBasicAmt: 57055.00,
          discount: 2420.00,
          bNetAmt: 54635.00,
          bRecieptAmt: 42915.00,
          recieptAmount: 106870.00,
        ));
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<AgentBillingSummaryModel> getFilteredData() {
    final data = billingData;
    developer.log('Filtering data. Current items: ${data.length}');
    if (searchQuery.value.isEmpty) {
      return data;
    }

    final query = searchQuery.value.toLowerCase();
    final filtered = data.where((billing) {
      return billing.agentName.toLowerCase().contains(query);
    }).toList();
    developer.log('Filtered items: ${filtered.length}');
    return filtered;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
