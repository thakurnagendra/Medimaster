import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpdTransactionScreen extends StatelessWidget {
  const OpdTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF8E1,
      ), // Light orange background for OPD
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPD Transactions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage and track all consultations and payments',
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
                hintText: 'Search patients or doctors',
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
            color: Colors.orange,
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
              // Add new transaction
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final RxString selectedTab = 'All'.obs;
    final List<String> tabs = ['All', 'Consultation', 'Payment', 'Refund'];

    // Sample transactions data
    final List<Map<String, dynamic>> transactions = [
      {
        'id': 'TRX-2024-001',
        'patientName': 'Ram Kumar',
        'type': 'Consultation',
        'amount': 'NPR 1,200',
        'date': '04 Apr 2024',
        'doctor': 'Dr. Sharma',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': 'TRX-2024-002',
        'patientName': 'Sita Sharma',
        'type': 'Payment',
        'amount': 'NPR 2,200',
        'date': '03 Apr 2024',
        'doctor': 'Dr. Thapa',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': 'TRX-2024-003',
        'patientName': 'Hari Thapa',
        'type': 'Consultation',
        'amount': 'NPR 1,500',
        'date': '03 Apr 2024',
        'doctor': 'Dr. Sharma',
        'status': 'Pending',
        'statusColor': Colors.orange,
      },
      {
        'id': 'TRX-2024-004',
        'patientName': 'Gita Gurung',
        'type': 'Refund',
        'amount': 'NPR 800',
        'date': '02 Apr 2024',
        'doctor': 'Dr. Thapa',
        'status': 'Processed',
        'statusColor': Colors.blue,
      },
      {
        'id': 'TRX-2024-005',
        'patientName': 'Bishnu Rai',
        'type': 'Consultation',
        'amount': 'NPR 1,800',
        'date': '01 Apr 2024',
        'doctor': 'Dr. Sharma',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
    ];

    return Expanded(
      child: Column(
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: selectedTab.value == tab
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tab,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedTab.value == tab
                                    ? Colors.orange
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
                            'Patient / Doctor',
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
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final IconData typeIcon = transaction['type'] == 'Consultation'
        ? Icons.medical_services
        : transaction['type'] == 'Payment'
            ? Icons.payments
            : Icons.money_off;

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
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(typeIcon, color: Colors.orange, size: 20),
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
                        '${transaction['type']} | ${transaction['id']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Dr: ${transaction['doctor']} | ${transaction['date']}',
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    transaction['type'] == 'Refund' ? Colors.red : Colors.black,
              ),
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
