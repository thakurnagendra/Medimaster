import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class IpdReportScreen extends StatelessWidget {
  const IpdReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.ipdBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportCategories(),
                      const SizedBox(height: 12),
                      _buildRecentReports(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IPD Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage and generate in-patient department reports',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildReportCategories() {
    final categories = [
      {
        'title': 'Patient Reports',
        'count': '42',
        'icon': Icons.person,
        'color': Colors.blue,
      },
      {
        'title': 'Billing Reports',
        'count': '36',
        'icon': Icons.receipt_long,
        'color': Colors.green,
      },
      {
        'title': 'Occupancy Reports',
        'count': '28',
        'icon': Icons.hotel,
        'color': Colors.amber,
      },
      {
        'title': 'Medical Reports',
        'count': '54',
        'icon': Icons.medical_services,
        'color': AppConstantColors.ipdAccent,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(
          title: categories[index]['title'] as String,
          count: categories[index]['count'] as String,
          icon: categories[index]['icon'] as IconData,
          color: categories[index]['color'] as Color,
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
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
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count reports',
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(Icons.arrow_forward, color: color, size: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    final RxInt selectedTabIndex = 0.obs;
    final tabs = ['Recent', 'Patients', 'Billing', 'Occupancy', 'Medical'];

    final reports = [
      {
        'id': 'RPT-2024-0145',
        'title': 'Monthly Patient Discharge Summary',
        'date': '12 Apr 2024',
        'type': 'Patients',
        'format': 'PDF',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
        'description':
            'Summary of all patient discharges for April 2024 including length of stay, diagnosis, and treatment outcomes.',
      },
      {
        'id': 'RPT-2024-0144',
        'title': 'Ward Occupancy Analysis',
        'date': '11 Apr 2024',
        'type': 'Occupancy',
        'format': 'Excel',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.table_chart,
        'description':
            'Detailed analysis of bed occupancy rates by ward, department, and time period.',
      },
      {
        'id': 'RPT-2024-0143',
        'title': 'IPD Revenue Breakdown',
        'date': '10 Apr 2024',
        'type': 'Billing',
        'format': 'PDF',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
        'description':
            'Financial analysis of IPD revenue streams by department, procedure type, and insurance category.',
      },
      {
        'id': 'RPT-2024-0142',
        'title': 'Patient Readmission Report',
        'date': '09 Apr 2024',
        'type': 'Patients',
        'format': 'PDF',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
        'description':
            'Analysis of patients readmitted within 30 days, including reasons and preventative measures.',
      },
      {
        'id': 'RPT-2024-0141',
        'title': 'Diagnosis Distribution Analysis',
        'date': '08 Apr 2024',
        'type': 'Medical',
        'format': 'Excel',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.table_chart,
        'description':
            'Statistical breakdown of diagnoses by age, gender, and ward distribution.',
      },
      {
        'id': 'RPT-2024-0140',
        'title': 'Length of Stay Breakdown',
        'date': '07 Apr 2024',
        'type': 'Patients',
        'format': 'PDF',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
        'description':
            'Average length of stay analysis by department, diagnosis, and age group.',
      },
      {
        'id': 'RPT-2024-0139',
        'title': 'Surgical Procedures Report',
        'date': '06 Apr 2024',
        'type': 'Medical',
        'format': 'Excel',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.table_chart,
        'description':
            'Summary of all surgical procedures performed, including outcomes and complications.',
      },
      {
        'id': 'RPT-2024-0138',
        'title': 'Insurance Claims Analysis',
        'date': '05 Apr 2024',
        'type': 'Billing',
        'format': 'PDF',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
        'description':
            'Status of insurance claims, rejection rates, and payment timelines.',
      },
      {
        'id': 'RPT-2024-0137',
        'title': 'Bed Turnover Rate Report',
        'date': '04 Apr 2024',
        'type': 'Occupancy',
        'format': 'Excel',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.table_chart,
        'description':
            'Analysis of bed turnover rates and optimization opportunities.',
      },
      {
        'id': 'RPT-2024-0136',
        'title': 'Critical Care Unit Analysis',
        'date': '03 Apr 2024',
        'type': 'Medical',
        'format': 'PDF',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
        'description':
            'Comprehensive review of ICU and CCU patient outcomes, resource utilization, and mortality rates.',
      },
      {
        'id': 'RPT-2024-0135',
        'title': 'Patient Demographics Analysis',
        'date': '02 Apr 2024',
        'type': 'Patients',
        'format': 'Excel',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.table_chart,
        'description':
            'Demographic breakdown of inpatient admissions by age, gender, location, and socioeconomic status.',
      },
      {
        'id': 'RPT-2024-0134',
        'title': 'Outstanding Payments Report',
        'date': '01 Apr 2024',
        'type': 'Billing',
        'format': 'PDF',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
        'description':
            'Status of all outstanding patient payments and collection efforts.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              return Obx(
                () => GestureDetector(
                  onTap: () {
                    selectedTabIndex.value = index;
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selectedTabIndex.value == index
                          ? AppConstantColors.ipdAccent
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedTabIndex.value == index
                            ? AppConstantColors.ipdAccent
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selectedTabIndex.value == index
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Available Reports',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppConstantColors.ipdAccent,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          var filteredReports = reports;
          if (selectedTabIndex.value > 0) {
            final selectedType = tabs[selectedTabIndex.value];
            filteredReports = reports
                .where((report) => report['type'] == selectedType)
                .toList();
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredReports.length,
            itemBuilder: (context, index) {
              final report = filteredReports[index];
              return _buildReportItem(
                id: report['id'] as String,
                title: report['title'] as String,
                date: report['date'] as String,
                type: report['type'] as String,
                format: report['format'] as String,
                status: report['status'] as String,
                statusColor: report['statusColor'] as Color,
                icon: report['icon'] as IconData,
                description: report['description'] as String,
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildReportItem({
    required String id,
    required String title,
    required String date,
    required String type,
    required String format,
    required String status,
    required Color statusColor,
    required IconData icon,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppConstantColors.ipdAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppConstantColors.ipdAccent, size: 16),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              'ID: $id • $date',
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTypeColor(type),
                      fontWeight: FontWeight.w500,
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
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    format,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[800], fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.remove_red_eye, size: 14),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstantColors.ipdAccent,
                        side: const BorderSide(
                            color: AppConstantColors.ipdAccent),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 14),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstantColors.ipdAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Patients':
        return Colors.blue;
      case 'Billing':
        return Colors.green;
      case 'Occupancy':
        return Colors.amber;
      case 'Medical':
        return AppConstantColors.ipdAccent;
      default:
        return Colors.grey;
    }
  }
}
