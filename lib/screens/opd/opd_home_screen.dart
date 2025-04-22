import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class OpdHomeScreen extends StatelessWidget {
  const OpdHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.opdBackground,
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
                _buildRecentPatientsSection(),
                const SizedBox(height: 20),
                _buildAppointmentsSection(),
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
          'OPD Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: selectedPeriod.value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
          underline: const SizedBox(),
          isDense: true,
          style: const TextStyle(
            color: Colors.black87,
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
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Patients', '128', Colors.blue),
              _buildStatItem('Consultations', '112', Colors.orange),
              _buildStatItem('Revenue', 'NPR 84,520', Colors.green),
              _buildStatItem('Today', '23', Colors.purple),
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
            title == 'Patients'
                ? Icons.people
                : title == 'Consultations'
                    ? Icons.medical_services
                    : title == 'Revenue'
                        ? Icons.attach_money
                        : Icons.today,
            color: color,
            size: 20,
          ),
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

  Widget _buildRecentPatientsSection() {
    final recentPatients = [
      {
        'id': 'OPD-2024-001',
        'name': 'Ram Kumar',
        'age': '32 years',
        'phone': '+977 9801234567',
        'visitDate': '04 Apr 2024',
        'doctor': 'Dr. Sharma',
      },
      {
        'id': 'OPD-2024-002',
        'name': 'Sita Sharma',
        'age': '28 years',
        'phone': '+977 9812345678',
        'visitDate': '03 Apr 2024',
        'doctor': 'Dr. Thapa',
      },
      {
        'id': 'OPD-2024-003',
        'name': 'Hari Thapa',
        'age': '45 years',
        'phone': '+977 9823456789',
        'visitDate': '03 Apr 2024',
        'doctor': 'Dr. Sharma',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                'Recent Patients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all patients screen
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentPatients.map((patient) => _buildPatientItem(patient)),
        ],
      ),
    );
  }

  Widget _buildPatientItem(Map<String, dynamic> patient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                patient['name'].substring(0, 1),
                style: const TextStyle(
                  color: Colors.orange,
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
                Text(
                  patient['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${patient['age']} | ID: ${patient['id']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Doctor: ${patient['doctor']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                patient['visitDate'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, color: Colors.blue, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Call',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    final upcomingAppointments = [
      {
        'id': 'APT-2024-001',
        'patientName': 'Gita Gurung',
        'time': '10:30 AM',
        'date': '05 Apr 2024',
        'doctor': 'Dr. Sharma',
        'purpose': 'Follow-up',
      },
      {
        'id': 'APT-2024-002',
        'patientName': 'Bishnu Rai',
        'time': '11:45 AM',
        'date': '05 Apr 2024',
        'doctor': 'Dr. Thapa',
        'purpose': 'Consultation',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all appointments screen
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...upcomingAppointments.map(
            (appointment) => _buildAppointmentItem(appointment),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Add new appointment
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Schedule New Appointment',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appointment['time'],
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['patientName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${appointment['purpose']} | ${appointment['date']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Doctor: ${appointment['doctor']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 20,
                ),
                onPressed: () {
                  // Confirm appointment
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () {
                  // Cancel appointment
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
