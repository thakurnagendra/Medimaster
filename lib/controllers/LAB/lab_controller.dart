import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medimaster/services/investigation_service.dart';
import 'package:medimaster/models/reference_data_model.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/test_model.dart';

class LabController extends GetxController {
  // Method to fetch patient details by investigation ID
  Future<void> fetchPatientByInvestigationId(String investigationId) async {
    try {
      print('DEBUG: Fetching details for Patient ID: $investigationId');
      final response =
          await _investigationService.getInvestigationById(investigationId);

      print('DEBUG: API Response received');
      print('DEBUG: Total items in response: ${response.items.length}');

      if (response.items.isNotEmpty) {
        final investigation = response.items.first;

        print('\n=== Patient Details (ID: $investigationId) ===');
        print('Patient ID (System): ${investigation.id}');
        print('Patient ID (Medical): ${investigation.bPatientId ?? 'N/A'}');
        print('Patient Name: ${investigation.bName ?? 'N/A'}');
        print('Bill Number: ${investigation.bBillNo ?? 'N/A'}');
        print('Sample Count: ${investigation.sampleCount}');
        print('\nPersonal Information:');
        print('Age: ${investigation.bAge ?? 'N/A'}');
        print('Sex: ${investigation.bSex ?? 'N/A'}');
        print('Address: ${investigation.bAddress ?? 'N/A'}');
        print('Mobile: ${investigation.bMobileNo ?? 'N/A'}');
        print('\nDates:');
        print('Visit Date: ${investigation.bDate ?? 'N/A'}');
        print('Nepali Date: ${investigation.bMiti ?? 'N/A'}');
        print('========================\n');
      } else {
        print('No patient found with Patient ID: $investigationId');
      }
    } catch (e) {
      print('Error fetching patient details: $e');
    }
  }

