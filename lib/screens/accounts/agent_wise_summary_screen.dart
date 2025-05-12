import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medimaster/models/client_billing_detail_model.dart';
import 'package:medimaster/services/client_billing_service.dart';

class AgentWiseSummaryScreen extends StatefulWidget {
  const AgentWiseSummaryScreen({super.key});

  @override
  State<AgentWiseSummaryScreen> createState() => _AgentWiseSummaryScreenState();
}

class _AgentWiseSummaryScreenState extends State<AgentWiseSummaryScreen> {
  final RxBool isLoading = false.obs;
  final RxList<ClientBillingDetailModel> clientBillingData =
      <ClientBillingDetailModel>[].obs;
  final RxInt totalRecordCount = 0.obs;
  final numberFormat = NumberFormat("#,##0.00", "en_US");

  // Filter variables
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedAgentName = 'All Agents'.obs;
  final RxList<String> agentNames = <String>['All Agents'].obs;

  // Client billing totals
  final RxDouble clientTotalBasicAmount = 0.0.obs;
  final RxDouble clientTotalDiscount = 0.0.obs;
  final RxDouble clientTotalNetAmount = 0.0.obs;
  final RxDouble clientTotalReceiptAmount = 0.0.obs;

  late final ClientBillingService _clientBillingService;

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
    _clientBillingService = ClientBillingService(dio);

    _loadClientBillingData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClientBillingData() async {
    try {
      isLoading.value = true;
      final data = await _clientBillingService.getClientWiseBillingDetails();
      clientBillingData.assignAll(data);
      totalRecordCount.value = data.length;
      _calculateClientTotals();

      // Populate agent names for dropdown
      final Set<String> names = {'All Agents'};
      for (var item in clientBillingData) {
        names.add(item.agentName);
      }
      agentNames.assignAll(names.toList()..sort());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load client billing data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateClientTotals() {
    clientTotalBasicAmount.value =
        clientBillingData.fold(0, (sum, item) => sum + item.basicAmt);
    clientTotalDiscount.value =
        clientBillingData.fold(0, (sum, item) => sum + item.discount);
    clientTotalNetAmount.value =
        clientBillingData.fold(0, (sum, item) => sum + item.netAmt);
    clientTotalReceiptAmount.value =
        clientBillingData.fold(0, (sum, item) => sum + item.recieptAmt);
  }

  List<ClientBillingDetailModel> getFilteredData() {
    if (selectedAgentName.value == 'All Agents') {
      return clientBillingData;
    }

    return clientBillingData.where((billing) {
      return billing.agentName == selectedAgentName.value;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppConstantColors.labBackground,
      ),
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
                          'Loading client billing data...',
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
                          selectedAgentName.value == 'All Agents'
                              ? Icons.error_outline
                              : Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedAgentName.value == 'All Agents'
                              ? 'No client billing entries available'
                              : 'No matching client entries found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selectedAgentName.value == 'All Agents')
                          ElevatedButton.icon(
                            onPressed: _loadClientBillingData,
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
                  onRefresh: _loadClientBillingData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      return _buildClientBillingCard(filteredData[index]);
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
            'Agent Wise Billing Summary',
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
              'Showing ${filteredData.length} of ${totalRecordCount.value} records',
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
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedAgentName.value,
                                items: [
                                  DropdownMenuItem<String>(
                                    value: 'All Agents',
                                    child: Text('All Agents',
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                  ),
                                  ...agentNames
                                      .where((agent) => agent != 'All Agents')
                                      .map((agent) => DropdownMenuItem<String>(
                                            value: agent,
                                            child: Text(
                                              agent,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87),
                                            ),
                                          )),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    selectedAgentName.value = value;
                                    searchQuery.value =
                                        value == 'All Agents' ? '' : value;
                                  }
                                },
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.grey[600]),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                hint: Text('Select Agent',
                                    style: TextStyle(color: Colors.grey[600])),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'NPR ${numberFormat.format(amount)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildClientBillingCard(ClientBillingDetailModel billing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with bill number and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      billing.billNo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      billing.date,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${billing.miti})',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 16),

            // Patient details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 14, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              billing.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.perm_identity,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'ID: ${billing.patientId}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (billing.mobileNo != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    _launchPhoneCall(billing.mobileNo!),
                                child: Text(
                                  billing.mobileNo!,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${billing.age} ${billing.sex}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Agent and department
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.business,
                          size: 14, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Agent: ${billing.agentName}',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.local_hospital,
                          size: 14, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dept: ${billing.departmentName}',
                          style: TextStyle(
                            color: Colors.teal[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Referred by
            Row(
              children: [
                const Icon(Icons.medical_services, size: 14, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Referred by: ${billing.referdBy}',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Products/Services
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.science, size: 14, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tests: ${billing.products}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 16),

            // Amount details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountItem('Basic', billing.basicAmt, Colors.blue),
                _buildAmountItem('Disc', billing.discount, Colors.green),
                _buildAmountItem('Net', billing.netAmt, Colors.orange),
                _buildAmountItem(
                    'Receipt', billing.recieptAmt, AppConstantColors.labAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'NPR ${numberFormat.format(amount)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Function to launch phone call
  Future<void> _launchPhoneCall(String phoneNumber) async {
    // Ensure the phone number is in the correct format
    // Remove any potential spaces or special characters
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    // Try first with tel: scheme
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanedNumber);
    try {
      print('Attempting to launch phone dialer with: $phoneUri');

      if (await canLaunchUrl(phoneUri)) {
        final launched = await launchUrl(phoneUri);
        print('Phone dialer launch result: $launched');

        if (!launched) {
          // If the first method fails, try an alternative approach
          final fallbackUri = Uri.parse('tel:$cleanedNumber');
          print('Trying fallback method with: $fallbackUri');

          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri);
          } else {
            _showDialError(
                'Could not launch phone dialer. Please try dialing manually.');
          }
        }
      } else {
        print('canLaunchUrl returned false for $phoneUri');
        _showDialError(
            'Could not launch phone dialer. Please try dialing manually.');
      }
    } catch (e) {
      print('Error launching phone dialer: $e');
      _showDialError('Failed to open phone dialer: ${e.toString()}');
    }
  }

  // Helper to show error message
  void _showDialError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  }
} 