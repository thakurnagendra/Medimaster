import 'package:flutter/material.dart';
import 'package:medimaster/screens/main_screen.dart';

class ReportsScreen extends StatelessWidget {
  final String moduleType;

  const ReportsScreen({super.key, this.moduleType = 'default'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ModuleScreenFactory.getModuleColor(moduleType),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moduleType == 'lab'
                    ? 'Lab Reports'
                    : moduleType == 'billing'
                    ? 'Billing Reports'
                    : 'Reports',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 20),
              _buildReportCategories(),
              const SizedBox(height: 20),
              _buildRecentReports(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCategories() {
    // Different report categories based on module type
    List<Widget> categoryItems = [];

    if (moduleType == 'lab') {
      categoryItems = [
        _reportCategoryItem(Icons.science, 'Test Results'),
        _reportCategoryItem(Icons.analytics, 'Lab Analytics'),
        _reportCategoryItem(Icons.people, 'Patient Tests'),
        _reportCategoryItem(Icons.inventory, 'Lab Inventory'),
        _reportCategoryItem(Icons.trending_up, 'Test Trends'),
        _reportCategoryItem(Icons.schedule, 'Test Schedule'),
      ];
    } else if (moduleType == 'billing') {
      categoryItems = [
        _reportCategoryItem(Icons.receipt, 'Invoices'),
        _reportCategoryItem(Icons.payments, 'Payments'),
        _reportCategoryItem(Icons.account_balance, 'Revenue'),
        _reportCategoryItem(Icons.pending_actions, 'Outstanding'),
        _reportCategoryItem(Icons.timeline, 'Financial Trends'),
        _reportCategoryItem(Icons.account_balance_wallet, 'Transactions'),
      ];
    } else {
      categoryItems = [
        _reportCategoryItem(Icons.bar_chart, 'Financial'),
        _reportCategoryItem(Icons.people, 'Patient'),
        _reportCategoryItem(Icons.medical_services, 'Clinical'),
        _reportCategoryItem(Icons.trending_up, 'Revenue'),
        _reportCategoryItem(Icons.analytics, 'Analytics'),
        _reportCategoryItem(Icons.calendar_today, 'Schedule'),
      ];
    }

    // Get accent color based on module type
    Color accentColor = ModuleScreenFactory.getModuleAccentColor(moduleType);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              moduleType == 'lab'
                  ? 'Lab Report Categories'
                  : moduleType == 'billing'
                  ? 'Billing Report Categories'
                  : 'Report Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: categoryItems,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCategoryItem(IconData icon, String title) {
    // Get accent color based on module type
    Color accentColor = ModuleScreenFactory.getModuleAccentColor(moduleType);

    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: accentColor),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports() {
    final List<Widget> reportItems = [];

    if (moduleType == 'lab') {
      reportItems.addAll([
        _reportItem(
          'Lab Test Results',
          'Monthly test results statistics',
          'Apr 10, 2024',
          Icons.science,
        ),
        _reportItem(
          'Equipment Usage',
          'Lab equipment utilization report',
          'Apr 05, 2024',
          Icons.settings,
        ),
        _reportItem(
          'Test Turnaround Time',
          'Average processing time for lab tests',
          'Apr 02, 2024',
          Icons.timer,
        ),
        _reportItem(
          'Sample Collection',
          'Daily sample collection statistics',
          'Mar 28, 2024',
          Icons.opacity,
        ),
        _reportItem(
          'Test Accuracy',
          'Quality control and accuracy metrics',
          'Mar 25, 2024',
          Icons.check_circle,
        ),
      ]);
    } else if (moduleType == 'billing') {
      reportItems.addAll([
        _reportItem(
          'Monthly Revenue',
          'Billing revenue for April 2024',
          'Apr 10, 2024',
          Icons.bar_chart,
        ),
        _reportItem(
          'Outstanding Payments',
          'Unpaid invoices report',
          'Apr 08, 2024',
          Icons.money_off,
        ),
        _reportItem(
          'Insurance Claims',
          'Status of insurance claim submissions',
          'Apr 05, 2024',
          Icons.article,
        ),
        _reportItem(
          'Payment Methods',
          'Analysis of payment method usage',
          'Apr 02, 2024',
          Icons.payment,
        ),
        _reportItem(
          'Refund Report',
          'Monthly refunds and adjustments',
          'Mar 28, 2024',
          Icons.keyboard_return,
        ),
      ]);
    } else {
      reportItems.addAll([
        _reportItem(
          'Monthly Revenue',
          'Financial analysis for March 2023',
          'Mar 31, 2023',
          Icons.bar_chart,
        ),
        _reportItem(
          'Patient Statistics',
          'New patient registrations and demographics',
          'Mar 28, 2023',
          Icons.people,
        ),
        _reportItem(
          'Test Results Summary',
          'Overview of lab test results',
          'Mar 25, 2023',
          Icons.science,
        ),
        _reportItem(
          'Staff Performance',
          'Quarterly performance metrics',
          'Mar 20, 2023',
          Icons.assessment,
        ),
        _reportItem(
          'Inventory Status',
          'Current stock levels and requirements',
          'Mar 15, 2023',
          Icons.inventory,
        ),
      ]);
    }

    // Get accent color based on module type
    Color accentColor = ModuleScreenFactory.getModuleAccentColor(moduleType);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              moduleType == 'lab'
                  ? 'Recent Lab Reports'
                  : moduleType == 'billing'
                  ? 'Recent Billing Reports'
                  : 'Recent Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            ...reportItems,
          ],
        ),
      ),
    );
  }

  Widget _reportItem(
    String title,
    String description,
    String date,
    IconData icon,
  ) {
    // Get accent color based on module type
    Color accentColor = ModuleScreenFactory.getModuleAccentColor(moduleType);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Icon(Icons.download, color: accentColor, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
