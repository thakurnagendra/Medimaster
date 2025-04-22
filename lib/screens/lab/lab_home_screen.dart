import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/controllers/main_controller.dart';
import 'package:medimaster/controllers/lab_controller.dart';
import 'package:medimaster/widgets/welcome_card.dart';
import 'package:medimaster/screens/lab/lab_recent_tests_screen.dart';
import 'package:medimaster/services/api_service.dart';

class LabHomeScreen extends StatelessWidget {
  const LabHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();
    final ApiService apiService = Get.find<ApiService>();
    final LabController labController = Get.put(
      LabController(apiService: apiService),
    );
    // Track the currently expanded card index
    final RxInt expandedCardIndex = RxInt(-1);

    // Get doctor name
    String doctorName = 'User';
    if (mainController.accounts.isNotEmpty &&
        mainController.activeAccountIndex.value <
            mainController.accounts.length) {
      doctorName = mainController
              .accounts[mainController.activeAccountIndex.value]['name'] ??
          'User';
    }

    Future<void> refreshData() async {
      try {
        await labController.refreshData();
      } catch (e) {
        // Show a snackbar if refresh fails completely
        Get.snackbar(
          'Refresh Failed',
          'Could not refresh data. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
      }
    }

    // Handle back button presses with confirmation dialog
    Future<bool> onWillPop() async {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Exit App?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF022C29),
                ),
              ),
              content: const Text(
                'Do you want to exit the MediMaster app?',
                style: TextStyle(fontSize: 15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              elevation: 5,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('No, Stay'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop(); // This will close the app
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A884),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Yes, Exit'),
                ),
              ],
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ) ??
          false;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: AppConstantColors.labBackground,
        body: SafeArea(
          child: Obx(
            () => RefreshIndicator(
              onRefresh: refreshData,
              color: AppConstantColors.labAccent,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WelcomeCard(
                          doctorName: doctorName,
                          message: 'You are in the lab module',
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderSection(labController),
                              const SizedBox(height: 20),
                              _buildBillingStatisticsSection(labController),
                              const SizedBox(height: 20),
                              _buildStatisticsSection(labController),
                              const SizedBox(height: 20),
                              _buildRecentTestsSection(
                                labController,
                                expandedCardIndex,
                              ),
                            ],
                          ),
                        ),
                        // Add extra space at bottom for pull to refresh
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                  // Loading indicator overlay
                  if (labController.isLoading.value)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppConstantColors.labAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(LabController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildDateDisplay()],
        ),
      ],
    );
  }

  Widget _buildTimePeriodSelector(LabController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButton<String>(
          value: controller.selectedTimePeriod.value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
          underline: const SizedBox(),
          isDense: true,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: controller.timePeriods
              .map(
                (String period) => DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                ),
              )
              .toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.changeTimePeriod(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateDisplay() {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Text(
      dateStr,
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildStatisticsSection(LabController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investigation Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Total Tests',
                  controller.totalTests.value,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Completed',
                  controller.completedTests.value,
                  Colors.green,
                ),
                _buildStatItem(
                  'Pending',
                  controller.pendingTests.value,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Today',
                  controller.todayTests.value,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            title == 'Total Tests'
                ? Icons.science
                : title == 'Completed'
                    ? Icons.check_circle
                    : title == 'Pending'
                        ? Icons.pending
                        : Icons.today,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBillingStatisticsSection(LabController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Billing Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Obx(
                      () => Text(
                        controller.revenueGrowth.value,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Revenue metrics row
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBillingMetricWithCount(
                  'Today',
                  controller.todayRevenue.value,
                  controller.todayBillCount.value.toString(),
                  Icons.today,
                  Colors.blue,
                ),
                _buildBillingMetricWithCount(
                  'This Week',
                  controller.weeklyRevenue.value,
                  controller.weekBillCount.value.toString(),
                  Icons.date_range,
                  Colors.indigo,
                ),
                _buildBillingMetricWithCount(
                  'This Month',
                  controller.monthlyRevenue.value,
                  controller.monthBillCount.value.toString(),
                  Icons.calendar_month,
                  Colors.purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Pending and outstanding row

          // Revenue chart
          const SizedBox(height: 20),
          const Text(
            'Weekly Revenue',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            padding: const EdgeInsets.only(top: 8),
            child: Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(controller.revenueData.length, (index) {
                  final double value = controller.revenueData[index].toDouble();
                  final double maxValue = controller.maxRevenue.value;
                  final double height =
                      maxValue > 0 ? 80 * (value / maxValue) : 0;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: 'Rs. ${value.toStringAsFixed(0)}',
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.6),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green.withOpacity(0.8),
                                  Colors.green.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.revenueLabels[index],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingMetric(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBillingMetricWithCount(
    String title,
    String amount,
    String count,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count bills',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBillingAlert(
    String title,
    String amount,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTestsSection(
    LabController controller,
    RxInt expandedCardIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstantColors.labBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Tests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all tests screen
                  Get.to(() => const LabRecentTestsScreen());
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value &&
                controller.allRecentTests.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (controller.allRecentTests.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No recent tests found',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            final tests = controller.allRecentTests.take(5).toList();
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];
                final Color statusColor = test['status'] == 'Completed'
                    ? Colors.green
                    : test['status'] == 'Pending'
                        ? Colors.orange
                        : test['status'] == 'In Progress'
                            ? Colors.blue
                            : Colors.red;

                return Obx(() {
                  final bool isExpanded = expandedCardIndex.value == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? AppConstantColors.labBackground.withOpacity(0.3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isExpanded ? 0.08 : 0.04,
                          ),
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
                                color: AppConstantColors.labAccent
                                    .withOpacity(0.5),
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
                                expandedCardIndex.value = -1;
                              } else {
                                // Otherwise, expand this card (which will collapse any other)
                                expandedCardIndex.value = index;
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
                                                maxLines: 2,
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
                                              ? AppConstantColors.labAccent
                                                  .withOpacity(0.1)
                                              : Colors.grey[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: AnimatedRotation(
                                          turns: isExpanded ? 0.5 : 0,
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                                          color: AppConstantColors.labAccent
                                              .withOpacity(0.1),
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
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
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
                                          value: test['patientMobile'] ?? 'N/A',
                                          iconColor: Colors.green,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildContactInfo(
                                          icon: Icons.location_on,
                                          label: 'Address',
                                          value:
                                              test['patientAddress'] ?? 'N/A',
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
                                          onTap: () {
                                            // View report action
                                          },
                                        ),
                                        _buildActionButton(
                                          icon: Icons.print,
                                          label: 'Print',
                                          color: Colors.deepPurple,
                                          onTap: () {
                                            // Print report action
                                          },
                                        ),
                                        _buildActionButton(
                                          icon: Icons.email_outlined,
                                          label: 'Email',
                                          color: Colors.orange,
                                          onTap: () {
                                            // Send to email action
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Second row of action buttons
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildActionButton(
                                          icon: Icons.message,
                                          label: 'WhatsApp',
                                          color: Colors.green,
                                          onTap: () {
                                            // Send to WhatsApp action
                                          },
                                        ),
                                        _buildActionButton(
                                          icon: Icons.sms_outlined,
                                          label: 'SMS Notify',
                                          color: Colors.blue,
                                          onTap: () {
                                            // Notify by SMS action
                                          },
                                        ),
                                        _buildActionButton(
                                          icon: Icons.notifications_outlined,
                                          label: 'Notify',
                                          color: Colors.amber,
                                          onTap: () {
                                            // Notify by system action
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
              },
            );
          }),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
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
}
