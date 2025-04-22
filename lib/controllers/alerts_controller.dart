import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertsController extends GetxController {
  // Add any alerts specific state and methods here
  final RxInt criticalAlerts = 5.obs;
  final RxInt warningAlerts = 8.obs;
  final RxInt infoAlerts = 12.obs;

  final RxList<Map<String, dynamic>> recentAlerts =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with sample data
    recentAlerts.value = [
      {
        'type': 'Critical',
        'message': 'Low medication stock: Amoxicillin',
        'timeAgo': '10 minutes ago',
        'color': Colors.red,
      },
      // Add more sample alerts as needed
    ];
  }

  void markAllAsRead() {
    // Implement mark all as read logic here
  }

  void clearAlert(String alertId) {
    // Implement clear alert logic here
  }
}
