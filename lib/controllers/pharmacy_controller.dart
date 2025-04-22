import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PharmacyController extends GetxController {
  // Selected time period
  final RxString selectedTimePeriod = 'This Week'.obs;

  // List of available time periods
  final List<String> timePeriods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
  ];

  // Pharmacy statistics
  final RxString totalSales = '₹38,450'.obs;
  final RxString totalPrescriptions = '175'.obs;
  final RxString pendingOrders = '24'.obs;
  final RxString lowStockItems = '12'.obs;

  // Inventory statistics
  final RxString totalInventoryValue = '₹2,45,836'.obs;
  final RxString expiringItems = '8'.obs;

  // Top selling categories
  final RxList<Map<String, dynamic>> topSellingCategories =
      <Map<String, dynamic>>[
        {'name': 'Antibiotics', 'percentage': 32, 'value': '₹12,304'},
        {'name': 'Painkillers', 'percentage': 24, 'value': '₹9,228'},
        {'name': 'Vitamins', 'percentage': 18, 'value': '₹6,921'},
        {'name': 'Others', 'percentage': 26, 'value': '₹9,997'},
      ].obs;

  // Recent orders
  final RxList<Map<String, dynamic>> recentOrders =
      <Map<String, dynamic>>[].obs;

  // GetStorage instance for persistent storage
  final GetStorage storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Load saved data or initialize with mock data
    _loadMockData();
  }

  // Change the selected time period
  void changeTimePeriod(String period) {
    selectedTimePeriod.value = period;
    // In a real app, we would reload data for the selected period
    _loadDataForPeriod(period);
  }

  // Private method to load mock data
  void _loadMockData() {
    // Mock recent orders
    recentOrders.value = List.generate(
      5,
      (index) => {
        'id': 'ORD-${10032 + index}',
        'patientName': 'Patient ${index + 1}',
        'amount': '₹${(index + 1) * 300}.00',
        'items': '${3 + index} items',
        'date':
            DateTime.now()
                .subtract(Duration(days: index))
                .toString()
                .split(' ')[0],
        'status': index % 3 == 0 ? 'Pending' : 'Completed',
      },
    );
  }

  // Load data based on selected time period
  void _loadDataForPeriod(String period) {
    // In a real app, this would be an API call or database query
    // Here we just simulate different data for different periods
    switch (period) {
      case 'Today':
        totalSales.value = '₹4,520';
        totalPrescriptions.value = '23';
        pendingOrders.value = '8';
        lowStockItems.value = '12';
        totalInventoryValue.value = '₹2,45,836';
        expiringItems.value = '8';
        break;

      case 'This Week':
        totalSales.value = '₹38,450';
        totalPrescriptions.value = '175';
        pendingOrders.value = '24';
        lowStockItems.value = '12';
        totalInventoryValue.value = '₹2,45,836';
        expiringItems.value = '8';
        break;

      case 'This Month':
        totalSales.value = '₹1,54,380';
        totalPrescriptions.value = '723';
        pendingOrders.value = '36';
        lowStockItems.value = '12';
        totalInventoryValue.value = '₹2,45,836';
        expiringItems.value = '8';
        break;

      case 'This Year':
        totalSales.value = '₹18,52,730';
        totalPrescriptions.value = '8,651';
        pendingOrders.value = '36';
        lowStockItems.value = '12';
        totalInventoryValue.value = '₹2,45,836';
        expiringItems.value = '8';
        break;
    }

    // Update top selling categories based on time period
    if (period == 'This Month' || period == 'This Year') {
      topSellingCategories.value = [
        {
          'name': 'Antibiotics',
          'percentage': 28,
          'value': '₹${period == 'This Month' ? '43,226' : '5,18,764'}',
        },
        {
          'name': 'Painkillers',
          'percentage': 26,
          'value': '₹${period == 'This Month' ? '40,138' : '4,81,709'}',
        },
        {
          'name': 'Vitamins',
          'percentage': 22,
          'value': '₹${period == 'This Month' ? '33,963' : '4,07,600'}',
        },
        {
          'name': 'Others',
          'percentage': 24,
          'value': '₹${period == 'This Month' ? '37,051' : '4,44,655'}',
        },
      ];
    } else {
      topSellingCategories.value = [
        {
          'name': 'Antibiotics',
          'percentage': 32,
          'value': '₹${period == 'Today' ? '1,446' : '12,304'}',
        },
        {
          'name': 'Painkillers',
          'percentage': 24,
          'value': '₹${period == 'Today' ? '1,084' : '9,228'}',
        },
        {
          'name': 'Vitamins',
          'percentage': 18,
          'value': '₹${period == 'Today' ? '813' : '6,921'}',
        },
        {
          'name': 'Others',
          'percentage': 26,
          'value': '₹${period == 'Today' ? '1,175' : '9,997'}',
        },
      ];
    }
  }
}
