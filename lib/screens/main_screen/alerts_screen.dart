import 'package:flutter/material.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EBF6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 8, 3, 3),
                ),
              ),
              const SizedBox(height: 20),
              _buildAlertStats(),
              const SizedBox(height: 20),
              _buildAlertsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertStats() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '5',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Critical', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notification_important,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '8',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Warnings', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info, color: Colors.blue, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '12',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Info', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstantColors.secondaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Mark All as Read'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _alertItem(
              'Critical',
              'Low medication stock: Amoxicillin',
              '10 minutes ago',
              Colors.red,
            ),
            _alertItem(
              'Warning',
              'Patient John Doe missed appointment',
              '1 hour ago',
              Colors.orange,
            ),
            _alertItem(
              'Info',
              'Dr. Smith added a new test result',
              '3 hours ago',
              Colors.blue,
            ),
            _alertItem(
              'Warning',
              'System backup required',
              '5 hours ago',
              Colors.orange,
            ),
            _alertItem(
              'Critical',
              'Lab equipment maintenance required',
              '8 hours ago',
              Colors.red,
            ),
            _alertItem(
              'Info',
              'New staff training scheduled',
              '1 day ago',
              Colors.blue,
            ),
            _alertItem(
              'Warning',
              'Monthly report deadline approaching',
              '1 day ago',
              Colors.orange,
            ),
            _alertItem(
              'Info',
              'System update available',
              '2 days ago',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertItem(
    String type,
    String message,
    String timeAgo,
    Color typeColor,
  ) {
    IconData icon;
    if (type == 'Critical') {
      icon = Icons.warning;
    } else if (type == 'Warning') {
      icon = Icons.notification_important;
    } else {
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: typeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
                Text(message, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
