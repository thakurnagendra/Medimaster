import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/models/credit_list_model.dart';
import 'package:medimaster/services/credit_list_service.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LabReportMenuCreditListScreen extends StatefulWidget {
  const LabReportMenuCreditListScreen({super.key});

  @override
  State<LabReportMenuCreditListScreen> createState() =>
      _LabReportMenuCreditListScreenState();
}

class _LabReportMenuCreditListScreenState
    extends State<LabReportMenuCreditListScreen> {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<CreditListModel> creditData = <CreditListModel>[].obs;
  final ScrollController _scrollController = ScrollController();
  final currencyFormat = NumberFormat.currency(
    symbol: 'NPR ',
    decimalDigits: 2,
    locale: 'en_US',
  );

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;
  final RxBool hasMoreData = true.obs;

  // Filter variables
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Add expandedCardIndex at class level
  final RxInt expandedCardIndex = RxInt(-1);

  late final CreditListService _creditListService;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
    _creditListService = CreditListService(dio);
    _setupScrollController();
    _loadCreditData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Credits',
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
            ),
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
                          'Loading credit list...',
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
                              ? 'No credit entries available'
                              : 'No matching credit entries found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (searchQuery.value.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _loadCreditData,
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
                  onRefresh: _loadCreditData,
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredData.length +
                            (hasMoreData.value && searchQuery.value.isEmpty
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredData.length &&
                              hasMoreData.value &&
                              searchQuery.value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _buildCreditCard(filteredData[index], index);
                        },
                      ),
                      if (isLoadingMore.value && searchQuery.value.isEmpty)
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: 6,
                            child: LinearProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
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
              hintText: 'Search by name, ID or mobile...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: Obx(
                () => searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchQuery.value = '';
                          // Reset pagination when clearing search
                          currentPage.value = 1;
                          hasMoreData.value = true;
                          _loadCreditData();
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
              // Disable pagination during search
              hasMoreData.value = false;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(CreditListModel credit, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    credit.pName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          credit.pAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          // Use url_launcher to open the dial pad with the phone number
                          if (credit.pMobile.isNotEmpty) {
                            final Uri telUri =
                                Uri(scheme: 'tel', path: credit.pMobile);
                            launchUrl(telUri);
                          }
                        },
                        child: Text(
                          credit.pMobile ?? 'No mobile number',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Total Credit',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  currencyFormat.format(credit.totalCredit),
                  style: const TextStyle(
                    color: AppConstantColors.labAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreData();
      }
    });
  }

  Future<void> _loadMoreData() async {
    if (!isLoadingMore.value &&
        hasMoreData.value &&
        !isLoading.value &&
        searchQuery.value.isEmpty) {
      try {
        isLoadingMore.value = true;
        developer.log('Loading more data... Page: ${currentPage.value + 1}');

        final newData = await _creditListService.getCreditList(
          pageNumber: currentPage.value + 1,
          pageSize: pageSize,
        );

        if (newData.isEmpty) {
          hasMoreData.value = false;
        } else {
          creditData.addAll(newData);
          currentPage.value++;
        }
      } catch (e) {
        developer.log('Error loading more data: $e');
        Get.snackbar(
          'Error',
          'Failed to load more items',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      } finally {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> _loadCreditData() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;
      developer.log('Starting to load credit data...');

      final data = await _creditListService.getCreditList(
        pageNumber: currentPage.value,
        pageSize: pageSize,
      );

      if (data.isEmpty) {
        hasMoreData.value = false;
        creditData.clear();

        // Add test data only if it's the first page and no data is returned
        final testData = CreditListModel(
          id: 1,
          pCode: 'TEST001',
          pName: 'Test Patient',
          pAddress: 'Test Address',
          age: 30,
          active: true,
          ageGender: '30/M',
          balance: 1000,
          serviceBillCredit: 500,
          pharmacyCredit: 500,
          totalCredit: 1000,
          receipt: 0,
          payment: 0,
          pMobile: '9876543210',
          recCount: 1,
        );
        creditData.add(testData);

        Get.snackbar(
          'Using Test Data',
          'No records found from API, displaying test data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          duration: const Duration(seconds: 3),
        );
      } else {
        creditData.assignAll(data);
      }
    } catch (e) {
      developer.log('Error in _loadCreditData: $e');
      String errorMessage = 'Error';
      String errorDetails = e.toString();
      bool shouldShowRetry = true;
      Color backgroundColor = Colors.red[100]!;
      Color textColor = Colors.red[900]!;

      if (errorDetails.contains('Session expired') ||
          errorDetails.contains('401')) {
        errorMessage = 'Session Expired';
        errorDetails = 'Please log in again to continue';
        shouldShowRetry = false;
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed('/login');
        });
      } else if (errorDetails.contains('Connection timed out') ||
          errorDetails.contains('Connection error') ||
          errorDetails.contains('Network error')) {
        errorMessage = 'Connection Error';
        errorDetails = 'Please check your internet connection and try again';
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
      } else if (errorDetails.contains('403') ||
          errorDetails.contains('permission')) {
        errorMessage = 'Access Denied';
        errorDetails = 'You do not have permission to view credit list';
        shouldShowRetry = false;
      } else if (errorDetails.contains('500') ||
          errorDetails.contains('Server error')) {
        errorMessage = 'Server Error';
        errorDetails =
            'The server encountered an error. Please try again later.';
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
      }

      Get.snackbar(
        errorMessage,
        errorDetails,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: textColor,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.error_outline, color: Colors.red),
        mainButton: shouldShowRetry
            ? TextButton(
                onPressed: _loadCreditData,
                child: Text('Retry', style: TextStyle(color: textColor)),
              )
            : null,
      );

      // Use test data in case of error
      developer.log('Using test data due to API error');
      final testData = CreditListModel(
          id: 1,
          pCode: 'TEST001',
          pName: 'Test Patient',
          pAddress: 'Test Address',
          age: 30,
          active: true,
          ageGender: '30/M',
          balance: 1000,
          serviceBillCredit: 500,
          pharmacyCredit: 500,
          totalCredit: 1000,
          receipt: 0,
          payment: 0,
          pMobile: '9876543210',
          recCount: 1);
      creditData.assignAll([testData]);
    } finally {
      isLoading.value = false;
    }
  }

  List<CreditListModel> getFilteredData() {
    if (searchQuery.value.isEmpty) {
      return creditData;
    }

    final query = searchQuery.value.toLowerCase();
    return creditData.where((credit) {
      return credit.pName.toLowerCase().contains(query) ||
          credit.pCode.toLowerCase().contains(query) ||
          (credit.pMobile.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
