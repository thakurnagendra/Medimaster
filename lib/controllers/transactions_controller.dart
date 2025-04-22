import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TransactionsController extends GetxController {
  // Add any transactions specific state and methods here
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with sample data
    transactions.value = [
      {
        'id': 'TRX-2024-001',
        'patientName': 'Ram Kumar',
        'amount': 2500.0,
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      // Add more sample transactions as needed
    ];
  }

  void filterTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? minAmount,
    double? maxAmount,
  }) {
    // Implement filtering logic here
  }
}
