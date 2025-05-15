import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/controllers/lab_transaction_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LabTransactionScreen extends StatelessWidget {
  const LabTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get device screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    // Initialize controller
    final LabTransactionController controller = Get.put(
      LabTransactionController(),
    );

    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Lab Transactions',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Toggle filters button
                      Obx(
                        () => TextButton.icon(
                          onPressed: () => controller.showFilters.value =
                              !controller.showFilters.value,
                          icon: Icon(
                            controller.showFilters.value
                                ? Icons.filter_list_off
                                : Icons.filter_list,
                            color: Colors.green,
                            size: isSmallScreen ? 18 : 24,
                          ),
                          label: Text(
                            controller.showFilters.value
                                ? (isSmallScreen ? 'Hide' : 'Hide Filters')
                                : (isSmallScreen ? 'Filter' : 'Show Filters'),
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and track all your lab transactions',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),

            // Basic search - always visible
            _buildBasicSearch(controller, isSmallScreen),

            // Advanced filters that can be toggled
            Obx(
              () => controller.showFilters.value
                  ? _buildAdvancedFilters(
                      context,
                      isSmallScreen,
                      controller,
                    )
                  : const SizedBox.shrink(),
            ),

            // Transaction list
            _buildTransactionList(controller, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSearch(
    LabTransactionController controller,
    bool isSmallScreen,
  ) {
    // Create a TextEditingController that updates initially but won't cause infinite loop
    final TextEditingController searchController = TextEditingController(
      text: controller.searchQuery.value,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
              height: isSmallScreen ? 36 : 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: isSmallScreen ? 16 : 20,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                      decoration: InputDecoration(
                        hintText: isSmallScreen
                            ? 'Search transactions'
                            : 'Search by patient name, bill number',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        isDense: isSmallScreen,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        // Process all text changes consistently
                        // Empty searches
                        if (value.isEmpty) {
                          controller.applySearchFilter('');
                          return;
                        }

                        // Non-empty searches
                        if (value.contains(' ') || value.length >= 4) {
                          // Name-like search (with space or 4+ characters)
                          controller.searchByExactName(value);
                        } else if (value.length >= 2) {
                          // Shorter queries (2-3 characters)
                          controller.applySearchFilter(value);
                        }
                        // For single characters, do nothing until we have at least 2
                      },
                    ),
                  ),
                  Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return InkWell(
                        onTap: () {
                          // Clear search field and reset controller
                          controller.applySearchFilter('');
                          searchController.clear();
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.grey[600],
                          size: isSmallScreen ? 16 : 18,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
            height: isSmallScreen ? 36 : 40,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 26),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(color: Colors.green.withValues(alpha: 77)),
            ),
            child: TextButton.icon(
              onPressed: () {
                // Add new transaction
              },
              icon: Icon(
                Icons.add,
                color: Colors.green,
                size: isSmallScreen ? 16 : 18,
              ),
              label: Text(
                'New',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 11 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters(
    BuildContext context,
    bool isSmallScreen,
    LabTransactionController controller,
  ) {
    // Reactive variables for additional filters
    final Rx<DateTime?> fromDate = controller.fromDate;
    final Rx<DateTime?> toDate = controller.toDate;

    // Determine if we need to use a vertical layout for small screens in landscape
    final bool useVerticalLayout = isSmallScreen &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 4 : 6,
      ),
      color: Colors.white.withValues(alpha: 243),
      child: Column(
        children: [
          // Date range filters in a more compact layout
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildDateSelector(
                    label: 'From Date',
                    date: fromDate.value,
                    onSelect: (date) {
                      controller.applyDateFilter(date, toDate.value);
                    },
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Expanded(
                child: Obx(
                  () => _buildDateSelector(
                    label: 'To Date',
                    date: toDate.value,
                    onSelect: (date) {
                      controller.applyDateFilter(fromDate.value, date);
                    },
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Department and Doctor filters in a row
          Row(
            children: [
              // Department filter
              Expanded(
                child: Obx(
                  () => Container(
                    height: isSmallScreen ? 36 : 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 16 : 20,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 26),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.clientFilter.value,
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'All',
                            child: Text('All Departments'),
                          ),
                          ...controller.departments.where((d) => d.id != 0).map(
                                (dept) => DropdownMenuItem<String>(
                                  value: dept.departmentName ??
                                      'Unknown Department',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo
                                              .withValues(alpha: 26),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.business,
                                          size: isSmallScreen ? 14 : 16,
                                          color: Colors.indigo[700],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          dept.departmentName ??
                                              'Unknown Department',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.applyClientFilter(value);
                          }
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withValues(alpha: 26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.indigo[700],
                            size: isSmallScreen ? 16 : 20,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                        hint: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withValues(alpha: 26),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.business,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.indigo[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Department'),
                          ],
                        ),
                        dropdownColor: Colors.white,
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              // Doctor filter
              Expanded(
                child: Obx(
                  () => Container(
                    height: isSmallScreen ? 36 : 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 16 : 20,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 26),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.doctorFilter.value,
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'All',
                            child: Text('All Doctors'),
                          ),
                          ...controller.doctors.where((d) => d.id != 0).map(
                                (doctor) => DropdownMenuItem<String>(
                                  value: doctor.docName ?? 'Unknown Doctor',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.purple
                                              .withValues(alpha: 26),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.medical_services,
                                          size: isSmallScreen ? 14 : 16,
                                          color: Colors.purple[700],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          doctor.docName ?? 'Unknown Doctor',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.applyDoctorFilter(value);
                          }
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.purple[700],
                            size: isSmallScreen ? 16 : 20,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                        hint: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 26),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.medical_services,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.purple[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Doctor'),
                          ],
                        ),
                        dropdownColor: Colors.white,
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Filter chips / Applied filters
          Obx(
            () => _buildAppliedFilters(
              clientFilter: controller.clientFilter.value != 'All'
                  ? controller.clientFilter.value
                  : null,
              agentFilter: null, // Removed agent filter
              doctorFilter: controller.doctorFilter.value != 'All'
                  ? controller.doctorFilter.value
                  : null,
              fromDate: fromDate.value,
              toDate: toDate.value,
              onClearClient: () => controller.applyClientFilter('All'),
              onClearAgent: () {}, // Removed agent clear
              onClearDoctor: () => controller.applyDoctorFilter('All'),
              onClearDates: () => controller.applyDateFilter(null, null),
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedFilters({
    String? clientFilter,
    String? agentFilter,
    String? doctorFilter,
    DateTime? fromDate,
    DateTime? toDate,
    required VoidCallback onClearClient,
    required VoidCallback onClearAgent,
    required VoidCallback onClearDoctor,
    required VoidCallback onClearDates,
    required bool isSmallScreen,
  }) {
    // If no filters applied, return empty container
    if (clientFilter == null &&
        agentFilter == null &&
        doctorFilter == null &&
        fromDate == null &&
        toDate == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Applied Filters',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            TextButton(
              onPressed: () {
                onClearClient();
                onClearAgent();
                onClearDoctor();
                onClearDates();
              },
              child: Text(
                'Reset All',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: isSmallScreen ? 28 : 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (clientFilter != null)
                _buildFilterChip(
                  label: 'Department: $clientFilter',
                  color: Colors.indigo,
                  onClear: onClearClient,
                  isSmallScreen: isSmallScreen,
                ),
              if (agentFilter != null)
                _buildFilterChip(
                  label: 'Agent: $agentFilter',
                  color: Colors.teal,
                  onClear: onClearAgent,
                  isSmallScreen: isSmallScreen,
                ),
              if (doctorFilter != null)
                _buildFilterChip(
                  label: 'Doctor: $doctorFilter',
                  color: Colors.purple,
                  onClear: onClearDoctor,
                  isSmallScreen: isSmallScreen,
                ),
              if (fromDate != null || toDate != null)
                _buildFilterChip(
                  label:
                      'Date: ${fromDate != null ? '${fromDate.day}/${fromDate.month}/${fromDate.year}' : 'Any'} → ${toDate != null ? '${toDate.day}/${toDate.month}/${toDate.year}' : 'Now'}',
                  color: Colors.green,
                  onClear: onClearDates,
                  isSmallScreen: isSmallScreen,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter({
    required RxString value,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
    required String hint,
    required Function(String?) onChanged,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
      height: isSmallScreen ? 36 : 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value: value.value,
            items: items
                .map(
                  (String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            icon: Icon(icon, color: iconColor, size: isSmallScreen ? 14 : 16),
            hint: Text(
              hint,
              style: TextStyle(fontSize: isSmallScreen ? 12 : 13),
            ),
            isDense: isSmallScreen,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onSelect,
    required bool isSmallScreen,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2025),
        );
        if (pickedDate != null) {
          onSelect(pickedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
          border: Border.all(color: Colors.grey.withValues(alpha: 26)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: isSmallScreen ? 14 : 16,
              color: Colors.grey[700],
            ),
            SizedBox(width: isSmallScreen ? 4 : 8),
            Expanded(
              child: Text(
                date != null ? '${date.day}/${date.month}/${date.year}' : label,
                style: TextStyle(
                  color: date != null ? Colors.grey[800] : Colors.grey[600],
                  fontSize: isSmallScreen ? 11 : 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (date != null)
              InkWell(
                onTap: () => onSelect(null),
                child: Icon(
                  Icons.clear,
                  size: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required Color color,
    required VoidCallback onClear,
    required bool isSmallScreen,
  }) {
    return Container(
      margin: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 26),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: color.withValues(alpha: 77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          InkWell(
            onTap: onClear,
            child: Icon(
              Icons.clear,
              color: color,
              size: isSmallScreen ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    LabTransactionController controller,
    bool isSmallScreen,
  ) {
    return Expanded(
      child: Obx(() {
        // Handle authentication errors
        if (controller.authError.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text(
                  'Authentication Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your session has expired. Please try refreshing.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Try to refresh token and fetch data again
                    controller.refreshAndRetry();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.searchQuery.value.isNotEmpty
                      ? Icons.search_off
                      : Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  controller.searchQuery.value.isNotEmpty
                      ? 'No results found for "${controller.searchQuery.value}"'
                      : 'No transactions found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.searchQuery.value.isNotEmpty
                      ? controller.searchQuery.value.length >= 4
                          ? 'We couldn\'t find any transactions matching this exact name. Try a different spelling or clear the search.'
                          : 'Try different search terms or clear filters'
                      : 'Try adjusting your filters or create a new transaction',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                if (controller.searchQuery.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Clear the search completely
                        controller.applySearchFilter('');
                        // Fetch transactions again with no search filter
                        controller.fetchTransactions();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Clear Search'),
                    ),
                  ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Transaction count indicator
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 8,
              ),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Showing ${controller.displayedItemCount} of ${controller.totalItemCount} items',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Add refresh button to manually refresh data and token
                      IconButton(
                        onPressed: () {
                          controller.refreshData();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.green[600],
                          size: isSmallScreen ? 18 : 20,
                        ),
                        tooltip: 'Refresh',
                        constraints: BoxConstraints.tightFor(
                          width: isSmallScreen ? 30 : 40,
                          height: isSmallScreen ? 30 : 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        onPressed: () {
                          // Show printer options
                        },
                        icon: Icon(
                          Icons.print,
                          color: Colors.grey[600],
                          size: isSmallScreen ? 18 : 20,
                        ),
                        tooltip: 'Print',
                        constraints: BoxConstraints.tightFor(
                          width: isSmallScreen ? 30 : 40,
                          height: isSmallScreen ? 30 : 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        onPressed: () {
                          // Export data
                        },
                        icon: Icon(
                          Icons.download,
                          color: Colors.grey[600],
                          size: isSmallScreen ? 18 : 20,
                        ),
                        tooltip: 'Export',
                        constraints: BoxConstraints.tightFor(
                          width: isSmallScreen ? 30 : 40,
                          height: isSmallScreen ? 30 : 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Use PagedListView for true virtualization
            Expanded(
              child: Container(
                color: AppConstantColors.labBackground,
                child: RefreshIndicator(
                  onRefresh: () async {
                    return controller.refreshData();
                  },
                  child: buildVirtualizedListView(controller, isSmallScreen),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildVirtualizedListView(
    LabTransactionController controller,
    bool isSmallScreen,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 500) {
          if (!controller.isLoading.value && controller.hasMoreData.value) {
            controller.loadMore();
          }
        }
        return true;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
        // Enable caching of items
        cacheExtent: 1000,
        // Add keep alive
        addAutomaticKeepAlives: true,
        // Add repaint boundaries
        addRepaintBoundaries: true,
        itemCount: controller.transactions.length +
            (controller.hasMoreData.value ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator at the end
          if (index == controller.transactions.length &&
              controller.hasMoreData.value) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading more...',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Build a transaction card with optimizations
          return AutomaticKeepAliveWrapper(
            child: RepaintBoundary(
              child: _buildTransactionCard(
                transaction: controller.transactions[index],
                index: index,
                controller: controller,
                isSmallScreen: isSmallScreen,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(String date, bool isSmallScreen) {
    // Extract both English and Nepali dates
    String englishDate = date;
    String nepaliMonth = '';

    // This is just an example mapping - in real app, you would use proper date conversion
    final Map<String, String> nepaliMonths = {
      'Apr': 'चैत्र',
      'Mar': 'फाल्गुन',
      'Feb': 'माघ',
      'Jan': 'पौष',
    };

    // Parse English date like "04 Apr 2024"
    final parts = date.split(' ');
    String nepaliDate = '';
    if (parts.length == 3) {
      final day = parts[0];
      final month = parts[1];
      final year = parts[2];

      // Get Nepali month name
      nepaliMonth = nepaliMonths[month] ?? '';

      // Fake Nepali day conversion (in real app, use proper conversion library)
      final Map<String, String> nepaliDays = {
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

      final nepaliDay = nepaliDays[day.padLeft(2, '0')] ?? '';
      nepaliDate = '$nepaliDay $nepaliMonth २०८०';
    }

    // Get day name of week
    String dayOfWeek = '';
    try {
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
      dayOfWeek = weekdays[dateObj.weekday - 1];
    } catch (e) {
      dayOfWeek = '';
    }

    // Calculate number of days ago
    String timeAgo = '';
    try {
      final dateObj = DateTime.parse(
        '2024-${_getMonthNumber(parts[1])}-${parts[0].padLeft(2, '0')}',
      );
      final today = DateTime.now();
      final difference = today.difference(dateObj).inDays;

      if (difference == 0) {
        timeAgo = 'Today';
      } else if (difference == 1) {
        timeAgo = 'Yesterday';
      } else if (difference < 7) {
        timeAgo = '$difference days ago';
      }
    } catch (e) {
      timeAgo = '';
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isSmallScreen ? 4 : 6),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppConstantColors.labBackground.withValues(alpha: 243),
        border: Border(
          bottom:
              BorderSide(color: Colors.green.withValues(alpha: 77), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Date, day name, and मिति inline
          Expanded(
            child: Row(
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                const SizedBox(width: 4),
                if (nepaliDate.isNotEmpty)
                  Text(
                    '| मिति: $nepaliDate',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontSize: isSmallScreen ? 10 : 11,
                    ),
                  ),
                SizedBox(width: isSmallScreen ? 6 : 10),
                if (dayOfWeek.isNotEmpty)
                  Text(
                    '($dayOfWeek)',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // Right side: Time ago
          if (timeAgo.isNotEmpty)
            Text(
              timeAgo,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: isSmallScreen ? 11 : 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
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

  Widget _buildTransactionCard({
    required Map<String, dynamic> transaction,
    required int index,
    required LabTransactionController controller,
    required bool isSmallScreen,
  }) {
    final Color statusColor = transaction['statusColor'] as Color;

    return Obx(() {
      final bool isExpanded = controller.expandedCardIndex.value == index;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
                    color: Colors.green.withValues(alpha: 26),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          color: isExpanded
              ? AppConstantColors.labBackground.withValues(alpha: 243)
              : Colors.white,
          child: Column(
            children: [
              // Main card content - clickable to expand/collapse
              InkWell(
                onTap: () {
                  // If this card is already expanded, collapse it
                  if (isExpanded) {
                    controller.expandedCardIndex.value = -1;
                  } else {
                    // Otherwise, expand this card (which will collapse any other)
                    controller.expandedCardIndex.value = index;
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
                      // First row: Patient name, age, and amount
                      Row(
                        children: [
                          // Patient info
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    transaction['patientName'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildInfoTag(
                                  '${transaction['patientAge'] ?? '?'} yrs',
                                  Icons.calendar_today,
                                  Colors.blueGrey,
                                ),
                              ],
                            ),
                          ),

                          // Bill amount
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.payment,
                                  size: 10,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  transaction['amount'] ?? 'NPR 0',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Expand button
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? Colors.green.withValues(alpha: 26)
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
                                    ? Colors.green
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Second row: Bill number and date
                      Row(
                        children: [
                          // Bill number
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.receipt_outlined,
                                size: 12,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '#${transaction['billNumber'] ?? ''}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Date with Miti in one line
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 10,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                transaction['date'] ?? '-',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '| मिति: ${transaction['bsDate'] ?? '-'}',
                                style: TextStyle(
                                  color: Colors.amber[800],
                                  fontSize: 10,
                                ),
                              ),
                            ],
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
                      // Referred by and client
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
                                    'Dr: ${transaction['referredBy'] ?? 'Not specified'}',
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
                                    transaction['clientName'] ??
                                        'Not specified',
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

                      const SizedBox(height: 8),

                      // Contact info row
                      Row(
                        children: [
                          Expanded(
                            child: _buildContactInfo(
                              icon: Icons.phone,
                              label: 'Mobile',
                              value: transaction['mobile'] ?? 'Not specified',
                              iconColor: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _buildContactInfo(
                              icon: Icons.location_on,
                              label: 'Address',
                              value: transaction['address'] ?? 'Not specified',
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

                      // Action buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.receipt,
                              label: 'View Invoice',
                              color: Colors.blue,
                              onTap: () {
                                // View invoice action
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.print,
                              label: 'Print',
                              color: Colors.purple,
                              onTap: () {
                                // Print action
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.payment,
                              label: 'Payment',
                              color: Colors.green,
                              onTap: () {
                                // Payment action
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.share,
                              label: 'Share',
                              color: Colors.orange,
                              onTap: () {
                                // Share action
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.delete_outline,
                              label: 'Delete',
                              color: Colors.red,
                              onTap: () {
                                Get.defaultDialog(
                                  title: 'Delete Transaction',
                                  content: const Text(
                                    'Are you sure you want to delete this transaction?',
                                  ),
                                  textConfirm: 'Delete',
                                  textCancel: 'Cancel',
                                  confirmTextColor: Colors.white,
                                  cancelTextColor: Colors.grey[700],
                                  buttonColor: Colors.red,
                                  onConfirm: () {
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

  // Info tag widget (reused from recent tests screen)
  Widget _buildInfoTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 26),
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

  // Contact info widget (reused from recent tests screen)
  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    // Check if this is a phone/mobile contact and the value is a valid number
    bool isPhoneContact = label.toLowerCase() == 'mobile' &&
        value.isNotEmpty &&
        value != 'n/a' &&
        value != 'N/A';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: iconColor),
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
              if (isPhoneContact)
                InkWell(
                  onTap: () {
                    // Use url_launcher to open the dial pad with the phone number
                    final Uri telUri = Uri(scheme: 'tel', path: value);
                    launchUrl(telUri);
                  },
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
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

  // Action button widget (reused from recent tests screen)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AutomaticKeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const AutomaticKeepAliveWrapper({super.key, required this.child});

  @override
  _AutomaticKeepAliveWrapperState createState() =>
      _AutomaticKeepAliveWrapperState();
}

class _AutomaticKeepAliveWrapperState extends State<AutomaticKeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
