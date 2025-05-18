import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/controllers/main_controller.dart';
import 'package:medimaster/controllers/lab_controller.dart';
import 'package:medimaster/widgets/welcome_card.dart';
import 'package:medimaster/screens/lab/lab_recent_tests_screen.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:medimaster/utils/pdf_viewer_util.dart';
import 'package:medimaster/models/send_report_model.dart';
import 'package:medimaster/services/report_service.dart';
import 'package:medimaster/utils/logger.dart';
import 'package:medimaster/screens/lab/test_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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
                                        // View Test button - always shown for all statuses
                                        _buildActionButton(
                                          icon: Icons.remove_red_eye,
                                          label: 'View Test',
                                          color: Colors.blue,
                                          onTap: () {
                                            // Navigate to test list screen
                                            // Print patient details from raw API data
                                            print('\n=== Patient Details ===');
                                            print('Basic Information:');
                                            print('- Raw ID: ${test['id']}');
                                            print(
                                                '- Bill No: ${test['b_BillNo']}');
                                            // Use the numeric id for the API call
                                            final numericId =
                                                test['id']?.toString() ?? '';
                                            if (numericId.isEmpty) {
                                              Get.snackbar(
                                                  'Error', 'Test ID not found');
                                              return;
                                            }

                                            Get.to(() => TestListScreen(
                                                  investigationId: numericId,
                                                  patientName: test['b_Name'] ??
                                                      'Unknown',
                                                ));
                                          },
                                        ),

                                        // Show additional action buttons only for "Completed" tests
                                        if (test['status'] == 'Completed') ...[
                                          _buildActionButton(
                                            icon: Icons.description_outlined,
                                            label: 'View Report',
                                            color: Colors.teal,
                                            onTap: () async {
                                              // View report action
                                              if (test['printId'] != null) {
                                                final int printId =
                                                    int.tryParse(test['printId']
                                                            .toString()) ??
                                                        0;
                                                print(
                                                    'Opening report with printId: $printId');

                                                if (printId > 0) {
                                                  try {
                                                    await PDFViewerUtil
                                                        .viewLabReport(printId);
                                                  } catch (e) {
                                                    print(
                                                        'Error showing PDF: $e');
                                                    Get.snackbar(
                                                      'Error',
                                                      'Failed to open report: ${e.toString()}',
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                      backgroundColor:
                                                          Colors.red[100],
                                                      colorText:
                                                          Colors.red[900],
                                                      duration: const Duration(
                                                          seconds: 5),
                                                    );
                                                  }
                                                } else {
                                                  Get.snackbar(
                                                    'Error',
                                                    'Invalid report ID: $printId',
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[100],
                                                    colorText: Colors.red[900],
                                                  );
                                                }
                                              } else {
                                                print(
                                                    'PrintId not available in test data: ${test['id']}');
                                                Get.snackbar(
                                                  'Error',
                                                  'Report not available for this test',
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor:
                                                      Colors.red[100],
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
                                                final int printId =
                                                    int.tryParse(test['printId']
                                                            .toString()) ??
                                                        0;
                                                if (printId > 0) {
                                                  // Show the send report dialog instead of navigating to a new screen
                                                  Get.dialog(
                                                    Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: SendReportDialog(
                                                          testData: test),
                                                    ),
                                                  );
                                                } else {
                                                  Get.snackbar(
                                                    'Error',
                                                    'Invalid report ID: $printId',
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.red[100],
                                                    colorText: Colors.red[900],
                                                  );
                                                }
                                              } else {
                                                print(
                                                    'PrintId not available in test data: ${test['id']}');
                                                Get.snackbar(
                                                  'Error',
                                                  'Report not available for this test',
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor:
                                                      Colors.red[100],
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
                                              // Show the notify dialog
                                              Get.dialog(
                                                Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: NotifyDialog(
                                                      testData: test),
                                                ),
                                              );
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
                                                cancelTextColor:
                                                    Colors.grey[700],
                                                buttonColor: Colors.red,
                                                onConfirm: () {
                                                  // Delete action
                                                  Get.back();
                                                },
                                              );
                                            },
                                          ),
                                        ],
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
    // Check if this is a phone/mobile contact and the value is a valid number
    bool isPhoneContact = label.toLowerCase() == 'mobile' &&
        value.isNotEmpty &&
        value != 'n/a' &&
        value != 'N/A';

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
              if (isPhoneContact)
                InkWell(
                  onTap: () {
                    // Use url_launcher to open the dial pad with the phone number
                    final Uri telUri = Uri(scheme: 'tel', path: value);
                    launchUrl(telUri);
                  },
                  child: Text(
                    value,
                    style: const TextStyle(
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
  bool sendToPatient = false;
  bool sendToDoctor = false;
  bool sendToClient = false;

  // Track if dropdown is expanded
  bool isDropdownExpanded = false;

  // Loading state
  bool isLoading = false;

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
    return GestureDetector(
      // Dismiss keyboard when tapping outside of text fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.phone,
                        color: selectedMethod == 'WhatsApp'
                            ? Colors.green
                            : Colors.purple,
                      ),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    keyboardType: TextInputType.phone,
                    autocorrect: false,
                    autofillHints: null,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
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
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.blue,
                      ),
                      hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                    ),
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    enableSuggestions: true,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                        isDropdownExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                ),
              ),

              // Dropdown content
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isDropdownExpanded
                    ? 180
                    : 0, // Increased height for the new option
                curve: Curves.easeInOut,
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildRecipientCheckbox(
                          'Send to Patient',
                          'Patient: ${widget.testData['patientName'] ?? widget.testData['b_Name'] ?? 'Unknown'}',
                          sendToPatient,
                          (value) =>
                              setState(() => sendToPatient = value ?? false),
                          Colors.blue, // Set checkbox color to blue
                        ),
                        _buildRecipientCheckbox(
                          'Send to Doctor',
                          'Doctor: ${widget.testData['referredBy'] ?? widget.testData['b_ReferdBy'] ?? 'Unknown'}',
                          sendToDoctor,
                          (value) =>
                              setState(() => sendToDoctor = value ?? false),
                          Colors.blue, // Set checkbox color to blue
                        ),
                        _buildRecipientCheckbox(
                          'Send to Client',
                          'Client: ${widget.testData['clientName'] ?? widget.testData['refBy'] ?? 'Unknown'}',
                          sendToClient,
                          (value) =>
                              setState(() => sendToClient = value ?? false),
                          Colors.blue, // Set checkbox color to blue
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
                    onPressed: isLoading ? null : () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      disabledForegroundColor: Colors.grey[400],
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color:
                              isLoading ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            // Implement send functionality
                            _sendReport();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Sending...'),
                            ],
                          )
                        : const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
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

  // Helper to show snackbar and hide keyboard
  void _showSnackbar(String title, String message, bool isError) {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Show snackbar
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red[100] : Colors.green[100],
      colorText: isError ? Colors.red[900] : Colors.green[800],
      duration: Duration(seconds: isError ? 5 : 3),
    );
  }

  void _sendReport() async {
    // Hide keyboard if it's currently showing
    FocusScope.of(context).unfocus();

    // Check if printId is available
    if (widget.testData['printId'] == null) {
      _showSnackbar(
        'Error',
        'Report ID is not available for this test',
        true,
      );
      return;
    }

    final int printId =
        int.tryParse(widget.testData['printId'].toString()) ?? 0;
    if (printId <= 0) {
      _showSnackbar(
        'Error',
        'Invalid report ID: $printId',
        true,
      );
      return;
    }

    // Determine send method (1: Email, 2: WhatsApp, 3: SMS)
    int sendMethod = 1; // Default to Email
    if (selectedMethod == 'WhatsApp') {
      sendMethod = 2;
      Logger.i('WhatsApp selected as send method (sendMethod=2)');
    } else if (selectedMethod == 'SMS') {
      sendMethod = 3;
      Logger.i('SMS selected as send method (sendMethod=3)');
    } else {
      Logger.i('Email selected as send method (sendMethod=1)');
    }

    // Get recipient address based on selected method
    String recipientAddress = '';
    if (selectedMethod == 'WhatsApp' || selectedMethod == 'SMS') {
      // Get phone number and ensure it's properly formatted
      String phoneNumber = phoneController.text.trim();

      // Remove any non-digit characters that might have been added
      phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

      recipientAddress = phoneNumber;

      if (recipientAddress.isEmpty &&
          !sendToPatient &&
          !sendToDoctor &&
          !sendToClient) {
        _showSnackbar(
          'Error',
          'Please enter a phone number or select at least one recipient',
          true,
        );
        return;
      }
    } else if (selectedMethod == 'Email') {
      recipientAddress = emailController.text.trim();
      if (recipientAddress.isEmpty &&
          !sendToPatient &&
          !sendToDoctor &&
          !sendToClient) {
        _showSnackbar(
          'Error',
          'Please enter an email address or select at least one recipient',
          true,
        );
        return;
      }
    }

    // Create report model
    final reportModel = SendReportModel(
      id: printId,
      sendMethod: sendMethod,
      recipientAddress: recipientAddress,
      usePatientContact: sendToPatient,
      sendToClient: sendToClient,
      sendToDoctor: sendToDoctor,
    );

    // Log the report model for debugging
    Logger.i('Sending report with model: ${reportModel.toJson()}');

    // Set loading state to true
    setState(() {
      isLoading = true;
    });

    // Show loading indicator with text
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Container(
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
    );

    try {
      // Get report service
      final reportService = Get.put(ReportService());

      // Send report
      Logger.i('Sending report through ReportService');
      final success = await reportService.sendReport(reportModel);

      // First ensure loading dialog is closed
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Update loading state
      setState(() {
        isLoading = false;
      });

      // Add a delay to ensure the loading dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 300));

      if (success) {
        // Show success message
        Logger.i('Report sent successfully');
        _showSnackbar(
          'Report Sent',
          'Report sent successfully via $selectedMethod',
          false,
        );

        // Give time for the snackbar to appear before closing the dialog
        await Future.delayed(const Duration(milliseconds: 500));

        // Close the send report dialog last
        Navigator.of(context).pop();
      } else {
        Logger.e('Report sending failed');
        _showSnackbar(
          'Error',
          'Failed to send report',
          true,
        );
      }
    } catch (e) {
      // Ensure loading dialog is closed in case of error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Update loading state
      setState(() {
        isLoading = false;
      });

      // Show error message
      _showSnackbar(
        'Error',
        'Failed to send report: ${e.toString()}',
        true,
      );
    }
  }
}

