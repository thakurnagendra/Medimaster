import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/models/agent_billing_summary_model.dart';
import 'package:medimaster/services/agent_billing_summary_service.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:intl/intl.dart';

class AgentWiseSummaryScreen extends StatefulWidget {
  const AgentWiseSummaryScreen({super.key});

  @override
  State<AgentWiseSummaryScreen> createState() => _AgentWiseSummaryScreenState();
}

class _AgentWiseSummaryScreenState extends State<AgentWiseSummaryScreen> {
  final RxBool isLoading = false.obs;
  final RxList<AgentBillingSummaryModel> summaryData =
      <AgentBillingSummaryModel>[].obs;
  final numberFormat = NumberFormat("#,##0.00", "en_US");

  // Summary totals
  final RxDouble totalBasicAmount = 0.0.obs;
  final RxDouble totalDiscount = 0.0.obs;
  final RxDouble totalNetAmount = 0.0.obs;
  final RxDouble totalReceiptAmount = 0.0.obs;

  late final AgentBillingSummaryService _summaryService;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _summaryService = AgentBillingSummaryService(dio);
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    try {
      isLoading.value = true;
      final data = await _summaryService.getAgentBillingSummary();
      summaryData.assignAll(data);
      _calculateTotals();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load summary data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateTotals() {
    totalBasicAmount.value =
        summaryData.fold(0, (sum, item) => sum + item.bBasicAmt);
    totalDiscount.value =
        summaryData.fold(0, (sum, item) => sum + item.discount);
    totalNetAmount.value =
        summaryData.fold(0, (sum, item) => sum + item.bNetAmt);
    totalReceiptAmount.value =
        summaryData.fold(0, (sum, item) => sum + item.recieptAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      appBar: AppBar(
        title: const Text('Agent-wise Summary'),
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 20),
                _buildAgentList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Basic Amount',
                    totalBasicAmount.value,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Discount',
                    totalDiscount.value,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Net Amount',
                    totalNetAmount.value,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Receipt',
                    totalReceiptAmount.value,
                    AppConstantColors.labAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'NPR ${numberFormat.format(amount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAgentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agent-wise Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: summaryData.length,
          itemBuilder: (context, index) {
            final agent = summaryData[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  agent.agentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Net: NPR ${numberFormat.format(agent.bNetAmt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  'NPR ${numberFormat.format(agent.recieptAmount)}',
                  style: TextStyle(
                    color: AppConstantColors.labAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
