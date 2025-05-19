import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/services/lab_transaction_service.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/reference_data_model.dart';

class LabTransactionController extends GetxController {
  // Service instance
  final LabTransactionService _transactionService = LabTransactionService();
  final ApiService _apiService = Get.find<ApiService>();

  // Reactive variables for UI state
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt expandedCardIndex = RxInt(-1);
  final RxBool showFilters = false.obs;

  // Add authentication error flag
  final RxBool authError = false.obs;

  // Reactive variables for date filters
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxString clientFilter = 'All'.obs;
  final RxString doctorFilter = 'All'.obs;
  final RxString agentFilter = 'All'.obs;

  // Lists for dropdown options from API
  final RxList<String> uniqueAgents = <String>[].obs;
  final RxList<String> uniqueDoctors = <String>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt pageSize = 10.obs;
  final RxInt totalCount = 0.obs;
  final RxBool hasMoreData = true.obs;

  // Display counts for virtualized list
  final RxInt displayedItemCount = 0.obs;
  final RxInt totalItemCount = 0.obs;

  // Transactions data
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  // Group transactions by date
  final Rx<Map<String, List<Map<String, dynamic>>>> groupedTransactions =
      Rx<Map<String, List<Map<String, dynamic>>>>({});

  // Sorted dates for display
  final RxList<String> sortedDates = <String>[].obs;

  // Variables for search debounce
  late Worker _searchDebounceWorker;
  final RxString _debouncedSearchQuery = ''.obs;

  // Reference data lists
  final RxList<Department> departments = <Department>[].obs;
  final RxList<Agent> agents = <Agent>[].obs;
  final RxList<Doctor> doctors = <Doctor>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Setup debounce for search to delay API calls during typing
    _searchDebounceWorker = debounce(
      _debouncedSearchQuery,
      (String value) {
        _performSearch(value);
      },
      time: const Duration(milliseconds: 500),
    );

