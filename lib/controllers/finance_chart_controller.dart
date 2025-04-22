import 'package:get/get.dart';

class FinanceChartController extends GetxController {
  // Time frames for chart display
  final List<String> timeFrames = ['Day', 'Week', 'Month', 'Year'];
  final RxString selectedTimeFrame = 'Month'.obs;

  // Financial values
  final RxDouble totalNet = 125000.0.obs;
  final RxDouble totalReceipt = 150000.0.obs;
  final RxDouble difference = 25000.0.obs;

  // Chart data
  final RxList<double> chartData = <double>[].obs;
  final RxList<String> chartLabels = <String>[].obs;

  // Additional properties
  final RxList<double> netAmounts = <double>[].obs;
  final RxList<double> receiptAmounts = <double>[].obs;
  final RxList<String> timeLabels = <String>[].obs;

  // Performance metrics
  final RxDouble collectionRateValue = 75.0.obs;
  final RxDouble pendingRateValue = 25.0.obs;
  final RxString collectionRate = '75%'.obs;
  final RxString pendingRate = '25%'.obs;

  @override
  void onInit() {
    super.onInit();
    loadChartData();
  }

  // Change time frame and reload data
  void changeTimeFrame(String timeFrame) {
    selectedTimeFrame.value = timeFrame;
    loadChartData();

    // Update financial values based on timeframe
    switch (timeFrame) {
      case 'Day':
        totalNet.value = 12500.0;
        totalReceipt.value = 15000.0;
        break;
      case 'Week':
        totalNet.value = 45000.0;
        totalReceipt.value = 52000.0;
        break;
      case 'Month':
        totalNet.value = 125000.0;
        totalReceipt.value = 150000.0;
        break;
      case 'Year':
        totalNet.value = 1250000.0;
        totalReceipt.value = 1500000.0;
        break;
    }

    // Calculate difference
    difference.value = totalReceipt.value - totalNet.value;

    // Update rates
    collectionRateValue.value = (totalReceipt.value / totalNet.value) * 100;
    pendingRateValue.value = 100 - collectionRateValue.value;

    // Update rate strings
    collectionRate.value = '${collectionRateValue.value.toStringAsFixed(0)}%';
    pendingRate.value = '${pendingRateValue.value.toStringAsFixed(0)}%';
  }

  // Load chart data based on selected time frame
  void loadChartData() {
    chartData.clear();
    chartLabels.clear();
    netAmounts.clear();
    receiptAmounts.clear();
    timeLabels.clear();

    switch (selectedTimeFrame.value) {
      case 'Day':
        timeLabels.value = ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
        chartLabels.value = timeLabels.value;
        netAmounts.value = [2500.0, 3800.0, 5200.0, 4100.0, 6500.0, 4900.0];
        receiptAmounts.value = [2300.0, 3600.0, 5000.0, 3900.0, 6200.0, 4500.0];
        chartData.value = netAmounts.value;
        break;
      case 'Week':
        timeLabels.value = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        chartLabels.value = timeLabels.value;
        netAmounts.value = [
          8500.0,
          7200.0,
          9800.0,
          6400.0,
          8900.0,
          5200.0,
          6000.0,
        ];
        receiptAmounts.value = [
          8000.0,
          6800.0,
          9500.0,
          6100.0,
          8500.0,
          4800.0,
          5500.0,
        ];
        chartData.value = netAmounts.value;
        break;
      case 'Month':
        timeLabels.value = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        chartLabels.value = timeLabels.value;
        netAmounts.value = [28500.0, 35200.0, 42800.0, 43500.0];
        receiptAmounts.value = [26000.0, 32500.0, 40000.0, 42500.0];
        chartData.value = netAmounts.value;
        break;
      case 'Year':
        timeLabels.value = [
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
        chartLabels.value = timeLabels.value;
        netAmounts.value = [
          95000.0,
          102000.0,
          115000.0,
          98000.0,
          125000.0,
          130000.0,
          142000.0,
          135000.0,
          148000.0,
          152000.0,
          138000.0,
          160000.0,
        ];
        receiptAmounts.value = [
          90000.0,
          98000.0,
          110000.0,
          94000.0,
          120000.0,
          126000.0,
          138000.0,
          130000.0,
          144000.0,
          148000.0,
          134000.0,
          155000.0,
        ];
        chartData.value = netAmounts.value;
        break;
    }
  }

  // Format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}
