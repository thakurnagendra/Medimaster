import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BillingController extends GetxController {
  // Selected time period
  final RxString selectedTimePeriod = 'This Week'.obs;

  // List of available time periods
  final List<String> timePeriods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
  ];

  // Billing statistics
  final RxString totalBilling = '₹45,642'.obs;
  final RxString totalReceipt = '₹42,180'.obs;
  final RxString pendingAmount = '₹3,462'.obs;
  final RxString todayCollection = '₹5,842'.obs;

  // Payment methods
  final RxString cashPayment = '₹18,250'.obs;
  final RxString upiPayment = '₹15,430'.obs;
  final RxString cardPayment = '₹8,500'.obs;

  // Summary statistics
  final RxString totalPatients = '256'.obs;
  final RxString totalTests = '324'.obs;
  final RxString pendingReports = '12'.obs;

  // Recent transactions
  final RxList<Map<String, dynamic>> recentTransactions =
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
    // Mock recent transactions
    recentTransactions.value = List.generate(
      5,
      (index) => {
        'id': 'INV-${10032 + index}',
        'patientName': 'Patient ${index + 1}',
        'amount': '₹${(index + 1) * 500}.00',
        'date':
            DateTime.now()
                .subtract(Duration(days: index))
                .toString()
                .split(' ')[0],
        'status': index % 3 == 0 ? 'Pending' : 'Paid',
      },
    );
  }

  // Load data based on selected time period
  void _loadDataForPeriod(String period) {
    // In a real app, this would be an API call or database query
    // Here we just simulate different data for different periods
    switch (period) {
      case 'Today':
        totalBilling.value = '₹5,842';
        totalReceipt.value = '₹4,920';
        pendingAmount.value = '₹922';
        todayCollection.value = '₹5,842';
        cashPayment.value = '₹2,250';
        upiPayment.value = '₹1,670';
        cardPayment.value = '₹1,000';
        totalPatients.value = '24';
        totalTests.value = '31';
        pendingReports.value = '7';
        break;

      case 'This Week':
        totalBilling.value = '₹45,642';
        totalReceipt.value = '₹42,180';
        pendingAmount.value = '₹3,462';
        todayCollection.value = '₹5,842';
        cashPayment.value = '₹18,250';
        upiPayment.value = '₹15,430';
        cardPayment.value = '₹8,500';
        totalPatients.value = '256';
        totalTests.value = '324';
        pendingReports.value = '12';
        break;

      case 'This Month':
        totalBilling.value = '₹1,85,642';
        totalReceipt.value = '₹1,68,180';
        pendingAmount.value = '₹17,462';
        todayCollection.value = '₹5,842';
        cashPayment.value = '₹72,250';
        upiPayment.value = '₹64,430';
        cardPayment.value = '₹31,500';
        totalPatients.value = '932';
        totalTests.value = '1,245';
        pendingReports.value = '38';
        break;

      case 'This Year':
        totalBilling.value = '₹24,65,642';
        totalReceipt.value = '₹22,98,180';
        pendingAmount.value = '₹1,67,462';
        todayCollection.value = '₹5,842';
        cashPayment.value = '₹10,22,250';
        upiPayment.value = '₹8,54,430';
        cardPayment.value = '₹4,21,500';
        totalPatients.value = '11,256';
        totalTests.value = '14,324';
        pendingReports.value = '132';
        break;
    }
  }
}
