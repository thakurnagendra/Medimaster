import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/screens/lab/lab_recent_tests_screen.dart';
import 'package:medimaster/screens/lab/lab_transaction_screen.dart';
import 'package:medimaster/screens/lab/Lab_report_Menus/credit_list.dart';
import 'package:medimaster/screens/lab/Lab_report_Menus/test_list.dart';
import 'package:medimaster/screens/lab/Lab_report_Menus/test_wise_investigation.dart';
import 'package:medimaster/screens/lab/Lab_report_Menus/agent_wise_billing_detail.dart';
import 'package:medimaster/screens/lab/Lab_report_Menus/doctor_wise_report_summary.dart';
import 'package:medimaster/screens/lab/Lab_report_Menus/agent_wise_billing_and_summary/agent_wise_selection_dialog.dart';

class LabReportScreen extends StatelessWidget {
  const LabReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE8F5E9,
      ), // Light green background for lab
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildReportCategories(),
                const SizedBox(height: 20),
                _buildReportsMenuHeader(),
                const SizedBox(height: 12),
                _buildReportMenuList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lab Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'View and manage all lab reports',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildReportCategories() {
    final categories = [
      {
        'title': 'Investigation',
        'icon': Icons.science,
        'color': Colors.red,
        'count': '143',
      },
      {
        'title': 'Billing',
        'icon': Icons.receipt_long,
        'color': Colors.purple,
        'count': '87',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryItem(
          title: category['title'] as String,
          icon: category['icon'] as IconData,
          color: category['color'] as Color,
          count: category['count'] as String,
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required String title,
    required IconData icon,
    required Color color,
    required String count,
  }) {
    // Get device screen size
    final Size screenSize = MediaQuery.of(Get.context!).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isMediumScreen =
        screenSize.width >= 360 && screenSize.width < 600;

    // Calculate responsive sizes
    final double iconSize = isSmallScreen ? 20 : (isMediumScreen ? 22 : 24);
    final double iconPadding = isSmallScreen ? 8 : (isMediumScreen ? 9 : 10);
    final double titleFontSize =
        isSmallScreen ? 11 : (isMediumScreen ? 12 : 13);
    final double countFontSize = isSmallScreen ? 9 : (isMediumScreen ? 10 : 11);
    final double verticalPadding =
        isSmallScreen ? 10 : (isMediumScreen ? 11 : 12);
    final double horizontalPadding =
        isSmallScreen ? 6 : (isMediumScreen ? 7 : 8);

    return InkWell(
      onTap: () {
        // Navigate to the appropriate screen based on the category
        if (title == 'Investigation') {
          Get.to(() => const LabRecentTestsScreen());
        } else if (title == 'Billing') {
          // Navigate to Billing/Transaction screen
          Get.to(() => const LabTransactionScreen(showBackButton: true));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 1 : 2),
            Text(
              '$count reports',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: countFontSize,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsMenuHeader() {
    return const Text(
      'Reports Menu',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }

  Widget _buildReportMenuList() {
    // List of report menu items
    final reportMenuItems = [
      {'title': 'Credit List', 'icon': Icons.credit_card},
      {'title': 'Test List', 'icon': Icons.list_alt},
      {'title': 'Agent Wise Billing & Summary', 'icon': Icons.person_search},
      {'title': 'Test Wise Investigation', 'icon': Icons.biotech},
      {'title': 'Agent Wise Billing Detail', 'icon': Icons.assignment},
      {'title': 'Doctor Wise Report & Summary', 'icon': Icons.medical_services},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling for this list
      itemCount: reportMenuItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = reportMenuItems[index];
        return _buildReportMenuItem(
          title: item['title'] as String,
          icon: item['icon'] as IconData,
        );
      },
    );
  }

  Widget _buildReportMenuItem({
    required String title,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        // Navigate to appropriate screen based on menu item title
        switch (title) {
          case 'Credit List':
            Get.to(() => const LabReportMenuCreditListScreen());
            break;
          case 'Test List':
            Get.to(() => const LabReportMenuTestListScreen());
            break;
          case 'Agent Wise Billing & Summary':
            Get.dialog(const AgentWiseSelectionDialog());
            break;
          case 'Test Wise Investigation':
            Get.to(() => const LabReportMenuTestWiseInvestigationScreen());
            break;
          case 'Agent Wise Billing Detail':
            Get.to(() => const LabReportMenuAgentWiseBillingDetailScreen());
            break;
          case 'Doctor Wise Report & Summary':
            Get.to(() => const LabReportMenuDoctorWiseReportSummaryScreen());
            break;
          default:
            Get.snackbar(
              "Error",
              "Invalid report type selected",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.7),
              colorText: Colors.white,
            );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
