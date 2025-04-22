import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BillingChartController extends GetxController {
  // Statistics data
  final RxString totalBilling = '₹67,054'.obs;
  final RxString totalReceipt = '₹62,416'.obs;
  final RxString pendingAmount = '₹4,638'.obs;
  final RxString todayCollection = '₹12,500'.obs;

  // Payment method breakdown
  final RxString cashPayment = '₹45,000'.obs;
  final RxString upiPayment = '₹12,500'.obs;
  final RxString cardPayment = '₹4,916'.obs;

  // Summary data
  final RxString totalPatients = '156'.obs;
  final RxString totalTests = '234'.obs;
  final RxString pendingReports = '12'.obs;

  // Time period selection
  final List<String> timePeriods = ['Today', 'Week', 'Month', 'Year'];
  final RxString selectedTimePeriod = 'Month'.obs;

  // Chart data
  final RxList<double> billingData = <double>[].obs;
  final RxList<double> receiptData = <double>[].obs;
  final RxList<String> chartLabels = <String>[].obs;

  // Transaction data
  final RxList<Map<String, dynamic>> recentTransactions =
      <Map<String, dynamic>>[
        {
          'id': 'TRX-001',
          'patient': 'John Doe',
          'amount': '₹1,500',
          'date': '10 Mar 2023',
          'status': 'Completed',
        },
        {
          'id': 'TRX-002',
          'patient': 'Jane Smith',
          'amount': '₹2,300',
          'date': '09 Mar 2023',
          'status': 'Pending',
        },
        {
          'id': 'TRX-003',
          'patient': 'Mike Johnson',
          'amount': '₹950',
          'date': '08 Mar 2023',
          'status': 'Completed',
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
    loadChartData();
  }

  // Change time period and reload data
  void changeTimePeriod(String period) {
    selectedTimePeriod.value = period;
    loadChartData();

    // Update stats based on selected period
    switch (period) {
      case 'Today':
        totalBilling.value = '₹12,500';
        totalReceipt.value = '₹10,200';
        pendingAmount.value = '₹2,300';
        todayCollection.value = '₹10,200';
        break;
      case 'Week':
        totalBilling.value = '₹32,450';
        totalReceipt.value = '₹28,900';
        pendingAmount.value = '₹3,550';
        todayCollection.value = '₹12,500';
        break;
      case 'Month':
        totalBilling.value = '₹67,054';
        totalReceipt.value = '₹62,416';
        pendingAmount.value = '₹4,638';
        todayCollection.value = '₹12,500';
        break;
      case 'Year':
        totalBilling.value = '₹780,250';
        totalReceipt.value = '₹753,800';
        pendingAmount.value = '₹26,450';
        todayCollection.value = '₹12,500';
        break;
    }
  }

  // Load chart data based on selected time period
  void loadChartData() {
    billingData.clear();
    receiptData.clear();
    chartLabels.clear();

    switch (selectedTimePeriod.value) {
      case 'Today':
        chartLabels.value = ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
        billingData.value = [1800.0, 2500.0, 3200.0, 1500.0, 2100.0, 1400.0];
        receiptData.value = [1600.0, 2300.0, 2900.0, 1200.0, 1600.0, 600.0];
        break;
      case 'Week':
        chartLabels.value = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        billingData.value = [
          4500.0,
          5200.0,
          6100.0,
          4900.0,
          5600.0,
          3200.0,
          2950.0,
        ];
        receiptData.value = [
          4200.0,
          4800.0,
          5600.0,
          4500.0,
          5100.0,
          2800.0,
          1900.0,
        ];
        break;
      case 'Month':
        chartLabels.value = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        billingData.value = [16500.0, 18200.0, 15400.0, 16954.0];
        receiptData.value = [15800.0, 17200.0, 14500.0, 14916.0];
        break;
      case 'Year':
        chartLabels.value = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        billingData.value = [
          62000.0,
          58500.0,
          65400.0,
          61200.0,
          69800.0,
          63500.0,
          67200.0,
          64800.0,
          70500.0,
          67054.0,
          65300.0,
          64500.0,
        ];
        receiptData.value = [
          60200.0,
          56800.0,
          63500.0,
          59400.0,
          67200.0,
          61800.0,
          65400.0,
          62600.0,
          68200.0,
          62416.0,
          62500.0,
          62800.0,
        ];
        break;
    }
  }

  // Method to fetch data from API or database
  void fetchDashboardData() {
    // In a real app, this would make API calls or DB queries
    // For this example, we're using the hardcoded values above
  }

  // Get status color based on status text
  Color getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
