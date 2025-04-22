import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpdReportScreen extends StatelessWidget {
  const OpdReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF8E1,
      ), // Light orange background for OPD
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
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

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPD Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'View and manage all outpatient department reports',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildReportCategories() {
    final categories = [
      {
        'title': 'Patient Reports',
        'icon': Icons.people,
        'color': Colors.blue,
        'count': '32',
      },
      {
        'title': 'Financial Reports',
        'icon': Icons.attach_money,
        'color': Colors.green,
        'count': '18',
      },
      {
        'title': 'Appointment Reports',
        'icon': Icons.calendar_today,
        'color': Colors.orange,
        'count': '24',
      },
      {
        'title': 'Doctor Reports',
        'icon': Icons.medical_services,
        'color': Colors.purple,
        'count': '12',
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            '$count reports',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    final RxString selectedTab = 'Recent'.obs;
    final List<String> tabs = [
      'Recent',
      'Patients',
      'Financial',
      'Appointments',
    ];

    final recentReports = [
      {
        'title': 'Monthly Patient Statistics',
        'id': 'REP-2024-001',
        'date': '30 Mar 2024',
        'type': 'Patient',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'title': 'Consultations Revenue Report',
        'id': 'REP-2024-002',
        'date': '28 Mar 2024',
        'type': 'Financial',
        'status': 'Pending',
        'statusColor': Colors.orange,
      },
      {
        'title': 'Doctor Performance Analysis',
        'id': 'REP-2024-003',
        'date': '25 Mar 2024',
        'type': 'Doctor',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'title': 'Weekly Appointment Summary',
        'id': 'REP-2024-004',
        'date': '20 Mar 2024',
        'type': 'Appointment',
        'status': 'Draft',
        'statusColor': Colors.grey,
      },
    ];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(
              () => Row(
                children:
                    tabs
                        .map(
                          (tab) => Expanded(
                            child: GestureDetector(
                              onTap: () => selectedTab.value = tab,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      selectedTab.value == tab
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tab,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        selectedTab.value == tab
                                            ? Colors.orange
                                            : Colors.grey,
                                    fontWeight:
                                        selectedTab.value == tab
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Recent reports list
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: recentReports.length,
                itemBuilder: (context, index) {
                  final report = recentReports[index];
                  return _buildReportItem(report);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    final IconData typeIcon =
        report['type'] == 'Patient'
            ? Icons.people
            : report['type'] == 'Financial'
            ? Icons.attach_money
            : report['type'] == 'Appointment'
            ? Icons.calendar_today
            : Icons.medical_services;

    final Color typeColor =
        report['type'] == 'Patient'
            ? Colors.blue
            : report['type'] == 'Financial'
            ? Colors.green
            : report['type'] == 'Appointment'
            ? Colors.orange
            : Colors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(typeIcon, color: typeColor, size: 16)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${report['type']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                    Text(
                      ' | ${report['id']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (report['statusColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  report['status'],
                  style: TextStyle(
                    color: report['statusColor'] as Color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                report['date'],
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.grey,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // Navigate to report details
            },
          ),
        ],
      ),
    );
  }
}
