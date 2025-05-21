import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/models/agent_wise_summary_model.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentWiseSummaryScreen extends StatefulWidget {
  const AgentWiseSummaryScreen({super.key});

  @override
  State<AgentWiseSummaryScreen> createState() => _AgentWiseSummaryScreenState();
}

class _AgentWiseSummaryScreenState extends State<AgentWiseSummaryScreen> {
  final RxBool isLoading = false.obs;
  final RxList<ClientBillingDetailModel> billingData =
      <ClientBillingDetailModel>[].obs;
  final numberFormat = NumberFormat("#,##0.00", "en_US");

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt pageSize = 10.obs;
  final RxInt totalCount = 0.obs;
  final RxBool hasMoreData = true.obs;

  // Filter controllers
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedAgent = 'All'.obs;
  final RxString selectedDepartment = 'All'.obs;
  final RxString selectedDateRange = 'All Time'.obs;

  // Date range options
  final List<String> dateRanges = [
    'All Time',
    'Today',
    'This Week',
    'This Month',
    'Last Month',
  ];

  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing AgentWiseSummaryScreen');
    developer.log('Base URL: ${ApiConfig.baseUrl}');

    // Get the authentication token
    final token = GetStorage().read('token');
    developer.log('Auth Token: ${token != null ? 'Present' : 'Missing'}');

    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Add the token to headers
      },
    ));

    // Log Dio configuration
    developer.log('Dio Configuration:');
    developer.log('- Base URL: ${_dio.options.baseUrl}');
    developer.log('- Connect Timeout: ${_dio.options.connectTimeout}');
    developer.log('- Receive Timeout: ${_dio.options.receiveTimeout}');
    developer.log('- Send Timeout: ${_dio.options.sendTimeout}');
    developer.log('- Headers: ${_dio.options.headers}');

    _loadBillingData();
  }

  Future<void> _loadBillingData() async {
    try {
      const fullUrl = '${ApiConfig.baseUrl}${ApiConfig.agentWiswSummary}';
      developer.log('Starting API request');
      developer.log('Full API URL: $fullUrl');
      developer.log('Endpoint: ${ApiConfig.agentWiswSummary}');

      // Verify token before making request
      final token = GetStorage().read('token');
      if (token == null) {
        developer.log('Authentication Error: No token found');
        Get.snackbar(
          'Authentication Error',
          'Please login again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      isLoading.value = true;

      // Log request details
      developer.log('Request Details:');
      developer.log('- Method: GET');
      developer.log('- URL: $fullUrl');
      developer.log('- Headers: ${_dio.options.headers}');

      final response = await _dio.get(
        ApiConfig.agentWiswSummary,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Log response details
      developer.log('Response Details:');
      developer.log('- Status Code: ${response.statusCode}');
      developer.log('- Status Message: ${response.statusMessage}');
      developer.log('- Headers: ${response.headers}');
      developer.log('- Real URL: ${response.realUri}');

      if (response.statusCode == 200 && response.data != null) {
        developer.log('Response Data:');
        developer.log('- Type: ${response.data.runtimeType}');
        developer.log('- Content: ${response.data}');

        // Parse paginated response
        final Map<String, dynamic> responseData = response.data;
        developer.log('Parsing paginated response');

        // Update pagination info
        totalCount.value = responseData['totalCount'] ?? 0;
        currentPage.value = responseData['pageNumber'] ?? 1;
        totalPages.value = responseData['totalPages'] ?? 1;
        hasMoreData.value = responseData['hasNextPage'] ?? false;

        developer.log('Pagination Info:');
        developer.log('- Total Count: ${totalCount.value}');
        developer.log('- Current Page: ${currentPage.value}');
        developer.log('- Total Pages: ${totalPages.value}');
        developer.log('- Has More: ${hasMoreData.value}');

        // Parse items array
        final List<dynamic> items = responseData['items'] ?? [];
        developer.log('Items array length: ${items.length}');

        billingData.value = items.map((json) {
          try {
            final model = ClientBillingDetailModel.fromJson(json);
            developer.log('Record Parsed Successfully:');
            developer.log('- Bill No: ${model.billNo}');
            developer.log('- Patient: ${model.patientName}');
            developer.log('- Agent: ${model.agentName}');
            developer.log('- Department: ${model.departmentName}');
            developer.log('- Date: ${model.date}');
            developer.log('- Amount: ${model.netAmt}');
            return model;
          } catch (e, stackTrace) {
            developer.log(
              'Error parsing record',
              error: e,
              stackTrace: stackTrace,
            );
            developer.log('Failed JSON: $json');
            rethrow;
          }
        }).toList();

        developer.log('Data Loading Complete:');
        developer.log('- Total Records Loaded: ${billingData.length}');
        developer.log(
            '- First Record: ${billingData.isNotEmpty ? billingData.first.billNo : 'No records'}');
        developer.log(
            '- Last Record: ${billingData.isNotEmpty ? billingData.last.billNo : 'No records'}');
      } else {
        developer.log('API Error Response:');
        developer.log('- Status Code: ${response.statusCode}');
        developer.log('- Data: ${response.data}');

        Get.snackbar(
          'Error',
          'Invalid response from server (Status: ${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } on DioException catch (e) {
      developer.log(
        'API Request Failed',
        error: e,
        stackTrace: e.stackTrace,
      );
      developer.log('Error Details:');
      developer.log('- Type: ${e.runtimeType}');
      developer.log('- Message: ${e.message}');
      developer.log('- Status Code: ${e.response?.statusCode}');
      developer.log('- Response Data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        Get.snackbar(
          'Authentication Error',
          'Please login again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load billing data: ${e.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Error',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
      developer.log('API Request Completed');
    }
  }

  List<ClientBillingDetailModel> getFilteredData() {
    developer.log('Starting data filtering');
    developer.log('Total records before filtering: ${billingData.length}');

    var filtered = billingData.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      developer.log('Applying search filter: ${searchQuery.value}');
      filtered = filtered.where((item) {
        return item.patientName
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            item.billNo
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            item.agentName
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }).toList();
      developer.log('Records after search filter: ${filtered.length}');
    }

    // Apply agent filter
    if (selectedAgent.value != 'All') {
      developer.log('Applying agent filter: ${selectedAgent.value}');
      filtered = filtered
          .where((item) => item.agentName == selectedAgent.value)
          .toList();
      developer.log('Records after agent filter: ${filtered.length}');
    }

    // Apply department filter
    if (selectedDepartment.value != 'All') {
      developer.log('Applying department filter: ${selectedDepartment.value}');
      filtered = filtered
          .where((item) => item.departmentName == selectedDepartment.value)
          .toList();
      developer.log('Records after department filter: ${filtered.length}');
    }

    // Apply date range filter
    if (selectedDateRange.value != 'All Time') {
      developer.log('Applying date range filter: ${selectedDateRange.value}');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      filtered = filtered.where((item) {
        try {
          final itemDate = DateTime.parse(item.date);
          bool matches = false;

          switch (selectedDateRange.value) {
            case 'Today':
              matches = itemDate.isAtSameMomentAs(today);
              break;
            case 'This Week':
              final weekStart =
                  today.subtract(Duration(days: today.weekday - 1));
              matches =
                  itemDate.isAfter(weekStart.subtract(const Duration(days: 1)));
              break;
            case 'This Month':
              matches =
                  itemDate.year == today.year && itemDate.month == today.month;
              break;
            case 'Last Month':
              final lastMonth = today.month == 1
                  ? DateTime(today.year - 1, 12, 1)
                  : DateTime(today.year, today.month - 1, 1);
              matches = itemDate.year == lastMonth.year &&
                  itemDate.month == lastMonth.month;
              break;
            default:
              matches = true;
          }

          return matches;
        } catch (e) {
          developer.log('Error parsing date for item ${item.billNo}: $e',
              error: e);
          return false;
        }
      }).toList();

      developer.log('Records after date range filter: ${filtered.length}');
    }

    developer.log('Final filtered records count: ${filtered.length}');
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      appBar: AppBar(
        title: const Text('Agent-wise Summary'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Basic search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200]!,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search by agent name...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (searchQuery.value.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: () {
                                  searchQuery.value = '';
                                  searchController.clear();
                                },
                              ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.filter_list,
                                color: Colors.grey[600],
                                size: 22,
                              ),
                              onSelected: (String value) {
                                searchController.text = value;
                                searchQuery.value = value;
                              },
                              itemBuilder: (BuildContext context) {
                                final agents = [
                                  'All',
                                  ...billingData
                                      .map((e) => e.agentName)
                                      .toSet()
                                      .toList()
                                ];
                                return agents.map((String agent) {
                                  return PopupMenuItem<String>(
                                    value: agent,
                                    child: Text(
                                      agent,
                                      style: TextStyle(
                                        color: agent == searchQuery.value
                                            ? Theme.of(context).primaryColor
                                            : Colors.black87,
                                        fontWeight: agent == searchQuery.value
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        searchQuery.value = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transaction list
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredData = getFilteredData();

              if (filteredData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No billing data found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  return _buildBillingCard(filteredData[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCard(ClientBillingDetailModel billing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with bill number and date
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Bill #${billing.billNo}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            billing.date,
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '| मिति: ${billing.miti}',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getDayName(billing.date),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getTimeAgo(billing.date),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 12),

            // Patient Details Section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Patient name and basic info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 13, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                billing.patientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildInfoChip('Age: ${billing.age}'),
                            _buildInfoChip('Sex: ${billing.sex}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right side - ID and Mobile
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'ID: ${billing.patientId}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (billing.mobileNo != null) ...[
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _launchPhoneCall(billing.mobileNo!),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone,
                                  size: 13, color: Colors.blue[700]),
                              const SizedBox(width: 2),
                              Text(
                                billing.mobileNo!,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Agent and Department Details Section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 13, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Agent: ${billing.agentName}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (billing.referdBy.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.medical_services,
                            size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Ref: ${billing.referdBy}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.business, size: 13, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Dept: ${billing.departmentName}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (billing.products.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.science, size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Products: ${billing.products}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Amount Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountItem('Basic', billing.basicAmt, Colors.blue),
                  _buildAmountItem('Discount', billing.discount, Colors.green),
                  _buildAmountItem('Net', billing.netAmt, Colors.orange),
                  _buildAmountItem(
                      'Receipt', billing.recieptAmt, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildAmountItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'NPR ${numberFormat.format(amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        developer.log('Empty phone number provided');
        return;
      }

      // Clean the phone number - remove any spaces, dashes, or other non-digit characters
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // If number starts with 0, remove it
      if (cleanNumber.startsWith('0')) {
        cleanNumber = cleanNumber.substring(1);
      }

      developer.log('Attempting to dial: $cleanNumber');

      // Try multiple URI formats
      final List<Uri> uriToTry = [
        Uri.parse('tel:$cleanNumber'),
        Uri(scheme: 'tel', path: cleanNumber),
        Uri.parse('tel://$cleanNumber'),
      ];

      bool launched = false;
      for (final uri in uriToTry) {
        try {
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.externalNonBrowserApplication,
            );
            if (launched) {
              developer.log('Successfully launched with URI: $uri');
              break;
            }
          }
        } catch (e) {
          developer.log('Failed to launch with URI: $uri, Error: $e');
          continue;
        }
      }

      if (!launched) {
        // Fallback to basic tel: URI with no formatting
        final basicUri = Uri.parse('tel:$phoneNumber');
        launched = await launchUrl(
          basicUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      }

      if (!launched) {
        developer.log('All attempts to launch dialer failed');
        Get.snackbar(
          'Error',
          'Could not open dial pad',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error launching phone call',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Error',
        'Could not open dial pad',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 2),
      );
    }
  }

  String _getDayName(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length == 3) {
        final dateObj = DateTime.parse(
          '2024-${_getMonthNumber(parts[1])}-${parts[0].padLeft(2, '0')}',
        );
        final weekdays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        return '(${weekdays[dateObj.weekday - 1]})';
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return '';
  }

  String _getTimeAgo(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length == 3) {
        final dateObj = DateTime.parse(
          '2024-${_getMonthNumber(parts[1])}-${parts[0].padLeft(2, '0')}',
        );
        final today = DateTime.now();
        final difference = today.difference(dateObj).inDays;

        if (difference == 0) {
          return 'Today';
        } else if (difference == 1) {
          return 'Yesterday';
        } else if (difference < 7) {
          return '$difference days ago';
        }
      }
    } catch (e) {
      print('Error calculating time ago: $e');
    }
    return '';
  }

  String _getMonthNumber(String monthName) {
    final months = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'May': '05',
      'Jun': '06',
      'Jul': '07',
      'Aug': '08',
      'Sep': '09',
      'Oct': '10',
      'Nov': '11',
      'Dec': '12',
    };
    return months[monthName] ?? '01';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