  // We're keeping these for compatibility, but the dropdown is being removed from UI
  final RxString selectedTimePeriod = 'This Week'.obs;
  final List<String> timePeriods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
  ];

  // Method to fetch test details by ID
  Future<List<TestModel>> getTestDetailsById(String testId) async {
    try {
      final response =
          await apiService.get('${ApiConfig.getTestNameById}$testId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => TestModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching test details: $e');
      return [];
    }
  }

  // Method to print testId for a specific patient
  Future<void> printPatientInvestigationDetails(String patientName) async {
    try {
      print('DEBUG: Starting investigation fetch...');
      final response = await _investigationService.getInvestigations(
        searchTerm: patientName,
        pageSize: 1, // We only need one result
      );

      print('DEBUG: API Response received');
      print('DEBUG: Total items in response: ${response.items.length}');

      if (response.items.isNotEmpty) {
        final investigation = response.items.first;

        // Debug raw data
        print('\nDEBUG: Raw investigation data:');
        print('DEBUG: Actual ID (id) = ${investigation.id}');
        print('DEBUG: Bill Number (bBillNo) = ${investigation.bBillNo}');
        print('DEBUG: Patient ID (bPatientId) = ${investigation.bPatientId}');
        print('DEBUG: Patient Name (bName) = ${investigation.bName}');
        print('DEBUG: Test ID (testId) = ${investigation.testId}');

        // Formatted output
        print('\n=== Investigation Details ===');
        print('Patient Name: ${investigation.bName ?? patientName}');
        print('Actual ID: ${investigation.id}');
        print('Bill Number: ${investigation.bBillNo}');
        print('Patient ID: ${investigation.bPatientId}');
        print('========================\n');
      } else {
        print('DEBUG: No items found in response');
        print('No investigation found for patient: $patientName');
      }
    } catch (e) {
      print('DEBUG: Error occurred: $e');
      print('Error fetching investigation details: $e');
    }
  }

  // Statistics
  final RxString totalTests = '0'.obs;
  final RxString completedTests = '0'.obs;
  final RxString pendingTests = '0'.obs;
  final RxString todayTests = '0'.obs;

  // Recent tests
  final RxList<Map<String, dynamic>> recentTests = <Map<String, dynamic>>[].obs;

  // All recent tests (larger dataset for the all tests screen)
  final RxList<Map<String, dynamic>> allRecentTests =
      <Map<String, dynamic>>[].obs;

  // Pending reports
  final List<Map<String, dynamic>> pendingReports = [
    {'id': '10045', 'testType': 'Blood Test', 'dueIn': '1 hour(s)'},
    {'id': '10046', 'testType': 'Urine Test', 'dueIn': '2 hour(s)'},
    {'id': '10047', 'testType': 'X-Ray', 'dueIn': '3 hour(s)'},
  ];

  // GetStorage instance for persistent storage
  final GetStorage storage = GetStorage();

  // Reactive variables
  final RxList filteredRecentTests = [].obs;

  // Reactive variables for billing
  final RxString todayRevenue = 'Rs. 0'.obs;
  final RxString weeklyRevenue = 'Rs. 0'.obs;
  final RxString monthlyRevenue = 'Rs. 0'.obs;
  final RxString pendingPayments = 'Rs. 0'.obs;
  final RxString outstandingAmount = 'Rs. 0'.obs;
  final RxString revenueGrowth = '0%'.obs;
  final RxList revenueData = [].obs;
  final RxDouble maxRevenue = 0.0.obs;
  final RxInt pendingInvoices = 0.obs;
  final RxInt outstandingInvoices = 0.obs;
  final RxList<String> revenueLabels = <String>[].obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt pageSize = 10.obs;
  final RxInt totalCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;

  // Investigation service
  final InvestigationService _investigationService = InvestigationService();
  final ApiService _apiService;

  // Test list
  final RxList<TestModel> testList = <TestModel>[].obs;
  final RxBool isLoadingTests = false.obs;

  LabController({ApiService? apiService})
      : _apiService = apiService ?? Get.find<ApiService>();

  // Method to get API service
  ApiService get apiService => _apiService;

  // Reference data
  final Rx<ReferenceData?> referenceData = Rx<ReferenceData?>(null);
  final RxList<Department> departments = <Department>[].obs;
  final RxList<Agent> agents = <Agent>[].obs;
  final RxList<Doctor> doctors = <Doctor>[].obs;

  // Filter states
  final RxString selectedDepartmentId = ''.obs;
  final RxString selectedAgentId = ''.obs;
  final RxString selectedDoctorId = ''.obs;

  // Billing statistics
  final RxInt todayBillCount = 0.obs;
  final RxDouble todayBillAmount = 0.0.obs;
  final RxInt weekBillCount = 0.obs;
  final RxDouble weekBillAmount = 0.0.obs;
  final RxInt monthBillCount = 0.obs;
  final RxDouble monthBillAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize revenue data with default values
    revenueData.value = [12000, 18000, 15000, 22000, 19000, 26000, 28000];
    revenueLabels.value = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    maxRevenue.value = 30000;

    // First, fetch reference data
    fetchReferenceData().then((_) {
      // After reference data is loaded, fetch tests
      _fetchRecentTests(
        dateFilter: getDateFilterForTimePeriod(),
        pageNumber: 1,
        pageSize: 10, // Changed from 5 to 10 to meet API requirements
      );
    });

    // Update statistics
    updateStatistics();
    updateBillingStatistics();
  }

  // Load recent tests from API
  Future<void> _fetchRecentTests({
    required String dateFilter,
    required int pageNumber,
    required int pageSize,
    String doctorId = '',
    String agent = '',
  }) async {
    print('_fetchRecentTests called with doctorId: $doctorId, agent: $agent');

    // Store current data for potential rollback
    final previousAllRecentTests = List<Map<String, dynamic>>.from(
      allRecentTests,
    );
    final previousFilteredRecentTests = List<Map<String, dynamic>>.from(
      filteredRecentTests,
    );

    // Only set loading to true if we don't already have data
    if (allRecentTests.isEmpty) {
      isLoading.value = true;
    }

    try {
      final response = await _investigationService.getInvestigations(
        dateFilter: dateFilter,
        pageNumber: pageNumber,
        pageSize: pageSize,
        doctorId: doctorId,
        agent: agent,
      );

      // Update pagination data
      totalPages.value = response.totalPages;
      currentPage.value = response.pageNumber;
      totalCount.value = response.totalCount;
      hasMoreData.value = response.hasNextPage;

      // Convert Investigation items to Map format expected by UI
      final tests =
          response.items.map((test) => test.toDisplayFormat()).toList();

      // Only update if we got valid data
      if (tests.isNotEmpty) {
        // Update recent tests
        allRecentTests.value = tests;
        filteredRecentTests.value = tests;
        print('Successfully updated tests data with ${tests.length} items');
      } else if (allRecentTests.isEmpty) {
        // Only generate mock data if we have no existing data
        print('API returned empty data, falling back to mock data');
        _generateMockData();
      } else {
        // Keep existing data if API returns empty but we already have data
        print(
          'API returned empty data, keeping existing ${allRecentTests.length} items',
        );
      }
    } catch (e) {
      print('Error fetching recent tests: $e');

      // Rollback to previous data if we had any
      if (previousAllRecentTests.isNotEmpty) {
        print(
          'Rolling back to previous data with ${previousAllRecentTests.length} items',
        );
        allRecentTests.value = previousAllRecentTests;
        filteredRecentTests.value = previousFilteredRecentTests;
      } else if (allRecentTests.isEmpty) {
        // Only generate mock data if we have no existing data
        print('No previous data available, falling back to mock data');
        _generateMockData();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all tests with pagination for view all page
  Future<void> fetchAllTests({
    String doctorId = '',
    String agent = '',
    String status = '',
    String searchTerm = '',
    String fromDate = '',
    String toDate = '',
    bool resetPage = true,
  }) async {
    print('Fetching all tests with parameters:');
    print('- doctorId: $doctorId');
    print('- agent: $agent');
    print('- status: $status');
    print('- searchTerm: $searchTerm');
    print('- fromDate: $fromDate');
    print('- toDate: $toDate');
    print('- resetPage: $resetPage');

    // Handle the status parameter mapping to match API expectations
    String apiStatus = '';
    if (status.isNotEmpty) {
      // Convert status string to numerical codes expected by API
      apiStatus = status == 'Pending'
          ? '0'
          : status == 'In Progress'
              ? '1'
              : status == 'Completed'
                  ? '2'
                  : status == 'Canceled'
                      ? '3'
                      : '';
      print('Mapped status text "$status" to API status code: "$apiStatus"');
    }

    if (resetPage) {
      currentPage.value = 1;
      allRecentTests.clear();
      filteredRecentTests.clear();
    }

    try {
      isLoading.value = true;

      final response = await _investigationService.getInvestigations(
        dateFilter: getDateFilterForTimePeriod(),
        pageNumber: currentPage.value,
        pageSize: pageSize.value,
        doctorId: doctorId,
        agent: agent,
        status: apiStatus, // Use the numerical status code
        searchTerm: searchTerm,
        fromDate: fromDate,
        toDate: toDate,
      );

      print(
        'API response - total count: ${response.totalCount}, page: ${response.pageNumber}/${response.totalPages}',
      );

      // Update pagination data
      totalPages.value = response.totalPages;
      totalCount.value = response.totalCount;
      hasMoreData.value = response.hasNextPage;

      // Convert Investigation items to Map format expected by UI
      final tests =
          response.items.map((test) => test.toDisplayFormat()).toList();
      print('\nReceived ${tests.length} tests from API');

      // Print all patient details
      print('All Patients:');
      for (var test in tests) {
        print(
            'Patient: ${test['patientName']} (ID: ${test['id']}) - ${test['testType']} - Status: ${test['status']}');
      }
      print('');

      // If loading more data, append to existing list
      if (resetPage) {
        allRecentTests.value = tests;
      } else {
        allRecentTests.addAll(tests);
      }

      filteredRecentTests.value = [...allRecentTests];

      // Double-check if we need to filter locally as well
      if (status.isNotEmpty && status != 'All') {
        print('Additional local filtering for status: $status');
        filteredRecentTests.value = allRecentTests
            .where(
              (test) =>
                  test['status'].toString().toLowerCase() ==
                  status.toLowerCase(),
            )
            .toList();
      }

      // Apply local date filtering if needed
      if (fromDate.isNotEmpty || toDate.isNotEmpty) {
        // Convert date strings back to DateTime objects for local filtering
        DateTime? fromDateTime;
        DateTime? toDateTime;

        try {
          if (fromDate.isNotEmpty) {
            fromDateTime = DateTime.parse(fromDate);
          }
          if (toDate.isNotEmpty) {
            toDateTime = DateTime.parse(toDate);
          }

          // Apply additional local date filtering
          if (fromDateTime != null || toDateTime != null) {
            _applyLocalDateFilter(fromDateTime, toDateTime);
          }
        } catch (e) {
          print('Error parsing dates for local filtering: $e');
        }
      }

      print(
        'Updated filteredRecentTests with ${filteredRecentTests.length} items',
      );
    } catch (e) {
      print('Error fetching all tests: $e');
      if (allRecentTests.isEmpty) {
        // Show error state instead of fallback to mock data
        print('Error fetching data from API, no fallback available');
        allRecentTests.value = [];
        filteredRecentTests.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Get date filter for current time period
  String getDateFilterForTimePeriod() {
    // Always use the fixed time period
    return selectedTimePeriod.value;
  }

  // Load recent tests for home dashboard
  Future<void> loadRecentTests() async {
    try {
      await _fetchRecentTests(
        dateFilter: getDateFilterForTimePeriod(),
        pageNumber: 1,
        pageSize: 10, // Changed from 5 to 10 to meet API requirements
        doctorId: selectedDoctorId.value,
        agent: selectedAgentId.value,
      );
    } catch (e) {
      print('Error loading recent tests: $e');
      // No fallback to mock data
      allRecentTests.value = [];
      filteredRecentTests.value = [];
    }
  }

  // Load more data for pagination
  Future<void> loadMore() async {
    if (!isLoading.value && hasMoreData.value) {
      print('Loading more data (page ${currentPage.value + 1})');
      currentPage.value++;

      // Get the current filter values
      final doctorIdParam =
          selectedDoctorId.value.isEmpty ? '' : selectedDoctorId.value;
      final agentIdParam =
          selectedAgentId.value.isEmpty ? '' : selectedAgentId.value;

      // Get current status filter
      String statusFilter = '';
      try {
        final statusVariable = Get.find<RxString>(tag: 'statusFilter');
        if (statusVariable.value != 'All') {
          statusFilter = statusVariable.value;
          print('Found status filter for pagination: $statusFilter');
        }
      } catch (e) {
        // Status filter not found, continue without it
        print('Status filter not found for pagination: $e');
      }

      // Map status filter to API codes same as in fetchAllTests
      String apiStatus = '';
      if (statusFilter.isNotEmpty) {
        // Convert status string to numerical codes expected by API
        apiStatus = statusFilter == 'Pending'
            ? '0'
            : statusFilter == 'In Progress'
                ? '1'
                : statusFilter == 'Completed'
                    ? '2'
                    : statusFilter == 'Canceled'
                        ? '3'
                        : '';
        print(
          'Mapped status text "$statusFilter" to API status code: "$apiStatus" for pagination',
        );
      }

      print(
        'Pagination with filters - doctorId: $doctorIdParam, agent: $agentIdParam, status: $statusFilter (code: $apiStatus)',
      );

      await fetchAllTests(
        doctorId: doctorIdParam,
        agent: agentIdParam,
        status:
            statusFilter, // Keep the original status text, fetchAllTests will map it
        resetPage: false,
      );
    }
  }

  // Private method to load mock data as fallback
  void _generateMockData() {
    print('API returned no data and no fallback mechanism provided');

    // Just initialize empty lists
    allRecentTests.value = [];
    filteredRecentTests.value = [];
  }

  // Helper methods for mock data generation
  String _getClientName(int index) {
    return "Unknown";
  }

  String _getTestType(int index) {
    return "Unknown";
  }

  String _getStatus(int index) {
    return "Unknown";
  }

  String _getRandomBsDate(int index) {
    return "";
  }

  // Apply filter for status
  void applyStatusFilter(String status) {
    if (status == 'All') {
      filteredRecentTests.value = [...allRecentTests];
      return;
    }

    filteredRecentTests.value =
        allRecentTests.where((test) => test['status'] == status).toList();
  }

  // Apply date range filter
  void applyDateFilter(DateTime? from, DateTime? to) {
    print(
      'Applying date filter - from: ${from?.toIso8601String()}, to: ${to?.toIso8601String()}',
    );

    try {
      // Format dates for API call
      String fromDateStr = '';
      String toDateStr = '';

      if (from != null) {
        // Format as yyyy-MM-dd
        fromDateStr =
            '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
      }

      if (to != null) {
        // Format as yyyy-MM-dd
        toDateStr =
            '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
      }

      print('Formatted date range for API: $fromDateStr to $toDateStr');

      // Get current status from UI if available through GetX managers
      String statusFilter = '';
      try {
        final statusVariable = Get.find<RxString>(tag: 'statusFilter');
        if (statusVariable.value != 'All') {
          statusFilter = statusVariable.value;
        }
      } catch (e) {
        // Status filter not found, continue without it
      }

      // Call API with date range and other current filters
      fetchAllTests(
        doctorId: selectedDoctorId.value.isEmpty ? '' : selectedDoctorId.value,
        agent: selectedAgentId.value.isEmpty ? '' : selectedAgentId.value,
        status: statusFilter,
        fromDate: fromDateStr,
        toDate: toDateStr,
        resetPage: true,
      );

      // Also apply local filtering as a backup
      _applyLocalDateFilter(from, to);
    } catch (e) {
      print('Error applying date filter: $e');
      // If API call fails, fallback to local filtering
      _applyLocalDateFilter(from, to);
    }
  }

  // Local date filtering (fallback when API filtering doesn't work)
  void _applyLocalDateFilter(DateTime? from, DateTime? to) {
    print(
      'Applying local date filter - from: ${from?.toIso8601String()}, to: ${to?.toIso8601String()}',
    );

    // Reset to full list first if no dates provided
    if (from == null && to == null) {
      filteredRecentTests.value = [...allRecentTests];
      return;
    }

    // Apply date filters
    filteredRecentTests.value = allRecentTests.where((test) {
      try {
        // Parse the date from the test (handling various formats)
        DateTime testDate;
        final dateStr = test['date'].toString();

        // Try to parse the date from the test
        try {
          testDate = DateTime.parse(dateStr);
        } catch (e) {
          // If standard parse fails, try alternative format (DD MMM YYYY)
          final parts = dateStr.split(' ');
          if (parts.length >= 3) {
            final day = int.tryParse(parts[0]) ?? 1;
            final month = _getMonthNumber(parts[1]);
            final year = int.tryParse(parts[2]) ?? 2023;
            testDate = DateTime(year, month, day);
          } else {
            // Default to today if parsing fails
            print('Failed to parse date: $dateStr');
            testDate = DateTime.now();
          }
        }

        // Apply from date filter if provided
        if (from != null) {
          // Set from date to start of day
          final fromDate = DateTime(from.year, from.month, from.day);
          if (testDate.isBefore(fromDate)) {
            return false;
          }
        }

        // Apply to date filter if provided
        if (to != null) {
          // Set to date to end of day
          final toDate = DateTime(to.year, to.month, to.day, 23, 59, 59);
          if (testDate.isAfter(toDate)) {
            return false;
          }
        }

        return true;
      } catch (e) {
        print('Error filtering date for test: $e');
        return true; // Include records with date errors by default
      }
    }).toList();

    print(
      'After date filtering: ${filteredRecentTests.length} tests remaining',
    );
  }

  // Helper to convert month name to number
  int _getMonthNumber(String monthName) {
    final months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[monthName] ?? 1; // Default to January if not found
  }

  // Apply client filter
  void applyClientFilter(String clientName) {
    if (clientName == 'All') {
      filteredRecentTests.value = [...allRecentTests];
      return;
    }

    filteredRecentTests.value = allRecentTests
        .where((test) => test['clientName'] == clientName)
        .toList();
  }

  // Filter methods
  void applyDepartmentFilter(String? departmentId) {
    try {
      print('Applying department filter with ID: $departmentId');

      // Reset to all departments if "All" is selected
      if (departmentId == null ||
          departmentId.isEmpty ||
          departmentId == 'All') {
        selectedDepartmentId.value = '';
        print('Department filter reset to All');
      } else {
        // Store the selected ID
        selectedDepartmentId.value = departmentId;
        // Verify the department exists
        final dept = departments.firstWhereOrNull(
          (d) => d.id.toString() == departmentId,
        );
        print(
          'Selected department: ${dept?.departmentName ?? 'Unknown'} (ID: $departmentId)',
        );
      }

      // Fetch data with all current filters - use empty string or ID
      fetchAllTests(
        doctorId: selectedDoctorId.value.isEmpty ? '' : selectedDoctorId.value,
        agent: selectedAgentId.value.isEmpty ? '' : selectedAgentId.value,
        resetPage: true,
      );

      // Log the current filter state
      print(
        'Current filters - Department: ${selectedDepartmentId.value}, Agent: ${selectedAgentId.value}, Doctor: ${selectedDoctorId.value}',
      );
    } catch (e) {
      print('Error applying department filter: $e');
      filteredRecentTests.value = [...allRecentTests];
    }
  }

  void applyAgentFilter(String? agentId) {
    try {
      print('Applying agent filter with ID: $agentId');

      // Reset to all agents if "All" is selected
      if (agentId == null || agentId.isEmpty || agentId == 'All') {
        selectedAgentId.value = '';
        print('Agent filter reset to All');
      } else {
        // Store the selected ID
        selectedAgentId.value = agentId;
        // Verify the agent exists
        final agent = agents.firstWhereOrNull(
          (a) => a.id.toString() == agentId,
        );
        print(
          'Selected agent: ${agent?.agentName ?? 'Unknown'} (ID: $agentId)',
        );
      }

      // Get current status from UI if available through GetX managers
      String statusFilter = '';
      try {
        final statusVariable = Get.find<RxString>(tag: 'statusFilter');
        if (statusVariable.value != 'All') {
          statusFilter = statusVariable.value;
        }
      } catch (e) {
        // Status filter not found, continue without it
      }

      // Fetch data with all current filters - use empty string or ID
      fetchAllTests(
        doctorId: selectedDoctorId.value.isEmpty ? '' : selectedDoctorId.value,
        agent: selectedAgentId.value.isEmpty ? '' : selectedAgentId.value,
        status: statusFilter,
        resetPage: true,
      );

      // Log the current filter state
      print(
        'Current filters - Department: ${selectedDepartmentId.value}, Agent: ${selectedAgentId.value}, Doctor: ${selectedDoctorId.value}, Status: $statusFilter',
      );
    } catch (e) {
      print('Error applying agent filter: $e');
      filteredRecentTests.value = [...allRecentTests];
    }
  }

  void applyDoctorIdFilter(String? doctorId) {
    try {
      print('Applying doctor filter with ID: $doctorId');

      // Reset to all doctors if "All" is selected
      if (doctorId == null || doctorId.isEmpty || doctorId == 'All') {
        selectedDoctorId.value = '';
        print('Doctor filter reset to All');
      } else {
        // Store the selected ID
        selectedDoctorId.value = doctorId;
        // Verify the doctor exists
        final doctor = doctors.firstWhereOrNull(
          (d) => d.id.toString() == doctorId,
        );
        print(
          'Selected doctor: ${doctor?.docName ?? 'Unknown'} (ID: $doctorId)',
        );
      }

      // Get current status from UI if available through GetX managers
      String statusFilter = '';
      try {
        final statusVariable = Get.find<RxString>(tag: 'statusFilter');
        if (statusVariable.value != 'All') {
          statusFilter = statusVariable.value;
        }
      } catch (e) {
        // Status filter not found, continue without it
      }

      // Fetch data with all current filters - use empty string or ID
      fetchAllTests(
        doctorId: selectedDoctorId.value.isEmpty ? '' : selectedDoctorId.value,
        agent: selectedAgentId.value.isEmpty ? '' : selectedAgentId.value,
        status: statusFilter,
        resetPage: true,
      );

      // Log the current filter state
      print(
        'Current filters - Department: ${selectedDepartmentId.value}, Agent: ${selectedAgentId.value}, Doctor: ${selectedDoctorId.value}, Status: $statusFilter',
      );
    } catch (e) {
      print('Error applying doctor filter: $e');
      filteredRecentTests.value = [...allRecentTests];
    }
  }

  // Search functionality
  List<Map<String, dynamic>> searchTests(String query) {
    if (query.isEmpty) {
      return filteredRecentTests.cast<Map<String, dynamic>>().toList();
    }

    return filteredRecentTests
        .where((test) {
          return test['patientName'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
              test['id'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
              test['testType'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
              test['status'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  );
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // Update statistics based on selected time period
  void updateStatistics() {
    // Use default values of 0 instead of random calculations
    totalTests.value = '0';
    completedTests.value = '0';
    pendingTests.value = '0';
    todayTests.value = '0';
  }

  // Update billing statistics based on selected time period
  Future<void> updateBillingStatistics() async {
    try {
      // Get billing statistics from GetMitiBillingSummary endpoint
      final response = await _apiService.get(ApiConfig.billingStatistics);

      if (response != null && response is Map<String, dynamic>) {
        // Update today's stats
        todayBillCount.value = response['todayBillCount'] ?? 0;
        todayBillAmount.value = (response['todayBillAmount'] ?? 0).toDouble();

        // Update week's stats
        weekBillCount.value = response['weekBillCount'] ?? 0;
        weekBillAmount.value = (response['weekBillAmount'] ?? 0).toDouble();

        // Update month's stats
        monthBillCount.value = response['monthBillCount'] ?? 0;
        monthBillAmount.value = (response['monthBillAmount'] ?? 0).toDouble();

        // Update the revenue display values with proper formatting
        todayRevenue.value = formatCurrency(todayBillAmount.value);
        weeklyRevenue.value = formatCurrency(weekBillAmount.value);
        monthlyRevenue.value = formatCurrency(monthBillAmount.value);
      }

      // Get weekly data for graph from GetWeeklyDailyBillingData endpoint
      final weeklyResponse = await _apiService.get(ApiConfig.billingTime);

      if (weeklyResponse != null && weeklyResponse is List) {
        final List<double> weeklyData = [];
        final List<String> labels = [];
        double maxValue = 0;

        // Process each day's data
        for (var dayData in weeklyResponse) {
          // Add the bill amount to weekly data
          final double amount = (dayData['billAmount'] ?? 0).toDouble();
          weeklyData.add(amount);

          // Add the day name (first letter) to labels
          final String dayName = dayData['dayName'] ?? '';
          labels.add(dayName.isNotEmpty ? dayName[0] : '');

          // Update max value if needed
          if (amount > maxValue) {
            maxValue = amount;
          }
        }

        // Ensure we have data before updating the UI
        if (weeklyData.isNotEmpty) {
          // Calculate revenue growth using today's amount vs average
          if (weeklyData.reduce((a, b) => a + b) > 0) {
            final avgDailyRevenue =
                weeklyData.reduce((a, b) => a + b) / weeklyData.length;
            final todayAmount = weeklyData.last; // Assuming last day is today
            final growth =
                ((todayAmount - avgDailyRevenue) / avgDailyRevenue) * 100;
            revenueGrowth.value = '${growth.toStringAsFixed(1)}%';
          } else {
            revenueGrowth.value = '0%';
          }

          // Update the chart data
          revenueData.value = weeklyData;
          revenueLabels.value = labels;
          maxRevenue.value =
              maxValue > 0 ? maxValue : 1; // Avoid division by zero
        }
      }
    } catch (e) {
      print('Error updating billing statistics: $e');
      // Keep the existing values in case of error, but don't generate mock data

      // Empty chart data if we have none
      if (revenueData.isEmpty) {
        revenueData.value = [];
        revenueLabels.value = [];
        maxRevenue.value = 1; // Default to avoid division by zero
      }
    }
  }

  // Helper method to format currency values
  String formatCurrency(double amount) {
    if (amount >= 100000) {
      return 'Rs. ${(amount / 100000).toStringAsFixed(2)}L';
    } else {
      return 'Rs. ${amount.toStringAsFixed(0)}';
    }
  }

  Future<void> fetchReferenceData() async {
    try {
      print('[LabController] Fetching reference data...');

      // Use the constant endpoint for reference data
      final response = await _apiService.get(ApiConfig.getReferenceData);
      print('[LabController] API Response data received');

      if (response == null) {
        print('[LabController] API response is null, using mock data');
        _useMockReferenceData();
        return;
      }

      // Clear existing lists
      departments.clear();
      agents.clear();
      doctors.clear();

      // Add "All" option first
      departments.add(Department(id: 0, departmentName: 'All Departments'));
      agents.add(Agent(id: 0, agentName: 'All Agents'));
      doctors.add(Doctor(id: 0, docName: 'All Doctors'));

      try {
        // Create a ReferenceData model from the JSON response
        final referenceDataModel = ReferenceData.fromJson(response);

        // Log counts from the parsed model
        print(
          '[LabController] Parsed ${referenceDataModel.departments.length} departments',
        );
        print(
          '[LabController] Parsed ${referenceDataModel.agents.length} agents',
        );
        print(
          '[LabController] Parsed ${referenceDataModel.doctors.length} doctors',
        );

        // Add the items from the model to our observable lists
        if (referenceDataModel.departments.isNotEmpty) {
          departments.addAll(referenceDataModel.departments);
        } else {
          print(
            '[LabController] No departments found from API',
          );
          // No longer adding mock departments
        }

        if (referenceDataModel.agents.isNotEmpty) {
          agents.addAll(referenceDataModel.agents);
        } else {
          print('[LabController] No agents found from API');
          // No longer adding mock agents
        }

        if (referenceDataModel.doctors.isNotEmpty) {
          doctors.addAll(referenceDataModel.doctors);
        } else {
          print('[LabController] No doctors found from API');
          // No longer adding mock doctors
        }

        // Store the reference data model
        referenceData.value = referenceDataModel;
      } catch (e) {
        print('[LabController] Error parsing reference data: $e');
        print('[LabController] Stack trace: ${StackTrace.current}');
        // If any error occurs during parsing, add mock data
        _useMockReferenceData();
      }
    } catch (e) {
      print('[LabController] Error in fetchReferenceData: $e');
      print('[LabController] Stack trace: ${StackTrace.current}');
      _useMockReferenceData();
    } finally {
      // Log final counts
      print('[LabController] Final departments count: ${departments.length}');
      print('[LabController] Final agents count: ${agents.length}');
      print('[LabController] Final doctors count: ${doctors.length}');

      // Force UI update
      departments.refresh();
      agents.refresh();
      doctors.refresh();

      // Reset filter selections
      selectedDepartmentId.value = '';
      selectedAgentId.value = '';
      selectedDoctorId.value = '';
    }
  }

  // Add reference data
  void _useMockReferenceData() {
    print('[LabController] Reference data unavailable from API');

    // Clear existing lists
    departments.clear();
    agents.clear();
    doctors.clear();

    // Add "All" options only
    departments.add(Department(id: 0, departmentName: 'All Departments'));
    agents.add(Agent(id: 0, agentName: 'All Agents'));
    doctors.add(Doctor(id: 0, docName: 'All Doctors'));

    // No mock data added - only "All" options will be available
  }

  void _addMockDepartments() {
    // No longer adding mock departments
    print('[LabController] Not adding mock departments');
  }

  void _addMockAgents() {
    // No longer adding mock agents
    print('[LabController] Not adding mock agents');
  }

  void _addMockDoctors() {
    // No longer adding mock doctors
    print('[LabController] Not adding mock doctors');
  }

  // Helper methods to get names by IDs
  String? getDepartmentNameById(String? id) {
    try {
      if (id == null || id.isEmpty || id == 'All') return 'All Departments';
      final dept = departments.firstWhereOrNull((d) => d.id.toString() == id);
      return dept?.departmentName ?? 'Unknown Department';
    } catch (e) {
      print('Error getting department name: $e');
      return 'Unknown Department';
    }
  }

  String? getAgentNameById(String? id) {
    try {
      if (id == null || id.isEmpty || id == 'All') return 'All Agents';
      final agent = agents.firstWhereOrNull((a) => a.id.toString() == id);
      return agent?.agentName ?? 'Unknown Agent';
    } catch (e) {
      print('Error getting agent name: $e');
      return 'Unknown Agent';
    }
  }

  String? getDoctorNameById(String? id) {
    try {
      if (id == null || id.isEmpty || id == 'All') return 'All Doctors';
      final doctor = doctors.firstWhereOrNull((d) => d.id.toString() == id);
      return doctor?.docName ?? 'Unknown Doctor';
    } catch (e) {
      print('Error getting doctor name: $e');
      return 'Unknown Doctor';
    }
  }

  // Clear all filters
  void clearFilters() {
    print('[LabController] Clearing all filters');
    selectedDepartmentId.value = '';
    selectedAgentId.value = '';
    selectedDoctorId.value = '';

    // Refetch data with cleared filters
    fetchAllTests(
      doctorId: '',
      agent: '',
      status: '',
      searchTerm: '',
      resetPage: true,
    );

    print(
      '[LabController] Filters cleared - doctorId: ${selectedDoctorId.value}, agentId: ${selectedAgentId.value}, departmentId: ${selectedDepartmentId.value}',
    );
  }

  // Refresh all data
  Future<void> refreshData() async {
    try {
      isLoading.value = true;

      // Update statistics based on fixed time period
      updateStatistics();
      updateBillingStatistics();

      // Refresh tests data
      await _fetchRecentTests(
        dateFilter: getDateFilterForTimePeriod(),
        pageNumber: 1,
        pageSize: 10,
        doctorId: selectedDoctorId.value,
        agent: selectedAgentId.value,
      );

      // Also refresh reference data in case it has changed
      await fetchReferenceData();
    } catch (e) {
      print('Error refreshing data: $e');
      rethrow; // Re-throw to allow handling in UI
    } finally {
      isLoading.value = false;
    }
  }

  // Update time period and related statistics - keeping method for compatibility
  void changeTimePeriod(String period) {
    // No longer needed as we removed the dropdown
    updateStatistics();
    updateBillingStatistics();
    _fetchRecentTests(
      dateFilter: getDateFilterForTimePeriod(),
      pageNumber: 1,
      pageSize: 5, // For home page we only need 5 items
      doctorId: selectedDoctorId.value,
      agent: selectedAgentId.value,
    ); // Refresh data with new time period
  }

  // Fetch test list by patient ID
  Future<void> fetchTestList(String id) async {
    try {
      print('\n🔍 INVESTIGATION ID CHECK (Lab Controller) 🔍');
      print('----------------------------------------');
      print('Investigation ID Value: "$id"');
      print('Type: ${id.runtimeType}');
      print('Length: ${id.length}');
      print('Is Empty?: ${id.isEmpty}');
      print('Contains Slash?: ${id.contains('/')}');
      print('----------------------------------------');

      isLoadingTests.value = true;
      final endpoint = '${ApiConfig.getTestNameById}$id';
      print('DEBUG: Making API call to endpoint: $endpoint');

      final response = await _apiService.get(endpoint);
      print('DEBUG: API Raw Response Type: ${response.runtimeType}');
      print('DEBUG: API Raw Response: $response');
      print(endpoint);

      if (response is List) {
        print('DEBUG: Processing list of ${response.length} tests');
        print(
            'DEBUG: First test data: ${response.isNotEmpty ? response.first : 'No data'}');

        testList.value = response.map((json) {
          print('DEBUG: Processing test JSON: $json');
          try {
            final model = TestModel.fromJson(Map<String, dynamic>.from(json));
            print('DEBUG: Successfully created TestModel: ${model.testName}');
            return model;
          } catch (e) {
            print('DEBUG: Error creating TestModel: $e');
            rethrow;
          }
        }).toList();

        print('DEBUG: Successfully processed ${testList.length} tests');
      } else {
        print('DEBUG: Unexpected response type: ${response.runtimeType}');
        testList.clear();
        throw Exception('Unexpected response format');
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error in fetchTestList: $e');
      print('DEBUG: Stack trace: $stackTrace');
      testList.clear();
      rethrow;
    } finally {
      isLoadingTests.value = false;
      print('DEBUG: fetchTestList completed. Tests count: ${testList.length}');
    }
  }
}
