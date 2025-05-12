import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/controllers/main_controller.dart';
import 'package:medimaster/controllers/lab_controller.dart';
import 'package:medimaster/widgets/top_app_bar.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:medimaster/utils/pdf_viewer_util.dart';
import 'package:medimaster/models/send_report_model.dart';
import 'package:medimaster/services/report_service.dart';

class LabRecentTestsScreen extends StatefulWidget {
  const LabRecentTestsScreen({super.key});

  @override
  State<LabRecentTestsScreen> createState() => _LabRecentTestsScreenState();
}

class _LabRecentTestsScreenState extends State<LabRecentTestsScreen> {
  static const double _smallFontSize = 10;
  static const double _mediumFontSize = 12;
  static const double _largeFontSize = 14;
  static const double _xlargeFontSize = 16;

  static const double _smallPadding = 4;
  static const double _mediumPadding = 8;
  static const double _largePadding = 16;

  static const double _smallBorderRadius = 4;
  static const double _largeBorderRadius = 20;

  @override
  void initState() {
    super.initState();
    // Initialize status filter
    final statusFilter = 'All'.obs;
    // Register status filter so it can be accessed by controller methods
    Get.put(statusFilter, tag: 'statusFilter', permanent: true);
  }

  @override
  void dispose() {
    // Clean up when widget is disposed
    try {
      Get.delete<RxString>(tag: 'statusFilter');
    } catch (e) {
      print('Error deleting status filter: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();
    final ApiService apiService = Get.put(ApiService());
    final LabController labController =
        Get.put(LabController(apiService: apiService));

    // Initialize screen data in proper sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Initializing lab_recent_tests_screen...');

      // First fetch reference data (departments, agents, doctors)
      labController.fetchReferenceData().then((_) {
        // Then load test data with properly initialized filters
        labController.fetchAllTests(resetPage: true);

        // Log the loaded data for debugging
        Future.delayed(const Duration(seconds: 3), () {
          print('Reference data loaded:');
          print('- Departments: ${labController.departments.length}');
          print('- Agents: ${labController.agents.length}');
          print('- Doctors: ${labController.doctors.length}');
          print('Tests loaded: ${labController.filteredRecentTests.length}');
        });
      });
    });

    // Reactive variables for filters
    final RxString statusFilter = Get.find<RxString>(tag: 'statusFilter');
    final RxString searchQuery = ''.obs;
    // Track the currently expanded card index
    final RxInt expandedCardIndex = RxInt(-1);
    // Track filter visibility
    final RxBool showFilters = false.obs;

    // Scroll controller for pagination
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !labController.isLoading.value &&
          labController.hasMoreData.value) {
        labController.loadMore();
      }
    });

    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      appBar: TopAppBar(
        controller: mainController,
        title: "Recent Tests",
        showBackButton: true,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Investigations',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Obx(
                        () => TextButton.icon(
                          onPressed: () =>
                              showFilters.value = !showFilters.value,
                          icon: Icon(
                            showFilters.value
                                ? Icons.filter_list_off
                                : Icons.filter_list,
                            color: AppConstantColors.labAccent.withOpacity(0.8),
                          ),
                          label: Text(
                            showFilters.value ? 'Hide Filters' : 'Show Filters',
                            style: TextStyle(
                              color:
                                  AppConstantColors.labAccent.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        'Showing ${labController.filteredRecentTests.length} of ${labController.totalCount} tests',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      )),
                ],
              ),
            ),
            // Basic search and status filters always visible
            _buildBasicFilters(statusFilter, searchQuery, labController),

            // Advanced filters that can be hidden
            Obx(
              () => showFilters.value
                  ? _buildAdvancedFilters(statusFilter, labController)
                  : const SizedBox.shrink(),
            ),

            Expanded(
              child: Obx(() {
                // Show loading indicator while initial load
                if (labController.isLoading.value &&
                    labController.filteredRecentTests.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Get filtered tests
                var filteredTests = labController.filteredRecentTests
                    .cast<Map<String, dynamic>>();

                // Debug output for status filtering
                print('Current status filter: ${statusFilter.value}');
                if (statusFilter.value != 'All') {
                  print(
                      'Testing filtered data - count: ${filteredTests.length}');
                  int matchingStatusCount = 0;
                  for (var test in filteredTests) {
                    if (test['status'] == statusFilter.value) {
                      matchingStatusCount++;
                    }
                  }
                  print(
                      'Tests with status "${statusFilter.value}": $matchingStatusCount');

                  // Apply additional local filter if API filtering didn't work completely
                  if (matchingStatusCount < filteredTests.length &&
                      matchingStatusCount > 0) {
                    print(
                        'API filtering incomplete, applying local status filter as fallback');
                    filteredTests = filteredTests
                        .where((test) =>
                            test['status'].toString() == statusFilter.value)
                        .toList();
                  }
                }

                // Apply search query if it exists
                if (searchQuery.value.isNotEmpty) {
                  filteredTests = labController.searchTests(searchQuery.value);
                }

                if (filteredTests.isEmpty) {
                  return Center(
                    child: Text(
                      'No tests found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  );
                }

                // Group tests by date
                final Map<String, List<Map<String, dynamic>>> groupedTests = {};
                // Track bsDate for each date group
                final Map<String, String> dateToBsDate = {};

                for (var test in filteredTests) {
                  final date = test['date'] as String;
                  if (!groupedTests.containsKey(date)) {
                    groupedTests[date] = [];
                    // Store the bsDate from the first test in each date group
                    dateToBsDate[date] = test['bsDate'] as String? ?? '';
                  }
                  groupedTests[date]!.add(test);
                }

                // Sort dates in descending order (newest first)
                final sortedDates = groupedTests.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return Stack(
                  children: [
                    ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      // Total items = just the number of test cards (removed date headers from count)
                      itemCount: filteredTests.length +
                          (labController.hasMoreData.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Add a loading indicator at the end if there are more items to load
                        if (index == filteredTests.length &&
                            labController.hasMoreData.value) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Direct index mapping to test items without date headers
                        int testIndex = 0;
                        int remainingIndex = index;

                        // Find which test to show based on the index
                        for (final date in sortedDates) {
                          final testsInDate = groupedTests[date]!.length;

                          if (remainingIndex < testsInDate) {
                            // Found the test to display
                            return _buildTestCard(
                              test: groupedTests[date]![remainingIndex],
                              index: index,
                              expandedIndex: expandedCardIndex,
                            );
                          }

                          // Move to next date group
                          remainingIndex -= testsInDate;
                        }

                        // Fallback (should never happen)
                        return const SizedBox.shrink();
                      },
                    ),

                    // Loading indicator overlay for pagination loading
                    if (labController.isLoading.value &&
                        labController.filteredRecentTests.isNotEmpty)
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 6,
                          width: double.infinity,
                          child: LinearProgressIndicator(),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Basic filters (always visible)
  Widget _buildBasicFilters(
    RxString statusFilter,
    RxString searchQuery,
    LabController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search by name, ID or test',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        searchQuery.value = value;
                        if (value.length > 2 || value.isEmpty) {
                          controller.fetchAllTests(
                              searchTerm: value,
                              doctorId:
                                  controller.selectedDoctorId.value.isEmpty
                                      ? ''
                                      : controller.selectedDoctorId.value,
                              agent: controller.selectedAgentId.value.isEmpty
                                  ? ''
                                  : controller.selectedAgentId.value,
                              status: statusFilter.value == 'All'
                                  ? ''
                                  : statusFilter.value,
                              resetPage: true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: Obx(
                () => DropdownButton<String>(
                  value: statusFilter.value,
                  isDense: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  items: [
                    'All',
                    'Pending',
                    'In Progress',
                    'Completed',
                    'Canceled'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: value == 'All'
                              ? Colors.grey[600]
                              : value == 'Pending'
                                  ? Colors.orange
                                  : value == 'In Progress'
                                      ? Colors.blue
                                      : value == 'Completed'
                                          ? Colors.green
                                          : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      statusFilter.value = newValue;
                      print('Setting status filter to: $newValue');

                      // Apply new status filter to refetch data
                      controller.fetchAllTests(
                          status: newValue == 'All' ? '' : newValue,
                          doctorId: controller.selectedDoctorId.value.isEmpty
                              ? ''
                              : controller.selectedDoctorId.value,
                          agent: controller.selectedAgentId.value.isEmpty
                              ? ''
                              : controller.selectedAgentId.value,
                          searchTerm: searchQuery.value.isEmpty
                              ? ''
                              : searchQuery.value,
                          resetPage: true);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Advanced filters (can be hidden)
  Widget _buildAdvancedFilters(
    RxString statusFilter,
    LabController controller,
  ) {
    // Reactive variables for additional filters
    final RxString clientFilter = 'All'.obs;
    final RxString doctorFilter = 'All'.obs;
    final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
    final Rx<DateTime?> toDate = Rx<DateTime?>(null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Date range filters
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildDateSelector(
                    label: 'From Date',
                    date: fromDate.value,
                    onSelect: (date) {
                      fromDate.value = date;
                      print('Setting From Date: ${date?.toIso8601String()}');
                      controller.applyDateFilter(fromDate.value, toDate.value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Obx(
                  () => _buildDateSelector(
                    label: 'To Date',
                    date: toDate.value,
                    onSelect: (date) {
                      toDate.value = date;
                      print('Setting To Date: ${date?.toIso8601String()}');
                      controller.applyDateFilter(fromDate.value, toDate.value);
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Department, Agent and Doctor filters in a row
          Row(
            children: [
              // Agent filter
              Expanded(
                child: Obx(() => Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.selectedAgentId.value.isEmpty
                              ? 'All'
                              : controller.selectedAgentId.value,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All',
                              child: Text('All Agents',
                                  style: TextStyle(color: Colors.grey[600])),
                            ),
                            ...controller.agents
                                .where((agent) => agent.id != 0)
                                .map((agent) => DropdownMenuItem<String>(
                                      value: agent.id.toString(),
                                      child: Text(
                                        agent.agentName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87),
                                      ),
                                    )),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.applyAgentFilter(value);
                            }
                          },
                          icon: Icon(Icons.person,
                              color: Colors.teal[300], size: 18),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          hint: Text('Agent',
                              style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                    )),
              ),
              const SizedBox(width: 6),
              // Doctor filter
              Expanded(
                child: Obx(() => Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.selectedDoctorId.value.isEmpty
                              ? 'All'
                              : controller.selectedDoctorId.value,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All',
                              child: Text('All Doctors',
                                  style: TextStyle(color: Colors.grey[600])),
                            ),
                            ...controller.doctors
                                .where((doctor) => doctor.id != 0)
                                .map((doctor) => DropdownMenuItem<String>(
                                      value: doctor.id.toString(),
                                      child: Text(
                                        doctor.docName ?? 'Unknown Doctor',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87),
                                      ),
                                    )),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.applyDoctorIdFilter(value);
                            }
                          },
                          icon: Icon(Icons.medical_services,
                              color: Colors.purple[300], size: 18),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          hint: Text('Doctor',
                              style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: Get.context!,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          print('Date selected: ${picked.toIso8601String()}');
          onSelect(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border:
              date != null ? Border.all(color: Colors.green, width: 1) : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: date != null ? Colors.green : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? '${date.day}/${date.month}/${date.year}' : label,
                style: TextStyle(
                  color: date != null ? Colors.green : Colors.grey[600],
                  fontWeight:
                      date != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (date != null)
              InkWell(
                onTap: () => onSelect(null),
                child: Icon(Icons.clear, color: Colors.grey[600], size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required Map<String, dynamic> test,
    required int index,
    required RxInt expandedIndex,
  }) {
    final Color statusColor = test['status'] == 'Completed'
        ? Colors.green
        : test['status'] == 'Pending'
            ? Colors.orange
            : test['status'] == 'In Progress'
                ? Colors.blue
                : Colors.red;

    return Obx(() {
      final bool isExpanded = expandedIndex.value == index;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isExpanded ? 0.08 : 0.04),
              blurRadius: isExpanded ? 5 : 2,
              spreadRadius: isExpanded ? 1 : 0,
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isExpanded
                ? BorderSide(
                    color: AppConstantColors.labAccent.withOpacity(0.5),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          color: isExpanded
              ? AppConstantColors.labBackground.withOpacity(0.3)
              : Colors.white,
          child: Column(
            children: [
              // Main card content - clickable to expand/collapse
              InkWell(
                onTap: () {
                  // If this card is already expanded, collapse it
                  if (isExpanded) {
                    expandedIndex.value = -1;
                  } else {
                    // Otherwise, expand this card (which will collapse any other)
                    expandedIndex.value = index;
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isExpanded ? 12 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    test['patientName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildInfoTag(
                                  '${test['patientAge']} yrs',
                                  Icons.calendar_today,
                                  Colors.blueGrey,
                                ),
                                const SizedBox(width: 4),
                                _buildInfoTag(
                                  test['patientSex'],
                                  test['patientSex'] == 'Male'
                                      ? Icons.male
                                      : Icons.female,
                                  test['patientSex'] == 'Male'
                                      ? Colors.blue
                                      : Colors.pink,
                                ),
                              ],
                            ),
                          ),
                          // View details icon/button
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? AppConstantColors.labAccent.withOpacity(
                                      0.1,
                                    )
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 14,
                                color: isExpanded
                                    ? AppConstantColors.labAccent
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Status tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              test['status'],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:
                                  AppConstantColors.labAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.science_outlined,
                              size: 12,
                              color: AppConstantColors.labAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.numbers,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            test['id'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),

                      // Doctor & Client info
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Referred by doctor
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 12,
                                  color: Colors.purple[700],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    test['referredBy'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.purple[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Client/Company
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 12,
                                  color: Colors.indigo[700],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    test['clientName'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.indigo[700],
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
                    ],
                  ),
                ),
              ),

              // Expandable content
              if (isExpanded)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact info row
                      Row(
                        children: [
                          Expanded(
                            child: _buildContactInfo(
                              icon: Icons.phone,
                              label: 'Mobile',
                              value: test['patientMobile'],
                              iconColor: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _buildContactInfo(
                              icon: Icons.location_on,
                              label: 'Address',
                              value: test['patientAddress'],
                              iconColor: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      // Action buttons section title
                      Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Action buttons - keep only the required ones
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.visibility,
                              label: 'View Test',
                              color: Colors.blue,
                              onTap: () {
                                Get.toNamed(
                                  '/lab/test-details',
                                  arguments: {'testId': test['id']},
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.description_outlined,
                              label: 'View Report',
                              color: Colors.teal,
                              onTap: () async {
                                // View report action
                                if (test['printId'] != null) {
                                  final int printId = int.tryParse(test['printId'].toString()) ?? 0;
                                  print('Opening report with printId: $printId');
                                  
                                  if (printId > 0) {
                                    try {
                                      await PDFViewerUtil.viewLabReport(printId);
                                    } catch (e) {
                                      print('Error showing PDF: $e');
                                      Get.snackbar(
                                        'Error', 
                                        'Failed to open report: ${e.toString()}',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red[100],
                                        colorText: Colors.red[900],
                                        duration: const Duration(seconds: 5),
                                      );
                                    }
                                  } else {
                                    Get.snackbar(
                                      'Error', 
                                      'Invalid report ID: $printId',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red[100],
                                      colorText: Colors.red[900],
                                    );
                                  }
                                } else {
                                  print('PrintId not available in test data: ${test['id']}');
                                  Get.snackbar(
                                    'Error', 
                                    'Report not available for this test',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red[100],
                                    colorText: Colors.red[900],
                                  );
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.send,
                              label: 'Send Report',
                              color: Colors.orange,
                              onTap: () {
                                // Send report action
                                if (test['printId'] != null) {
                                  final int printId = int.tryParse(test['printId'].toString()) ?? 0;
                                  if (printId > 0) {
                                    // Show the send report dialog instead of navigating to a new screen
                                    Get.dialog(
                                      Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: SendReportDialog(testData: test),
                                      ),
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Error', 
                                      'Invalid report ID: $printId',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red[100],
                                      colorText: Colors.red[900],
                                    );
                                  }
                                } else {
                                  print('PrintId not available in test data: ${test['id']}');
                                  Get.snackbar(
                                    'Error', 
                                    'Report not available for this test',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red[100],
                                    colorText: Colors.red[900],
                                  );
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.notifications_outlined,
                              label: 'Notify',
                              color: Colors.amber,
                              onTap: () {
                                // Notify action
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.delete_outline,
                              label: 'Delete',
                              color: Colors.red,
                              onTap: () {
                                // Delete report action
                                Get.defaultDialog(
                                  title: 'Delete Report',
                                  content: const Text(
                                    'Are you sure you want to delete this report?',
                                  ),
                                  textConfirm: 'Delete',
                                  textCancel: 'Cancel',
                                  confirmTextColor: Colors.white,
                                  cancelTextColor: Colors.grey[700],
                                  buttonColor: Colors.red,
                                  onConfirm: () {
                                    // Delete action
                                    Get.back();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date, {String bsDate = ''}) {
    final nepaliDate = _getNepaliDate(date, bsDate);
    final (dayOfWeek, nepaliDayOfWeek) = _getDayOfWeek(date);
    final timeAgo = _getTimeAgo(date);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: _smallPadding),
      padding: const EdgeInsets.symmetric(
          horizontal: _largePadding, vertical: _mediumPadding),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.green.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (nepaliDayOfWeek.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: _smallPadding),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: _mediumPadding, vertical: _smallPadding),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(_smallBorderRadius),
                ),
                child: Text(
                  nepaliDayOfWeek,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: _mediumFontSize,
                  ),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: _largeFontSize,
                ),
              ),
              const SizedBox(width: _mediumPadding),
              if (nepaliDate.isNotEmpty)
                Flexible(
                  child: Text(
                    '| मिति: $nepaliDate',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontSize: _mediumFontSize + 1,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
          if (timeAgo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: _smallPadding),
              child: Text(
                timeAgo,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: _mediumFontSize,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getNepaliDate(String date, String bsDate) {
    if (bsDate.isNotEmpty) {
      return _formatBsDate(bsDate);
    }
    return _convertToNepaliDate(date);
  }

  (String, String) _getDayOfWeek(String date) {
    try {
      final parts = date.split(' ');
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
      final nepaliWeekdays = [
        'सोमबार',
        'मंगलबार',
        'बुधबार',
        'बिहिबार',
        'शुक्रबार',
        'शनिबार',
        'आइतबार',
      ];
      return (
        weekdays[dateObj.weekday - 1],
        nepaliWeekdays[dateObj.weekday - 1]
      );
    } catch (e) {
      return ('', '');
    }
  }

  String _getTimeAgo(String date) {
    try {
      final parts = date.split(' ');
      final dateObj = DateTime.parse(
        '2024-${_getMonthNumber(parts[1])}-${parts[0].padLeft(2, '0')}',
      );
      final today = DateTime.now();
      final difference = today.difference(dateObj).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '$difference days ago';
      return '';
    } catch (e) {
      return '';
    }
  }

  String _formatBsDate(String bsDate) {
    try {
      final parts = bsDate.split('-');
      if (parts.length != 3) return bsDate;

      final nepaliMonthsFromNumber = {
        '01': 'बैशाख',
        '02': 'जेठ',
        '03': 'असार',
        '04': 'साउन',
        '05': 'भदौ',
        '06': 'असोज',
        '07': 'कार्तिक',
        '08': 'मंसिर',
        '09': 'पौष',
        '10': 'माघ',
        '11': 'फाल्गुन',
        '12': 'चैत्र',
      };

      final nepaliDigits = {
        '0': '०',
        '1': '१',
        '2': '२',
        '3': '३',
        '4': '४',
        '5': '५',
        '6': '६',
        '7': '७',
        '8': '८',
        '9': '९',
      };

      final nepaliDay =
          parts[2].split('').map((d) => nepaliDigits[d] ?? d).join('');
      final nepaliYear =
          parts[0].split('').map((d) => nepaliDigits[d] ?? d).join('');
      final nepaliMonth = nepaliMonthsFromNumber[parts[1]] ?? '';

      return '$nepaliDay $nepaliMonth $nepaliYear';
    } catch (e) {
      return bsDate;
    }
  }

  String _convertToNepaliDate(String date) {
    final nepaliMonths = {
      'Apr': 'चैत्र',
      'Mar': 'फाल्गुन',
      'Feb': 'माघ',
      'Jan': 'पौष',
      'Dec': 'मंसिर',
      'Nov': 'कार्तिक',
      'Oct': 'असोज',
      'Sep': 'भदौ',
      'Aug': 'साउन',
      'Jul': 'असार',
      'Jun': 'जेठ',
      'May': 'बैशाख',
    };

    final nepaliDays = {
      '01': '१७',
      '02': '१८',
      '03': '१९',
      '04': '२०',
      '05': '२१',
      '06': '२२',
      '07': '२३',
      '08': '२४',
      '09': '२५',
      '10': '२६',
      '11': '२७',
      '12': '२८',
      '13': '२९',
      '14': '३०',
      '15': '३१',
      '16': '३२',
      '17': '०१',
      '18': '०२',
      '19': '०३',
      '20': '०४',
      '21': '०५',
      '22': '०६',
      '23': '०७',
      '24': '०८',
      '25': '०९',
      '26': '१०',
      '27': '११',
      '28': '१२',
      '29': '१३',
      '30': '१४',
      '31': '१५',
    };

    final parts = date.split(' ');
    if (parts.length != 3) return '';

    final day = parts[0].padLeft(2, '0');
    final month = parts[1];
    final nepaliMonth = nepaliMonths[month] ?? '';
    final nepaliDay = nepaliDays[day] ?? '';

    return '$nepaliDay $nepaliMonth २०८०';
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
}

class SendReportDialog extends StatefulWidget {
  final Map<String, dynamic> testData;

  const SendReportDialog({Key? key, required this.testData}) : super(key: key);

  @override
  State<SendReportDialog> createState() => _SendReportDialogState();
}

class _SendReportDialogState extends State<SendReportDialog> {
  // Selected method (WhatsApp, SMS, Email)
  String selectedMethod = 'WhatsApp';
  
  // Recipients selection states
  bool sendToPatient = true;
  bool sendToDoctor = false;
  bool sendToClient = false;
  
  // Track if dropdown is expanded
  bool isDropdownExpanded = false;

  // Controllers for input fields
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstantColors.labBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      // Make the entire dialog scrollable to fix overflow issues
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Center(
              child: Text(
                'Send Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // WhatsApp, SMS, Email options in horizontal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMethodOption('WhatsApp', Icons.message, Colors.green),
                _buildMethodOption('SMS', Icons.sms, Colors.purple),
                _buildMethodOption('Email', Icons.email, Colors.blue),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Phone number input for WhatsApp and SMS
            if (selectedMethod == 'WhatsApp' || selectedMethod == 'SMS')
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.phone,
                      color: selectedMethod == 'WhatsApp' ? Colors.green : Colors.purple,
                    ),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
            
            // Email input for Email
            if (selectedMethod == 'Email')
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter email address',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Dropdown header
            InkWell(
              onTap: () {
                setState(() {
                  isDropdownExpanded = !isDropdownExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Recipients',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      isDropdownExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
            
            // Dropdown content
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isDropdownExpanded ? 180 : 0,  // Increased height for the new option
              curve: Curves.easeInOut,
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRecipientCheckbox(
                        'Send to Patient',
                        'Patient: ${widget.testData['patientName']}',
                        sendToPatient,
                        (value) => setState(() => sendToPatient = value ?? false),
                        Colors.blue,  // Set checkbox color to blue
                      ),
                      _buildRecipientCheckbox(
                        'Send to Doctor',
                        'Doctor: ${widget.testData['referredBy']}',
                        sendToDoctor,
                        (value) => setState(() => sendToDoctor = value ?? false),
                        Colors.blue,  // Set checkbox color to blue
                      ),
                      _buildRecipientCheckbox(
                        'Send to Client',
                        'Client: ${widget.testData['clientName']}',
                        sendToClient,
                        (value) => setState(() => sendToClient = value ?? false),
                        Colors.blue,  // Set checkbox color to blue
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Implement send functionality
                    _sendReport();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMethodOption(String method, IconData icon, Color color) {
    final bool isSelected = selectedMethod == method;
    
    return InkWell(
      onTap: () {
        setState(() {
          selectedMethod = method;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                ? Border.all(color: color, width: 2)
                : Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            method,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecipientCheckbox(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool?> onChanged,
    Color checkboxColor, // New parameter for checkbox color
  ) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: checkboxColor, // Set the active checkbox color
    );
  }
  
  void _sendReport() async {
    // Check if printId is available
    if (widget.testData['printId'] == null) {
      Get.snackbar(
        'Error',
        'Report ID is not available for this test',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }
    
    final int printId = int.tryParse(widget.testData['printId'].toString()) ?? 0;
    if (printId <= 0) {
      Get.snackbar(
        'Error',
        'Invalid report ID: $printId',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // Determine send method (1: Email, 2: WhatsApp, 3: SMS)
    int sendMethod = 1; // Default to Email
    if (selectedMethod == 'WhatsApp') {
      sendMethod = 2;
    } else if (selectedMethod == 'SMS') {
      sendMethod = 3;
    }
    
    // Get recipient address based on selected method
    String recipientAddress = '';
    if (selectedMethod == 'WhatsApp' || selectedMethod == 'SMS') {
      recipientAddress = phoneController.text.trim();
      if (recipientAddress.isEmpty && !sendToPatient && !sendToDoctor && !sendToClient) {
        Get.snackbar(
          'Error',
          'Please enter a phone number or select at least one recipient',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }
    } else if (selectedMethod == 'Email') {
      recipientAddress = emailController.text.trim();
      if (recipientAddress.isEmpty && !sendToPatient && !sendToDoctor && !sendToClient) {
        Get.snackbar(
          'Error',
          'Please enter an email address or select at least one recipient',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }
    }
    
    try {
      // Create report model
      final reportModel = SendReportModel(
        id: printId,
        sendMethod: sendMethod,
        recipientAddress: recipientAddress,
        usePatientContact: sendToPatient,
        sendToClient: sendToClient,
        sendToDoctor: sendToDoctor,
      );
      
      // Get report service
      final reportService = Get.put(ReportService());
      
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Send report
      final success = await reportService.sendReport(reportModel);
      
      // Close loading indicator
      Get.back();
      
      if (success) {
        // Show success message
        Get.snackbar(
          'Report Sent',
          'Report sent successfully via $selectedMethod',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to send report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
    }
  }
}