class NotifyDialog extends StatefulWidget {
  final Map<String, dynamic> testData;

  const NotifyDialog({Key? key, required this.testData}) : super(key: key);

  @override
  State<NotifyDialog> createState() => _NotifyDialogState();
}

class _NotifyDialogState extends State<NotifyDialog> {
  // Selected method (WhatsApp, SMS, Email)
  String selectedMethod = 'WhatsApp';

  // Recipients selection states
  bool notifyPatient = false;
  bool notifyDoctor = false;
  bool notifyClient = false;

  // Track if dropdown is expanded
  bool isDropdownExpanded = false;

  // Loading state
  bool isLoading = false;

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
    return GestureDetector(
      // Dismiss keyboard when tapping outside of text fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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
                  'Send Notification',
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.phone,
                        color: selectedMethod == 'WhatsApp'
                            ? Colors.green
                            : Colors.purple,
                      ),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    keyboardType: TextInputType.phone,
                    autocorrect: false,
                    autofillHints: null,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
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
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.blue,
                      ),
                      hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                    ),
                    style: const TextStyle(color: Colors.black87),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    enableSuggestions: true,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Recipient',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        isDropdownExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                ),
              ),

              // Dropdown content
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isDropdownExpanded ? 60 : 0,
                curve: Curves.easeInOut,
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildRecipientCheckbox(
                          'Notify Patient',
                          'Patient: ${widget.testData['patientName'] ?? widget.testData['b_Name'] ?? 'Unknown'}',
                          notifyPatient,
                          (value) =>
                              setState(() => notifyPatient = value ?? false),
                          Colors.blue,
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
                    onPressed: isLoading ? null : () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      disabledForegroundColor: Colors.grey[400],
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color:
                              isLoading ? Colors.grey[400] : Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            // Implement notify functionality
                            _sendNotification();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Sending...'),
                            ],
                          )
                        : const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
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
    Color checkboxColor,
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
      activeColor: checkboxColor,
    );
  }

  // Helper to show snackbar and hide keyboard
  void _showSnackbar(String title, String message, bool isError) {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Show snackbar
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red[100] : Colors.green[100],
      colorText: isError ? Colors.red[900] : Colors.green[800],
      duration: Duration(seconds: isError ? 5 : 3),
    );
  }

  void _sendNotification() async {
    // Hide keyboard if it's currently showing
    FocusScope.of(context).unfocus();

    // Validate recipient based on method
    if ((selectedMethod == 'WhatsApp' || selectedMethod == 'SMS') &&
        phoneController.text.trim().isEmpty &&
        !notifyPatient) {
      _showSnackbar(
        'Error',
        'Please enter a phone number or select patient as recipient',
        true,
      );
      return;
    }

    if (selectedMethod == 'Email' &&
        emailController.text.trim().isEmpty &&
        !notifyPatient) {
      _showSnackbar(
        'Error',
        'Please enter an email address or select patient as recipient',
        true,
      );
      return;
    }

    // Set loading state to true
    setState(() {
      isLoading = true;
    });

    // Show loading indicator
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Container(
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
    );

    try {
      // Simulate API call with a delay
      await Future.delayed(const Duration(seconds: 2));

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Update loading state
      setState(() {
        isLoading = false;
      });

      // Add a delay to ensure the loading dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 300));

      // Show success message
      _showSnackbar(
        'Notification Sent',
        'Test results notification sent successfully via $selectedMethod',
        false,
      );

      // Give time for the snackbar to appear before closing the dialog
      await Future.delayed(const Duration(milliseconds: 500));

      // Close the notify dialog
      Navigator.of(context).pop();
    } catch (e) {
      // Ensure loading dialog is closed in case of error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Update loading state
      setState(() {
        isLoading = false;
      });

      // Show error message
      _showSnackbar(
        'Error',
        'Failed to send notification: ${e.toString()}',
        true,
      );
    }
  }
}
