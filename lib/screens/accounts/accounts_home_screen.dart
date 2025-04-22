import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class AccountsHomeScreen extends StatelessWidget {
  const AccountsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.accountsBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 20),
                _buildFinancialSummarySection(),
                const SizedBox(height: 20),
                _buildRevenueChartSection(),
                const SizedBox(height: 20),
                _buildRecentTransactionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accounts Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildTimePeriodSelector(), _buildDateDisplay()],
        ),
      ],
    );
  }

  Widget _buildTimePeriodSelector() {
    final List<String> timePeriods = [
      'Today',
      'This Week',
      'This Month',
      'This Year',
    ];
    final selectedPeriod = 'This Month'.obs;

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: selectedPeriod.value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
          underline: const SizedBox(),
          isDense: true,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: timePeriods
              .map(
                (String period) => DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                ),
              )
              .toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              selectedPeriod.value = newValue;
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateDisplay() {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Text(
      dateStr,
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildFinancialSummarySection() {
    return Container(
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
          const Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFinancialSummaryItem(
                'Total Revenue',
                'NPR 1.25M',
                Colors.green,
                Icons.trending_up,
              ),
              _buildFinancialSummaryItem(
                'Expenses',
                'NPR 750K',
                Colors.red,
                Icons.trending_down,
              ),
              _buildFinancialSummaryItem(
                'Profit',
                'NPR 500K',
                Colors.blue,
                Icons.account_balance,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFinancialSummaryItem(
                'Receivables',
                'NPR 320K',
                Colors.orange,
                Icons.receipt_long,
              ),
              _buildFinancialSummaryItem(
                'Payables',
                'NPR 180K',
                Colors.purple,
                Icons.payments,
              ),
              _buildFinancialSummaryItem(
                'Cash Flow',
                'NPR 140K',
                Colors.teal,
                Icons.show_chart,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryItem(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartSection() {
    return Container(
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
              const Text(
                'Revenue by Department',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'April 2024',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildBarChart()),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('OPD', Colors.blue),
              _buildLegendItem('IPD', Colors.red),
              _buildLegendItem('Pharmacy', Colors.green),
              _buildLegendItem('Laboratory', Colors.amber),
              _buildLegendItem('Radiology', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 500000,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String department;
              switch (group.x) {
                case 0:
                  department = 'OPD';
                  break;
                case 1:
                  department = 'IPD';
                  break;
                case 2:
                  department = 'Pharmacy';
                  break;
                case 3:
                  department = 'Laboratory';
                  break;
                case 4:
                  department = 'Radiology';
                  break;
                default:
                  department = '';
              }
              return BarTooltipItem(
                '$department\nNPR ${rod.toY.round()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String text = '';
                switch (value.toInt()) {
                  case 0:
                    text = 'OPD';
                    break;
                  case 1:
                    text = 'IPD';
                    break;
                  case 2:
                    text = 'PHR';
                    break;
                  case 3:
                    text = 'LAB';
                    break;
                  case 4:
                    text = 'RAD';
                    break;
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                String text = '';
                if (value == 0) {
                  text = '0';
                } else if (value == 250000) {
                  text = '250K';
                } else if (value == 500000) {
                  text = '500K';
                }
                return Text(
                  text,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarGroup(0, 320000, Colors.blue),
          _buildBarGroup(1, 450000, Colors.red),
          _buildBarGroup(2, 280000, Colors.green),
          _buildBarGroup(3, 180000, Colors.amber),
          _buildBarGroup(4, 120000, Colors.purple),
        ],
        gridData: FlGridData(
          show: true,
          checkToShowHorizontalLine: (value) => value % 250000 == 0,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
            dashArray: [5],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection() {
    final transactions = [
      {
        'id': 'TRX-5001',
        'department': 'OPD',
        'type': 'Revenue',
        'description': 'Consultation Fees',
        'amount': 'NPR 35,000',
        'date': '05 Apr 2024',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': 'TRX-5002',
        'department': 'Admin',
        'type': 'Expense',
        'description': 'Staff Salaries',
        'amount': 'NPR 120,000',
        'date': '04 Apr 2024',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': 'TRX-5003',
        'department': 'Pharmacy',
        'type': 'Expense',
        'description': 'Medication Purchase',
        'amount': 'NPR 45,000',
        'date': '03 Apr 2024',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': 'TRX-5004',
        'department': 'IPD',
        'type': 'Revenue',
        'description': 'Patient Billing',
        'amount': 'NPR 78,000',
        'date': '02 Apr 2024',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': 'TRX-5005',
        'department': 'Laboratory',
        'type': 'Revenue',
        'description': 'Test Services',
        'amount': 'NPR 25,000',
        'date': '01 Apr 2024',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
    ];

    return Container(
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
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all transactions screen
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...transactions.map(
            (transaction) => _buildTransactionItem(transaction),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isRevenue = transaction['type'] == 'Revenue';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isRevenue
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isRevenue ? Icons.arrow_downward : Icons.arrow_upward,
              color: isRevenue ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction['description'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      transaction['amount'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isRevenue ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${transaction['id']} | ${transaction['department']} | ${transaction['type']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      transaction['date'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
