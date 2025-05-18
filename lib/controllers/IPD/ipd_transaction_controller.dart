import 'package:get/get.dart';

class IpdTransactionController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTransactions();
  }

  void _loadTransactions() {
    // TODO: Replace with actual API call
    transactions.value = [
      {
        'id': 'TRX-1001',
        'patient': 'Ram Kumar',
        'patientId': 'IPD-2024-001',
        'type': 'Admission',
        'description': 'Initial admission fees',
        'amount': 'NPR 5,000',
        'date': '01 Apr 2024',
        'status': 'Paid',
        'statusColor': 'green',
        'icon': 'assignment_ind',
      },
      {
        'id': 'TRX-1002',
        'patient': 'Ram Kumar',
        'patientId': 'IPD-2024-001',
        'type': 'Room',
        'description': 'Room charges (3 days)',
        'amount': 'NPR 9,000',
        'date': '04 Apr 2024',
        'status': 'Unpaid',
        'statusColor': 'red',
        'icon': 'hotel',
      },
      {
        'id': 'TRX-1003',
        'patient': 'Sita Sharma',
        'patientId': 'IPD-2024-002',
        'type': 'Medication',
        'description': 'Prescribed medications',
        'amount': 'NPR 3,200',
        'date': '30 Mar 2024',
        'status': 'Paid',
        'statusColor': 'green',
        'icon': 'medication',
      },
    ];
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Map<String, dynamic>> get filteredTransactions {
    if (selectedTabIndex.value == 0) {
      return transactions;
    }
    return transactions
        .where((t) => t['type'] == _getTabType(selectedTabIndex.value))
        .toList();
  }

  String _getTabType(int index) {
    switch (index) {
      case 1:
        return 'Admission';
      case 2:
        return 'Room';
      case 3:
        return 'Medication';
      case 4:
        return 'Services';
      case 5:
        return 'Payment';
      default:
        return '';
    }
  }
}
