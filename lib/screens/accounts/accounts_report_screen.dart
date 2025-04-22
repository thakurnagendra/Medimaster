import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AccountsReportScreen extends StatelessWidget {
  const AccountsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportCategories(),
                      const SizedBox(height: 16),
                      _buildFinancialReportsSection(),
                      const SizedBox(height: 16),
                      _buildRecentReportsSection(),
                      // Add bottom padding to prevent overflow
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Generate new report
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add_chart, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'View and generate financial reports and analysis',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildReportCategories() {
    final categories = [
      {
        'title': 'Profit & Loss',
        'count': '8',
        'icon': Icons.attach_money,
        'color': Colors.green,
      },
      {
        'title': 'Revenue Reports',
        'count': '12',
        'icon': Icons.trending_up,
        'color': Colors.blue,
      },
      {
        'title': 'Expense Reports',
        'count': '10',
        'icon': Icons.trending_down,
        'color': Colors.red,
      },
      {
        'title': 'Balance Sheet',
        'count': '6',
        'icon': Icons.account_balance,
        'color': Colors.purple,
      },
      {
        'title': 'Cash Flow',
        'count': '7',
        'icon': Icons.show_chart,
        'color': Colors.amber,
      },
      {
        'title': 'Tax Reports',
        'count': '5',
        'icon': Icons.receipt_long,
        'color': Colors.teal,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(
          title: categories[index]['title'] as String,
          count: categories[index]['count'] as String,
          icon: categories[index]['icon'] as IconData,
          color: categories[index]['color'] as Color,
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$count reports',
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialReportsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
                'Revenue vs Expenses',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Last 6 Months',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(height: 180, child: _buildLineChart()),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Revenue', Colors.green),
              const SizedBox(width: 12),
              _buildLegendItem('Expenses', Colors.red),
              const SizedBox(width: 12),
              _buildLegendItem('Profit', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
          handleBuiltInTouches: true,
          touchCallback:
              (FlTouchEvent event, LineTouchResponse? touchResponse) {},
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('Nov', style: style);
                    break;
                  case 1:
                    text = const Text('Dec', style: style);
                    break;
                  case 2:
                    text = const Text('Jan', style: style);
                    break;
                  case 3:
                    text = const Text('Feb', style: style);
                    break;
                  case 4:
                    text = const Text('Mar', style: style);
                    break;
                  case 5:
                    text = const Text('Apr', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: text,
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 100000,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value == 0 ? '0' : '${(value / 1000).toInt()}K',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.right,
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 400000,
        lineBarsData: [
          // Revenue Line
          LineChartBarData(
            spots: const [
              FlSpot(0, 250000),
              FlSpot(1, 280000),
              FlSpot(2, 260000),
              FlSpot(3, 300000),
              FlSpot(4, 320000),
              FlSpot(5, 350000),
            ],
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
          // Expenses Line
          LineChartBarData(
            spots: const [
              FlSpot(0, 180000),
              FlSpot(1, 220000),
              FlSpot(2, 190000),
              FlSpot(3, 200000),
              FlSpot(4, 210000),
              FlSpot(5, 230000),
            ],
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.1),
            ),
          ),
          // Profit Line
          LineChartBarData(
            spots: const [
              FlSpot(0, 70000),
              FlSpot(1, 60000),
              FlSpot(2, 70000),
              FlSpot(3, 100000),
              FlSpot(4, 110000),
              FlSpot(5, 120000),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReportsSection() {
    final reports = [
      {
        'id': 'RPT-2001',
        'title': 'Monthly Profit & Loss Statement',
        'date': '05 Apr 2024',
        'type': 'Profit & Loss',
        'format': 'PDF',
        'size': '2.4 MB',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
      },
      {
        'id': 'RPT-2002',
        'title': 'Quarterly Revenue Analysis',
        'date': '01 Apr 2024',
        'type': 'Revenue',
        'format': 'Excel',
        'size': '1.8 MB',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.table_chart,
      },
      {
        'id': 'RPT-2003',
        'title': 'Annual Financial Statement',
        'date': '31 Mar 2024',
        'type': 'Balance Sheet',
        'format': 'PDF',
        'size': '5.3 MB',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
      },
      {
        'id': 'RPT-2004',
        'title': 'Monthly Expense Report',
        'date': '30 Mar 2024',
        'type': 'Expense',
        'format': 'Excel',
        'size': '1.7 MB',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.table_chart,
      },
      {
        'id': 'RPT-2005',
        'title': 'Cash Flow Analysis',
        'date': '25 Mar 2024',
        'type': 'Cash Flow',
        'format': 'PDF',
        'size': '3.2 MB',
        'status': 'Generated',
        'statusColor': Colors.green,
        'icon': Icons.description,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
                'Recent Reports',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all reports
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...reports.map((report) => _buildReportItem(report)),
        ],
      ),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              report['icon'] as IconData,
              color: Colors.blue,
              size: 16,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        report['format'] as String,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${report['id']} | ${report['type']} | ${report['size']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report['date'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // View report
                },
                icon: const Icon(
                  Icons.visibility,
                  color: Colors.blue,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'View Report',
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  // Download report
                },
                icon: const Icon(Icons.download, color: Colors.green, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Download Report',
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  // Share report
                },
                icon: const Icon(Icons.share, color: Colors.orange, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Share Report',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
