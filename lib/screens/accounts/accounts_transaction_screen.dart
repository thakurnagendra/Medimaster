import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/screens/accounts/agent_wise_summary_screen.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class AccountsTransactionScreen extends StatelessWidget {
  const AccountsTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTabIndex = 0.obs;
    final dateRange = 'April 01 - April 30, 2024'.obs;

    return Scaffold(
      backgroundColor: const Color(
        0xFFE3F2FD,
      ), // Light blue background for Accounts
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildAgentWiseSummaryButton(),
              const SizedBox(height: 20),
              _buildSearchAndFilter(dateRange),
              const SizedBox(height: 20),
              _buildTransactionList(selectedTabIndex),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new transaction
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Transactions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage all financial transactions across departments',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(RxString dateRange) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search transactions',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () {
              // Show filter options
            },
            icon: const Icon(Icons.filter_list, color: Colors.blue),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            // Show date picker
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    dateRange.value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(RxInt selectedTabIndex) {
    final tabs = ['All', 'Revenue', 'Expense', 'Payable', 'Receivable'];

    final transactions = [
      {
        'id': 'TRX-5001',
        'department': 'OPD',
        'type': 'Revenue',
        'description': 'Consultation Fees',
        'amount': 'NPR 35,000',
        'date': '05 Apr 2024',
        'paymentMethod': 'Cash',
        'status': 'Completed',
        'statusColor': Colors.green,
        'icon': Icons.arrow_downward,
        'iconColor': Colors.green,
      },
      {
        'id': 'TRX-5002',
        'department': 'Admin',
        'type': 'Expense',
        'description': 'Staff Salaries',
        'amount': 'NPR 120,000',
        'date': '04 Apr 2024',
        'paymentMethod': 'Bank Transfer',
        'status': 'Completed',
        'statusColor': Colors.green,
        'icon': Icons.arrow_upward,
        'iconColor': Colors.red,
      },
      {
        'id': 'TRX-5003',
        'department': 'Pharmacy',
        'type': 'Expense',
        'description': 'Medication Purchase',
        'amount': 'NPR 45,000',
        'date': '03 Apr 2024',
        'paymentMethod': 'Bank Transfer',
        'status': 'Completed',
        'statusColor': Colors.green,
        'icon': Icons.arrow_upward,
        'iconColor': Colors.red,
      },
      {
        'id': 'TRX-5004',
        'department': 'IPD',
        'type': 'Revenue',
        'description': 'Patient Billing',
        'amount': 'NPR 78,000',
        'date': '02 Apr 2024',
        'paymentMethod': 'Card',
        'status': 'Completed',
        'statusColor': Colors.green,
        'icon': Icons.arrow_downward,
        'iconColor': Colors.green,
      },
      {
        'id': 'TRX-5005',
        'department': 'Laboratory',
        'type': 'Revenue',
        'description': 'Test Services',
        'amount': 'NPR 25,000',
        'date': '01 Apr 2024',
        'paymentMethod': 'Cash',
        'status': 'Completed',
        'statusColor': Colors.green,
        'icon': Icons.arrow_downward,
        'iconColor': Colors.green,
      },
      {
        'id': 'TRX-5006',
        'department': 'Radiology',
        'type': 'Receivable',
        'description': 'Pending Insurance Payment',
        'amount': 'NPR 18,000',
        'date': '05 Apr 2024',
        'paymentMethod': 'Insurance',
        'status': 'Pending',
        'statusColor': Colors.orange,
        'icon': Icons.schedule,
        'iconColor': Colors.orange,
      },
      {
        'id': 'TRX-5007',
        'department': 'Pharmacy',
        'type': 'Payable',
        'description': 'Medicine Supplier Invoice',
        'amount': 'NPR 65,000',
        'date': '03 Apr 2024',
        'paymentMethod': 'Credit',
        'status': 'Due',
        'statusColor': Colors.red,
        'icon': Icons.schedule,
        'iconColor': Colors.purple,
      },
    ];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    selectedTabIndex.value = index;
                  },
                  child: Obx(
                    () => Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: selectedTabIndex.value == index
                            ? Colors.blue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selectedTabIndex.value == index
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: selectedTabIndex.value == index
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
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
                      Obx(() {
                        final filteredTransactions = selectedTabIndex.value == 0
                            ? transactions
                            : transactions
                                .where(
                                  (t) =>
                                      t['type'] == tabs[selectedTabIndex.value],
                                )
                                .toList();

                        return Text(
                          'Transactions (${filteredTransactions.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // Show printer options
                            },
                            icon: const Icon(Icons.print, color: Colors.grey),
                            tooltip: 'Print',
                          ),
                          IconButton(
                            onPressed: () {
                              // Download or export transactions
                            },
                            icon: const Icon(
                              Icons.download,
                              color: Colors.grey,
                            ),
                            tooltip: 'Export',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Department',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Amount',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'Action',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Obx(() {
                      final filteredTransactions = selectedTabIndex.value == 0
                          ? transactions
                          : transactions
                              .where(
                                (t) =>
                                    t['type'] == tabs[selectedTabIndex.value],
                              )
                              .toList();

                      if (filteredTransactions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionItem(
                            filteredTransactions[index],
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (transaction['iconColor'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      transaction['icon'] as IconData,
                      color: transaction['iconColor'] as Color,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    transaction['id'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${transaction['paymentMethod']} | ${transaction['type']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              transaction['department'] as String,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              transaction['date'] as String,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              transaction['amount'] as String,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: transaction['type'] == 'Revenue' ||
                        transaction['type'] == 'Receivable'
                    ? Colors.green
                    : Colors.red,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('View', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 18),
                      SizedBox(width: 8),
                      Text('Download', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                // Handle menu item selection
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentWiseSummaryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => Get.to(() => const AgentWiseSummaryScreen()),
        icon: const Icon(Icons.people_alt),
        label: const Text('Agent Wise Summary'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstantColors.accountsAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