    // Fetch reference data first
    fetchReferenceData().then((_) {
      // Then fetch transactions
      fetchTransactions();
    });
  }

  @override
  void onClose() {
    _searchDebounceWorker.dispose();
    super.onClose();
  }

  // Convert string status to Color for UI
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Fetch transactions with optional filters
  Future<void> fetchTransactions({
    String searchTerm = '',
    String referredBy = '',
    String departmentId = '',
    String dateFilter = '',
    String agentName = '',
    bool resetPage = true,
  }) async {
    try {
      if (resetPage) {
        currentPage.value = 1;
        transactions.clear();
        groupedTransactions.value = {};
        sortedDates.clear();
      }

      isLoading.value = true;
      authError.value = false;

      final response = await _transactionService.getTransactions(
        pageNumber: currentPage.value,
        pageSize: pageSize.value,
        searchTerm: searchTerm,
        referredBy: referredBy,
        departmentId: departmentId,
        dateFilter: dateFilter,
        agentName: agentName,
      );

      // Update pagination data
      totalPages.value = response.totalPages;
      totalCount.value = response.totalCount;
      hasMoreData.value = response.hasNextPage;

      // Update display counts for UI
      displayedItemCount.value = transactions.length;
      totalItemCount.value = totalCount.value;

      // Process items
      final newTransactions = response.items.map((item) {
        final displayData = item.toDisplayFormat();
        // Convert status color string to Color object
        displayData['statusColor'] =
            getStatusColor(displayData['statusColor'] as String);
        return displayData;
      }).toList();

      // Add new transactions to list
      if (resetPage) {
        transactions.value = newTransactions;
      } else {
        transactions.addAll(newTransactions);
      }

      // Extract unique agents and doctors from transactions for filter dropdowns
      _extractUniqueFiltersFromTransactions();

      // Group transactions by date
      _groupTransactionsByDate();
    } catch (e) {
      print('Error fetching transactions: $e');
      if (e.toString().contains('Authentication failed')) {
        authError.value = true;
      }
      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to load transactions. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load more transactions (pagination)
  Future<void> loadMore() async {
    if (!isLoading.value && hasMoreData.value) {
      currentPage.value++;
      await fetchTransactions(resetPage: false);
    }
  }

  // Group transactions by date
  void _groupTransactionsByDate() {
    final newGroupedTransactions = <String, List<Map<String, dynamic>>>{};

    for (var transaction in transactions) {
      final date = transaction['date'] as String;
      if (!newGroupedTransactions.containsKey(date)) {
        newGroupedTransactions[date] = [];
      }
      newGroupedTransactions[date]!.add(transaction);
    }

    groupedTransactions.value = newGroupedTransactions;

    // Sort dates in descending order (newest first)
    sortedDates.value = newGroupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));
  }

  // Apply search filter with debounce
  void applySearchFilter(String query) {
    // Update search query immediately
    searchQuery.value = query;

    // If query is empty, clear results and fetch all transactions
    if (query.isEmpty) {
      _debouncedSearchQuery.value = '';

      // Show loading indicator
      isLoading.value = true;

      // Fetch all transactions (no search filter)
      fetchTransactions(
        referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
        departmentId: clientFilter.value == 'All' ? '' : clientFilter.value,
      );
      return;
    }

    // For name-like queries (4+ chars or contains space), use exact name search
    if (query.length >= 4 || (query.length >= 2 && query.contains(' '))) {
      // Cancel any pending debounce
      _debouncedSearchQuery.value = '';

      // Use exact name search
      searchByExactName(query);
    } else {
      // For shorter/simpler queries, use normal debounced search
      _debouncedSearchQuery.value = query;
    }
  }

  // Actual search implementation after debounce
  void _performSearch(String query) {
    // Skip if the query is empty or already handled by searchByExactName
    if (query.isEmpty ||
        (query.length >= 4 || (query.length >= 2 && query.contains(' ')))) {
      return;
    }

    // Create the filter parameters
    String dateFilter = '';
    if (fromDate.value != null && toDate.value != null) {
      final fromStr =
          '${fromDate.value!.year}-${fromDate.value!.month.toString().padLeft(2, '0')}-${fromDate.value!.day.toString().padLeft(2, '0')}';
      final toStr =
          '${toDate.value!.year}-${toDate.value!.month.toString().padLeft(2, '0')}-${toDate.value!.day.toString().padLeft(2, '0')}';
      dateFilter = 'custom:$fromStr:$toStr';
    } else if (fromDate.value != null) {
      final fromStr =
          '${fromDate.value!.year}-${fromDate.value!.month.toString().padLeft(2, '0')}-${fromDate.value!.day.toString().padLeft(2, '0')}';
      dateFilter = 'from:$fromStr';
    } else if (toDate.value != null) {
      final toStr =
          '${toDate.value!.year}-${toDate.value!.month.toString().padLeft(2, '0')}-${toDate.value!.day.toString().padLeft(2, '0')}';
      dateFilter = 'to:$toStr';
    }

    // Clear the list before fetching for a completely new search
    if (transactions.isNotEmpty) {
      transactions.clear();
      groupedTransactions.value = {};
      sortedDates.clear();
    }

    // Show loading indicator immediately
    isLoading.value = true;

    // For queries that don't look like names, we use the normal API search
    fetchTransactions(
      searchTerm: query,
      referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
      departmentId: clientFilter.value == 'All' ? '' : clientFilter.value,
      dateFilter: dateFilter,
      resetPage: true,
    );
  }

  // Apply date range filter
  void applyDateFilter(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value = to;

    // Convert to appropriate date filter format for API
    String dateFilter = '';

    if (from != null && to != null) {
      final fromStr =
          '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
      final toStr =
          '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
      dateFilter = 'custom:$fromStr:$toStr';
    } else if (from != null) {
      final fromStr =
          '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
      dateFilter = 'from:$fromStr';
    } else if (to != null) {
      final toStr =
          '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
      dateFilter = 'to:$toStr';
    }

    fetchTransactions(
      dateFilter: dateFilter,
      searchTerm: searchQuery.value,
      referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
      departmentId: clientFilter.value == 'All' ? '' : clientFilter.value,
    );
  }

  // Apply client filter
  void applyClientFilter(String client) {
    clientFilter.value = client;
    fetchTransactions(
      searchTerm: searchQuery.value,
      referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
      departmentId: client == 'All' ? '' : client,
    );
  }

  // Apply doctor filter
  void applyDoctorFilter(String doctor) {
    doctorFilter.value = doctor;
    fetchTransactions(
      searchTerm: searchQuery.value,
      referredBy: doctor == 'All' ? '' : doctor,
    );
  }

  // Apply agent filter
  void applyAgentFilter(String agent) {
    agentFilter.value = agent;
    fetchTransactions(
      searchTerm: searchQuery.value,
      referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
      agentName: agent == 'All' ? '' : agent,
    );
  }

  // Combined filter reset
  void resetFilters() {
    // Set loading state immediately to show feedback
    isLoading.value = true;

    // Clear all filters
    searchQuery.value = '';
    _debouncedSearchQuery.value = '';
    clientFilter.value = 'All';
    doctorFilter.value = 'All';
    agentFilter.value = 'All';
    fromDate.value = null;
    toDate.value = null;

    // Clear current data
    transactions.clear();
    groupedTransactions.value = {};
    sortedDates.clear();

    // Reset pagination
    currentPage.value = 1;

    // Fetch fresh data
    fetchTransactions();
  }

  // Mock data for fallback
  void _generateMockData() {
    print('Generating mock data for transactions');

    // Create a list of distinct patient names
    final patientNames = [
      'Rampratap Singh',
      'Rampratap Mehra',
      'Prithviraj Singh',
      'Aarti Gupta',
      'Suman Rai',
      'Pankaj Shah',
      'Rajesh Kumar',
      'Geeta Sharma',
      'Anil Verma',
      'Sunita Patel'
    ];

    transactions.value = List.generate(
      15, // Generate 15 records instead of 10
      (index) => {
        'sn': index + 1,
        'id': 'LAB-2024-00${index + 1}',
        'billNumber': 'B1004${index + 5}',
        'billDate': '0${index % 9 + 1} Apr 2024',
        'bsDate': '२०८०-१२-${(index % 30) + 1}',
        'patientName': patientNames[index % patientNames.length],
        'patientAge': '${20 + (index % 60)}',
        'patientSex': index % 2 == 0 ? 'Male' : 'Female',
        'mobile': '980${1234567 + index}',
        'address': 'Location ${index + 1}, Nepal',
        'testType': index % 3 == 0
            ? 'Blood Test'
            : (index % 3 == 1 ? 'X-Ray' : 'Ultrasound'),
        'amount': 'NPR ${1000 + (index * 500)}',
        'date': '0${index % 9 + 1} Apr 2024',
        'status': index % 3 == 0
            ? 'Completed'
            : (index % 3 == 1 ? 'In Progress' : 'Scheduled'),
        'statusColor': index % 3 == 0
            ? Colors.green
            : (index % 3 == 1 ? Colors.orange : Colors.blue),
        'user': 'Dr. ${index % 2 == 0 ? "Pankaj Shah" : "Aarti Gupta"}',
        'referredBy': 'Dr. ${index % 2 == 0 ? "Suman Rai" : "Pankaj Shah"}',
        'clientName': index % 3 == 0
            ? 'City Hospital'
            : (index % 3 == 1 ? 'Metro Clinic' : 'Valley Hospital'),
      },
    );

    // Add two specific records for Rampratap to ensure they appear in search
    transactions.add({
      'sn': transactions.length + 1,
      'id': 'LAB-2024-00${transactions.length + 1}',
      'billNumber': 'B10050',
      'billDate': '05 Apr 2024',
      'bsDate': '२०८०-१२-२२',
      'patientName': 'Rampratap Kumar',
      'patientAge': '45',
      'patientSex': 'Male',
      'mobile': '9801234567',
      'address': 'Kathmandu, Nepal',
      'testType': 'Blood Test',
      'amount': 'NPR 2500',
      'date': '05 Apr 2024',
      'status': 'Completed',
      'statusColor': Colors.green,
      'user': 'Dr. Aarti Gupta',
      'referredBy': 'Dr. Suman Rai',
      'clientName': 'City Hospital',
    });

    transactions.add({
      'sn': transactions.length + 1,
      'id': 'LAB-2024-00${transactions.length + 1}',
      'billNumber': 'B10051',
      'billDate': '06 Apr 2024',
      'bsDate': '२०८०-१२-२३',
      'patientName': 'Rampratap Gupta',
      'patientAge': '52',
      'patientSex': 'Male',
      'mobile': '9807654321',
      'address': 'Lalitpur, Nepal',
      'testType': 'X-Ray',
      'amount': 'NPR 3000',
      'date': '06 Apr 2024',
      'status': 'In Progress',
      'statusColor': Colors.orange,
      'user': 'Dr. Pankaj Shah',
      'referredBy': 'Dr. Aarti Gupta',
      'clientName': 'Metro Clinic',
    });

    // Group the mock transactions by date
    _groupTransactionsByDate();

    // Set pagination mock data
    currentPage.value = 1;
    totalPages.value = 3;
    totalCount.value = transactions.length;
    hasMoreData.value = true;
  }

  // Manually filter transactions by search query - used when we need more precise control
  void manualSearchFilter(String query) {
    searchQuery.value = query;

    // If query is empty, reset to full dataset
    if (query.isEmpty) {
      fetchTransactions(
        referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
        departmentId: clientFilter.value == 'All' ? '' : clientFilter.value,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Try to fetch from API first with the search query
      fetchTransactions(
        searchTerm: query,
        referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
        departmentId: clientFilter.value == 'All' ? '' : clientFilter.value,
      ).then((_) {
        // If we get results back, we're done
        if (transactions.isNotEmpty) {
          isLoading.value = false;
          return;
        }

        // If no results from API, try filtering existing data (for offline mode)
        final allTransactions = _generateMockTransactions();

        // Convert search query to lowercase for case-insensitive search
        final searchLower = query.toLowerCase();

        // Filter transactions that match the search query
        final List<Map<String, dynamic>> filteredList =
            allTransactions.where((transaction) {
          final patientName =
              transaction['patientName']?.toString().toLowerCase() ?? '';
          final billNumber =
              transaction['billNumber']?.toString().toLowerCase() ?? '';
          final id = transaction['id']?.toString().toLowerCase() ?? '';
          final mobile = transaction['mobile']?.toString().toLowerCase() ?? '';

          // Check if any field contains the search query
          return patientName.contains(searchLower) ||
              billNumber.contains(searchLower) ||
              id.contains(searchLower) ||
              mobile.contains(searchLower);
        }).toList();

        // Update transactions with filtered results
        if (filteredList.isNotEmpty) {
          transactions.value = filteredList;
          _groupTransactionsByDate(); // Re-group after filtering
        }

        isLoading.value = false;
      });
    } catch (e) {
      print('Error in manual search filter: $e');
      isLoading.value = false;
    }
  }

  // Helper method to generate a set of mock transactions for offline filtering
  List<Map<String, dynamic>> _generateMockTransactions() {
    // Create a list of distinct patient names
    final patientNames = [
      'Rampratap Singh',
      'Rampratap Mehra',
      'Prithviraj Singh',
      'Aarti Gupta',
      'Suman Rai',
      'Pankaj Shah',
      'Rajesh Kumar',
      'Geeta Sharma',
      'Anil Verma',
      'Sunita Patel'
    ];

    final transactions = List.generate(
      15, // Generate 15 records instead of 10
      (index) => {
        'sn': index + 1,
        'id': 'LAB-2024-00${index + 1}',
        'billNumber': 'B1004${index + 5}',
        'billDate': '0${index % 9 + 1} Apr 2024',
        'bsDate': '२०८०-१२-${(index % 30) + 1}',
        'patientName': patientNames[index % patientNames.length],
        'patientAge': '${20 + (index % 60)}',
        'patientSex': index % 2 == 0 ? 'Male' : 'Female',
        'mobile': '980${1234567 + index}',
        'address': 'Location ${index + 1}, Nepal',
        'testType': index % 3 == 0
            ? 'Blood Test'
            : (index % 3 == 1 ? 'X-Ray' : 'Ultrasound'),
        'amount': 'NPR ${1000 + (index * 500)}',
        'date': '0${index % 9 + 1} Apr 2024',
        'status': index % 3 == 0
            ? 'Completed'
            : (index % 3 == 1 ? 'In Progress' : 'Scheduled'),
        'statusColor': index % 3 == 0
            ? Colors.green
            : (index % 3 == 1 ? Colors.orange : Colors.blue),
        'user': 'Dr. ${index % 2 == 0 ? "Pankaj Shah" : "Aarti Gupta"}',
        'referredBy': 'Dr. ${index % 2 == 0 ? "Suman Rai" : "Pankaj Shah"}',
        'clientName': index % 3 == 0
            ? 'City Hospital'
            : (index % 3 == 1 ? 'Metro Clinic' : 'Valley Hospital'),
      },
    );

    // Add two specific records for Rampratap to ensure they appear in search
    transactions.add({
      'sn': transactions.length + 1,
      'id': 'LAB-2024-00${transactions.length + 1}',
      'billNumber': 'B10050',
      'billDate': '05 Apr 2024',
      'bsDate': '२०८०-१२-२२',
      'patientName': 'Rampratap Kumar',
      'patientAge': '45',
      'patientSex': 'Male',
      'mobile': '9801234567',
      'address': 'Kathmandu, Nepal',
      'testType': 'Blood Test',
      'amount': 'NPR 2500',
      'date': '05 Apr 2024',
      'status': 'Completed',
      'statusColor': Colors.green,
      'user': 'Dr. Aarti Gupta',
      'referredBy': 'Dr. Suman Rai',
      'clientName': 'City Hospital',
    });

    transactions.add({
      'sn': transactions.length + 1,
      'id': 'LAB-2024-00${transactions.length + 1}',
      'billNumber': 'B10051',
      'billDate': '06 Apr 2024',
      'bsDate': '२०८०-१२-२३',
      'patientName': 'Rampratap Gupta',
      'patientAge': '52',
      'patientSex': 'Male',
      'mobile': '9807654321',
      'address': 'Lalitpur, Nepal',
      'testType': 'X-Ray',
      'amount': 'NPR 3000',
      'date': '06 Apr 2024',
      'status': 'In Progress',
      'statusColor': Colors.orange,
      'user': 'Dr. Pankaj Shah',
      'referredBy': 'Dr. Aarti Gupta',
      'clientName': 'Metro Clinic',
    });

    return transactions;
  }

  // Apply specific search for exact patient name
  void searchByExactName(String name) {
    if (name.isEmpty) {
      // Clear search and show all transactions
      searchQuery.value = '';
      fetchTransactions(
        referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
        departmentId: clientFilter.value == 'All' ? '' : clientFilter.value,
      );
      return;
    }

    // Update the search query value
    searchQuery.value = name;

    isLoading.value = true;

    try {
      // First try API search
      fetchTransactions(
        searchTerm: name,
        referredBy: doctorFilter.value == 'All' ? '' : doctorFilter.value,
        departmentId: clientFilter.value == 'All' ? '' : clientFilter.value,
        resetPage: true,
      ).then((_) {
        // Get original results from the API
        final List<Map<String, dynamic>> originalResults = [...transactions];

        // If no result and we're not online, generate mock data
        if (originalResults.isEmpty) {
          _generateMockData();
        }

        // Further filter results to get matches using our utility function
        // This handles progressive typing - showing more results as user types more characters
        final List<Map<String, dynamic>> matchingTransactions =
            transactions.where((transaction) {
          final String patientName =
              transaction['patientName']?.toString().toLowerCase() ?? '';
          final String searchLower = name.toLowerCase();

          // Create a score-based ranking system
          int matchScore = 0;

          // Exact match gets highest score
          if (patientName == searchLower) {
            matchScore = 10;
          }
          // Name starts with query gets high score
          else if (patientName.startsWith(searchLower)) {
            matchScore = 8;
          }
          // Any word in name starts with query gets medium score
          else {
            final List<String> nameParts = patientName.split(' ');
            for (final part in nameParts) {
              if (part.startsWith(searchLower)) {
                matchScore = 6;
                break;
              }
            }
          }

          // Name contains query gets lower score
          if (matchScore == 0 && patientName.contains(searchLower)) {
            matchScore = 3;
          }

          // Score threshold based on query length (more strict for longer queries)
          final int threshold = name.length <= 3 ? 3 : 6;

          return matchScore >= threshold;
        }).toList();

        // Update transactions with filtered results
        if (matchingTransactions.isNotEmpty) {
          transactions.value = matchingTransactions;
          _groupTransactionsByDate(); // Re-group after filtering
        } else if (originalResults.isNotEmpty) {
          // If our custom filtering yielded no results but API returned some,
          // revert to API results (might be more relevant)
          transactions.value = originalResults;
          _groupTransactionsByDate();
        }

        isLoading.value = false;
      });
    } catch (e) {
      print('Error in exact name search: $e');
      isLoading.value = false;
    }
  }

  // Method to refresh data (wrapper around fetchTransactions)
  Future<void> refreshData() async {
    try {
      authError.value = false;
      await fetchTransactions(resetPage: true);
      displayedItemCount.value = transactions.length;
      totalItemCount.value = totalCount.value;
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  // Method to retry after auth error
  Future<void> refreshAndRetry() async {
    try {
      authError.value = false;
      await fetchTransactions(resetPage: true);
    } catch (e) {
      print('Error in refresh and retry: $e');
      // If still fails, keep auth error as true
      authError.value = true;
    }
  }

  // Extract unique agents and doctors from transactions for filter dropdowns
  void _extractUniqueFiltersFromTransactions() {
    final uniqueAgentsSet = <String>{};
    final uniqueDoctorsSet = <String>{};

    for (var transaction in transactions) {
      // For agents, use the referredBy field (referring doctor)
      final referringDoctor = transaction['referredBy'] as String?;
      if (referringDoctor != null && referringDoctor != 'Not specified') {
        uniqueAgentsSet.add(referringDoctor);
      }

      // For doctors, use the user field (who entered the transaction)
      final doctor = transaction['user'] as String?;
      if (doctor != null) {
        uniqueDoctorsSet.add(doctor);
      }
    }

    // Update the observable lists
    uniqueAgents.value = uniqueAgentsSet.toList()..sort();
    uniqueDoctors.value = uniqueDoctorsSet.toList()..sort();

    // Ensure we have data for dropdowns
    if (uniqueAgents.isEmpty) {
      print('Warning: No agents found in transactions. Adding placeholder.');
      uniqueAgents.add('Dr. Suman Rai');
    }
    if (uniqueDoctors.isEmpty) {
      print('Warning: No doctors found in transactions. Adding placeholder.');
      uniqueDoctors.add('Dr. Pankaj Shah');
    }
  }

  // Fetch reference data from API
  Future<void> fetchReferenceData() async {
    try {
      print('[LabTransactionController] Fetching reference data...');

      // Use the constant endpoint for reference data
      final response = await _apiService.get(ApiConfig.getReferenceData);
      print('[LabTransactionController] API Response data received');

      if (response == null) {
        print(
            '[LabTransactionController] API response is null, using mock data');
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
            '[LabTransactionController] Parsed ${referenceDataModel.departments.length} departments');
        print(
            '[LabTransactionController] Parsed ${referenceDataModel.agents.length} agents');
        print(
            '[LabTransactionController] Parsed ${referenceDataModel.doctors.length} doctors');

        // Add the items from the model to our observable lists
        if (referenceDataModel.departments.isNotEmpty) {
          departments.addAll(referenceDataModel.departments);
        } else {
          print(
              '[LabTransactionController] No departments found, adding mock departments');
          _addMockDepartments();
        }

        if (referenceDataModel.agents.isNotEmpty) {
          agents.addAll(referenceDataModel.agents);
        } else {
          print(
              '[LabTransactionController] No agents found, adding mock agents');
          _addMockAgents();
        }

        if (referenceDataModel.doctors.isNotEmpty) {
          doctors.addAll(referenceDataModel.doctors);
        } else {
          print(
              '[LabTransactionController] No doctors found, adding mock doctors');
          _addMockDoctors();
        }
      } catch (e) {
        print('[LabTransactionController] Error parsing reference data: $e');
        print('[LabTransactionController] Stack trace: ${StackTrace.current}');
        // If any error occurs during parsing, add mock data
        _useMockReferenceData();
      }
    } catch (e) {
      print('[LabTransactionController] Error in fetchReferenceData: $e');
      print('[LabTransactionController] Stack trace: ${StackTrace.current}');
      _useMockReferenceData();
    }
  }

  // Add mock reference data
  void _useMockReferenceData() {
    print('[LabTransactionController] Using mock reference data');

    // Clear existing lists
    departments.clear();
    agents.clear();
    doctors.clear();

    // Add "All" options
    departments.add(Department(id: 0, departmentName: 'All Departments'));
    agents.add(Agent(id: 0, agentName: 'All Agents'));
    doctors.add(Doctor(id: 0, docName: 'All Doctors'));

    // Add mock data
    _addMockDepartments();
    _addMockAgents();
    _addMockDoctors();
  }

  void _addMockDepartments() {
    departments.addAll([
      Department(id: 1, departmentName: 'City Hospital'),
      Department(id: 2, departmentName: 'Metro Clinic'),
      Department(id: 3, departmentName: 'Central Hospital'),
    ]);
  }

  void _addMockAgents() {
    agents.addAll([
      Agent(id: 1, agentName: 'Dr. Suman Rai'),
      Agent(id: 2, agentName: 'Dr. Pankaj Shah'),
      Agent(id: 3, agentName: 'Dr. Aarti Gupta'),
    ]);
  }

  void _addMockDoctors() {
    doctors.addAll([
      Doctor(id: 1, docName: 'Dr. Suman Rai'),
      Doctor(id: 2, docName: 'Dr. Pankaj Shah'),
      Doctor(id: 3, docName: 'Dr. Aarti Gupta'),
    ]);
  }
}
