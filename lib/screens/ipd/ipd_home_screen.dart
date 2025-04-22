import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class IpdHomeScreen extends StatelessWidget {
  const IpdHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.ipdBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 20),
                _buildStatisticsSection(),
                const SizedBox(height: 20),
                _buildCurrentPatientsSection(),
                const SizedBox(height: 20),
                _buildBedsOccupancySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IPD Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstantColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildTimePeriodSelector(), _buildDateDisplay()],
        ),
      ],
    );
  }

  Widget _buildTimePeriodSelector() {
    final List<String> timePeriods = [
      'Today',
      'This Week',
      'This Month',
      'This Year',
    ];
    final selectedPeriod = 'This Week'.obs;

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppConstantColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppConstantColors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: selectedPeriod.value,
          icon: const Icon(Icons.arrow_drop_down,
              color: AppConstantColors.ipdAccent),
          underline: const SizedBox(),
          isDense: true,
          style: const TextStyle(
            color: AppConstantColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: timePeriods
              .map(
                (String period) => DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                ),
              )
              .toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              selectedPeriod.value = newValue;
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
      style: const TextStyle(
        color: AppConstantColors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstantColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstantColors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Admissions', '42', AppConstantColors.info),
              _buildStatItem('Discharges', '38', AppConstantColors.success),
              _buildStatItem('Bed Capacity', '85%', AppConstantColors.warning),
              _buildStatItem(
                'Revenue',
                'NPR 1.2M',
                AppConstantColors.accountsAccent,
              ),
            ],
          ),
        ],
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
            title == 'Admissions'
                ? Icons.assignment_ind
                : title == 'Discharges'
                    ? Icons.exit_to_app
                    : title == 'Bed Capacity'
                        ? Icons.hotel
                        : Icons.attach_money,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppConstantColors.grey),
        ),
      ],
    );
  }

  Widget _buildCurrentPatientsSection() {
    final currentPatients = [
      {
        'id': 'IPD-2024-001',
        'name': 'Ram Kumar',
        'age': '48 years',
        'diagnosis': 'Pneumonia',
        'room': '204',
        'admission': '01 Apr 2024',
        'doctor': 'Dr. Sharma',
        'condition': 'Stable',
        'conditionColor': AppConstantColors.success,
      },
      {
        'id': 'IPD-2024-002',
        'name': 'Sita Sharma',
        'age': '65 years',
        'diagnosis': 'Heart Failure',
        'room': '302',
        'admission': '28 Mar 2024',
        'doctor': 'Dr. Thapa',
        'condition': 'Critical',
        'conditionColor': AppConstantColors.error,
      },
      {
        'id': 'IPD-2024-003',
        'name': 'Hari Thapa',
        'age': '34 years',
        'diagnosis': 'Appendicitis',
        'room': '105',
        'admission': '02 Apr 2024',
        'doctor': 'Dr. Gurung',
        'condition': 'Recovering',
        'conditionColor': AppConstantColors.info,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstantColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstantColors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Patients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstantColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all patients screen
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppConstantColors.ipdAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...currentPatients.map((patient) => _buildPatientItem(patient)),
        ],
      ),
    );
  }

  Widget _buildPatientItem(Map<String, dynamic> patient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppConstantColors.greyLight, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppConstantColors.ipdAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                patient['name'].substring(0, 1),
                style: const TextStyle(
                  color: AppConstantColors.ipdAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      patient['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (patient['conditionColor'] as Color).withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        patient['condition'],
                        style: TextStyle(
                          color: patient['conditionColor'] as Color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient['age']} | ID: ${patient['id']}',
                  style: const TextStyle(
                    color: AppConstantColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Diagnosis: ${patient['diagnosis']}',
                  style: const TextStyle(
                    color: AppConstantColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Room: ${patient['room']}',
                      style: const TextStyle(
                        color: AppConstantColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Text(' | '),
                    Text(
                      'Doctor: ${patient['doctor']}',
                      style: const TextStyle(
                        color: AppConstantColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Admitted on: ${patient['admission']}',
                  style: const TextStyle(
                    color: AppConstantColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedsOccupancySection() {
    final departments = [
      {
        'name': 'General Ward',
        'total': 40,
        'occupied': 32,
        'available': 8,
        'color': AppConstantColors.info,
      },
      {
        'name': 'ICU',
        'total': 12,
        'occupied': 10,
        'available': 2,
        'color': AppConstantColors.ipdAccent,
      },
      {
        'name': 'Pediatric',
        'total': 20,
        'occupied': 15,
        'available': 5,
        'color': AppConstantColors.success,
      },
      {
        'name': 'Maternity',
        'total': 15,
        'occupied': 12,
        'available': 3,
        'color': AppConstantColors.accountsAccent,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstantColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstantColors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bed Occupancy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...departments.map((dept) => _buildDepartmentItem(dept)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // View bed allocation details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstantColors.ipdAccent,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Bed Allocation Map',
              style: TextStyle(
                color: AppConstantColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentItem(Map<String, dynamic> dept) {
    final double occupancyRate =
        (dept['occupied'] as int) / (dept['total'] as int);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppConstantColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dept['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${dept['occupied']}/${dept['total']} beds',
                style: TextStyle(
                  color: (dept['color'] as Color),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppConstantColors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: occupancyRate,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: dept['color'] as Color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${dept['available']} available',
                style: const TextStyle(
                    color: AppConstantColors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
