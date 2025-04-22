import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/client_billing_controller.dart';
import 'package:medimaster/models/client_billing_model.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class ClientWiseBillingScreen extends StatelessWidget {
  final ClientBillingController controller = Get.put(ClientBillingController());

  ClientWiseBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      appBar: AppBar(
        title: const Text('Agent-wise Billing'),
        backgroundColor: AppConstantColors.labAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchClientWiseBillings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSummarySection(),
          Expanded(
            child: _buildBillingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search by agent name, bill number or client ID',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppConstantColors.labAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        color: AppConstantColors.labAccent.withOpacity(0.05),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Basic Amount',
                    controller.formatCurrency(controller.totalBasicAmount),
                    Icons.account_balance,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Discount',
                    controller.formatCurrency(controller.totalDiscount),
                    Icons.discount,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Net Amount',
                    controller.formatCurrency(controller.totalNetAmount),
                    Icons.payment,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Receipt Amount',
                    controller.formatCurrency(controller.totalReceiptAmount),
                    Icons.receipt_long,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.billings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No billing records found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredBillings.length,
        itemBuilder: (context, index) {
          return _buildBillingCard(controller.filteredBillings[index]);
        },
      );
    });
  }

  Widget _buildBillingCard(ClientBillingModel billing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill #${billing.billNo}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstantColors.labAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Client ID: ${billing.clientId}',
                    style: const TextStyle(
                      color: AppConstantColors.labAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Agent: ${billing.agentName}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildAmountInfo(
                    'Basic Amount',
                    controller.formatCurrency(billing.basicAmount),
                  ),
                ),
                Expanded(
                  child: _buildAmountInfo(
                    'Discount',
                    controller.formatCurrency(billing.discount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildAmountInfo(
                    'Net Amount',
                    controller.formatCurrency(billing.netAmount),
                  ),
                ),
                Expanded(
                  child: _buildAmountInfo(
                    'Receipt Amount',
                    controller.formatCurrency(billing.receiptAmount),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String label, String amount) {
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
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
