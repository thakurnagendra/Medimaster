import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/controllers/finance_chart_controller.dart';

class FinanceChartScreen extends StatelessWidget {
  FinanceChartScreen({super.key});

  final FinanceChartController controller = Get.put(FinanceChartController());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstantColors.labBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lab Financial Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 20),
              _buildTimeFrameSelector(),
              const SizedBox(height: 20),
              _buildFinancialSummary(),
              const SizedBox(height: 20),
              _buildMainChart(),
              const SizedBox(height: 20),
              _buildFinancialMetrics(),
              const SizedBox(height: 20),
              _buildRecentTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              controller.timeFrames.map((timeFrame) {
                return GestureDetector(
                  onTap: () => controller.changeTimeFrame(timeFrame),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          controller.selectedTimeFrame.value == timeFrame
                              ? Colors.green.shade700
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      timeFrame,
                      style: TextStyle(
                        color:
                            controller.selectedTimeFrame.value == timeFrame
                                ? Colors.white
                                : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade600.withOpacity(0.8),
              Colors.green.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.account_balance_wallet, color: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Net Amount',
                  '₹${controller.totalNet.value.toStringAsFixed(0)}',
                  Colors.white,
                ),
                _buildSummaryItem(
                  'Receipt Amount',
                  '₹${controller.totalReceipt.value.toStringAsFixed(0)}',
                  Colors.white,
                ),
                _buildSummaryItem(
                  'Difference',
                  '₹${controller.difference.value.toStringAsFixed(0)}',
                  controller.difference.value >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMainChart() {
    return Obx(
      () => Container(
        height: 350,
        padding: const EdgeInsets.all(16),
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
            const Text(
              'Net vs Receipt Amounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  controller.netAmounts.isNotEmpty
                      ? BarChart(_createBarChartData())
                      : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  AppConstantColors.secondaryColor,
                  'Net Amount',
                ),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.greenAccent.shade400, 'Receipt Amount'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _createBarChartData() {
    final maxY = controller.netAmounts.reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      titlesData: _getTitlesData(),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(
        controller.netAmounts.length,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: controller.netAmounts[index],
              color: AppConstantColors.secondaryColor,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: controller.receiptAmounts[index],
              color: Colors.greenAccent.shade400,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= controller.timeLabels.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                controller.timeLabels[value.toInt()],
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          },
          reservedSize: 30,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            // Dynamically calculate value intervals based on data range
            final maxAmount = controller.netAmounts.reduce(
              (a, b) => a > b ? a : b,
            );

            if (value == 0) {
              return const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(
                  '0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              );
            } else if (value % (maxAmount / 4) < 0.001 * maxAmount) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  controller.formatCurrency(value),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
          reservedSize: 40,
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFinancialMetrics() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
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
            const Text(
              'Financial Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Collection Rate',
                    controller.collectionRate.value,
                    Icons.trending_up,
                    Colors.green,
                    '+2.5% from last month',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Pending Rate',
                    controller.pendingRate.value,
                    Icons.trending_down,
                    Colors.orange,
                    '-1.3% from last month',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(change, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final bool isReceipt = index % 2 == 0;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        isReceipt
                            ? Colors.green.withOpacity(0.1)
                            : AppConstantColors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isReceipt ? Icons.arrow_downward : Icons.arrow_upward,
                    color:
                        isReceipt
                            ? Colors.green
                            : AppConstantColors.secondaryColor,
                  ),
                ),
                title: Text(
                  isReceipt
                      ? 'Receipt #${1001 + index}'
                      : 'Invoice #${2001 + index}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  DateTime.now()
                      .subtract(Duration(days: index))
                      .toString()
                      .substring(0, 10),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                trailing: Text(
                  isReceipt
                      ? '+₹${(1500 + index * 100).toString()}'
                      : '₹${(1800 + index * 150).toString()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isReceipt
                            ? Colors.green
                            : AppConstantColors.secondaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
