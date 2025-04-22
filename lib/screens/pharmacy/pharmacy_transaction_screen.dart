import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/main_controller.dart';

class PharmacyTransactionScreen extends StatelessWidget {
  // Added moduleType property to clearly associate this screen with its module
  final String moduleType = 'pharmacy';

  const PharmacyTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get reference to the main controller to access module state if needed
    final MainController mainController = Get.find<MainController>();

    // Verify current module is correct
    if (mainController.currentModule.value != moduleType) {
      // This is a safety check - if we somehow got here with wrong module, log it
      debugPrint(
        'Warning: Displaying PharmacyTransactionScreen while in ${mainController.currentModule.value} module',
      );
    }

    // Remove the Scaffold and SafeArea since this screen
    // is already inside a Scaffold in MainScreen
    return Container(
      color: const Color(0xFFE8F5E9), // Light green background for pharmacy
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          // We need to use Flexible instead of Expanded to avoid constraints issues
          Flexible(fit: FlexFit.tight, child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pharmacy Transactions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage and track all pharmacy sales and orders',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search orders or patients',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey[400]),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Add new order
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final RxString selectedTab = 'All'.obs;
    final List<String> tabs = ['All', 'Completed', 'Processing', 'Cancelled'];

    // Sample transactions data
    final List<Map<String, dynamic>> transactions = [
      {
        'id': 'ORD-2024-001',
        'patientName': 'Ram Kumar',
        'items': '3 items',
        'amount': 'NPR 1,200',
        'date': '04 Apr 2024',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': 'ORD-2024-002',
        'patientName': 'Sita Sharma',
        'items': '2 items',
        'amount': 'NPR 850',
        'date': '03 Apr 2024',
        'status': 'Processing',
        'statusColor': Colors.orange,
      },
      {
        'id': 'ORD-2024-003',
        'patientName': 'Hari Thapa',
        'items': '5 items',
        'amount': 'NPR 2,300',
        'date': '03 Apr 2024',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': 'ORD-2024-004',
        'patientName': 'Gita Gurung',
        'items': '1 item',
        'amount': 'NPR 450',
        'date': '02 Apr 2024',
        'status': 'Cancelled',
        'statusColor': Colors.red,
      },
      {
        'id': 'ORD-2024-005',
        'patientName': 'Bishnu Rai',
        'items': '4 items',
        'amount': 'NPR 1,800',
        'date': '01 Apr 2024',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
    ];

    return Column(
      children: [
        // Tab filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(
            () => Row(
              children: tabs
                  .map(
                    (tab) => Expanded(
                      child: GestureDetector(
                        onTap: () => selectedTab.value = tab,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedTab.value == tab
                                ? Colors.green.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tab,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedTab.value == tab
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: selectedTab.value == tab
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Transactions list
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                // Header row
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Patient / Order',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // List of transactions
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionItem(transaction);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['patientName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${transaction['items']} | ${transaction['id']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        transaction['date'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Amount column
          Expanded(
            flex: 1,
            child: Text(
              transaction['amount'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Status column
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (transaction['statusColor'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                transaction['status'],
                style: TextStyle(
                  color: transaction['statusColor'] as Color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
