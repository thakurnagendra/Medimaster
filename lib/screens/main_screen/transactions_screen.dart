import 'package:flutter/material.dart';
import 'package:medimaster/screens/main_screen.dart';

class TransactionsScreen extends StatelessWidget {
  final String moduleType;

  const TransactionsScreen({super.key, this.moduleType = 'default'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ModuleScreenFactory.getModuleColor(moduleType),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moduleType == 'lab'
                    ? 'Lab Transactions'
                    : moduleType == 'billing'
                    ? 'Billing Transactions'
                    : 'Transactions',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 20),
              _buildTransactionFilters(),
              const SizedBox(height: 20),
              _buildTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionFilters() {
    // Get accent color based on module type
    Color accentColor = ModuleScreenFactory.getModuleAccentColor(moduleType);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: accentColor,
                    ),
                    child: const Text('Date Range'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: accentColor,
                    ),
                    child: const Text('Status'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: accentColor,
                    ),
                    child: const Text('Amount'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Get accent color based on module type
    Color accentColor = ModuleScreenFactory.getModuleAccentColor(moduleType);

    // Different column titles based on module type
    List<Widget> headerColumns = [];

    if (moduleType == 'lab') {
      headerColumns = const [
        Expanded(
          flex: 2,
          child: Text('Test ID', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Patient Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Test Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 1,
          child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ];
    } else if (moduleType == 'billing') {
      headerColumns = const [
        Expanded(
          flex: 2,
          child: Text(
            'Invoice #',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Patient Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 1,
          child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 1,
          child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ];
    } else {
      headerColumns = const [
        Expanded(
          flex: 2,
          child: Text(
            'Transaction ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Patient Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 1,
          child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ];
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  moduleType == 'lab'
                      ? 'Recent Lab Tests'
                      : moduleType == 'billing'
                      ? 'Recent Invoices'
                      : 'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('View All', style: TextStyle(color: accentColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: Row(children: headerColumns),
            ),
            // Transaction items with module-specific data
            if (moduleType == 'lab')
              _buildLabTransactions()
            else if (moduleType == 'billing')
              _buildBillingTransactions()
            else
              _buildDefaultTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabTransactions() {
    return Column(
      children: [
        _labTransactionItem(
          'LAB-2024-001',
          'Ram Kumar',
          'Blood Test',
          'NPR 1,200',
          'Completed',
          Colors.green,
        ),
        _labTransactionItem(
          'LAB-2024-002',
          'Sita Sharma',
          'X-Ray',
          'NPR 2,200',
          'In Progress',
          Colors.orange,
        ),
        _labTransactionItem(
          'LAB-2024-003',
          'Hari Thapa',
          'Ultrasound',
          'NPR 3,500',
          'Completed',
          Colors.green,
        ),
        _labTransactionItem(
          'LAB-2024-004',
          'Gita Gurung',
          'MRI Scan',
          'NPR 8,000',
          'Scheduled',
          Colors.blue,
        ),
        _labTransactionItem(
          'LAB-2024-005',
          'Bishnu Rai',
          'Dental X-Ray',
          'NPR 1,800',
          'Completed',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildBillingTransactions() {
    return Column(
      children: [
        _billingTransactionItem(
          'INV-2024-001',
          'Ram Kumar',
          'Apr 10, 2024',
          'NPR 5,500',
          'Paid',
          Colors.green,
        ),
        _billingTransactionItem(
          'INV-2024-002',
          'Sita Sharma',
          'Apr 8, 2024',
          'NPR 3,200',
          'Partial',
          Colors.orange,
        ),
        _billingTransactionItem(
          'INV-2024-003',
          'Hari Thapa',
          'Apr 5, 2024',
          'NPR 8,700',
          'Paid',
          Colors.green,
        ),
        _billingTransactionItem(
          'INV-2024-004',
          'Gita Gurung',
          'Apr 3, 2024',
          'NPR 12,500',
          'Unpaid',
          Colors.red,
        ),
        _billingTransactionItem(
          'INV-2024-005',
          'Bishnu Rai',
          'Apr 1, 2024',
          'NPR 6,200',
          'Paid',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildDefaultTransactions() {
    return Column(
      children: [
        _transactionItem(
          'TRX-2024-001',
          'Ram Kumar',
          'NPR 2,500',
          'Completed',
          Colors.green,
        ),
        _transactionItem(
          'TRX-2024-002',
          'Sita Sharma',
          'NPR 1,800',
          'Pending',
          Colors.orange,
        ),
        _transactionItem(
          'TRX-2024-003',
          'Hari Thapa',
          'NPR 3,200',
          'Completed',
          Colors.green,
        ),
        _transactionItem(
          'TRX-2024-004',
          'Gita Gurung',
          'NPR 950',
          'Failed',
          Colors.red,
        ),
        _transactionItem(
          'TRX-2024-005',
          'Bishnu Rai',
          'NPR 1,250',
          'Completed',
          Colors.green,
        ),
      ],
    );
  }

  Widget _labTransactionItem(
    String testId,
    String patientName,
    String testType,
    String amount,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(testId)),
          Expanded(flex: 2, child: Text(patientName)),
          Expanded(flex: 2, child: Text(testType)),
          Expanded(flex: 1, child: Text(amount)),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billingTransactionItem(
    String invoiceId,
    String patientName,
    String date,
    String amount,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(invoiceId)),
          Expanded(flex: 2, child: Text(patientName)),
          Expanded(flex: 1, child: Text(date)),
          Expanded(flex: 1, child: Text(amount)),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(
    String transactionId,
    String patientName,
    String amount,
    String status,
    Color statusColor,
  ) {
    // Format amount with proper currency symbol and thousands separator
    String formattedAmount =
        'NPR ${double.parse(amount.replaceAll(RegExp(r'[^0-9.]'), '')).toStringAsFixed(2)}';

    // Normalize status text
    String normalizedStatus = status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              transactionId,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              patientName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              formattedAmount,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                normalizedStatus,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
