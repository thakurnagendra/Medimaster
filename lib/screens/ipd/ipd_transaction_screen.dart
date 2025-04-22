import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/controllers/ipd_controllers/ipd_transaction_controller.dart';

class IpdTransactionScreen extends GetView<IpdTransactionController> {
  @override
  IpdTransactionController controller = Get.put(IpdTransactionController());
  IpdTransactionScreen({super.key});

  final List<String> tabs = [
    'All',
    'Admission',
    'Room',
    'Medication',
    'Services',
    'Payment',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.ipdBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchAndFilter(),
              const SizedBox(height: 20),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new transaction
        },
        backgroundColor: AppConstantColors.ipdAccent,
        child: const Icon(Icons.add, color: AppConstantColors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IPD Transactions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstantColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Manage in-patient department billings and payments',
          style: TextStyle(
            fontSize: 14,
            color: AppConstantColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search patient or bill number',
              prefixIcon:
                  const Icon(Icons.search, color: AppConstantColors.grey),
              filled: true,
              fillColor: AppConstantColors.white,
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
                borderSide: const BorderSide(
                  color: AppConstantColors.ipdAccent,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppConstantColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () {
              // Show filter options
            },
            icon: const Icon(Icons.filter_list,
                color: AppConstantColors.ipdAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
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
                return Obx(
                  () => GestureDetector(
                    onTap: () => controller.changeTab(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: controller.selectedTabIndex.value == index
                            ? AppConstantColors.ipdAccent
                            : AppConstantColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: controller.selectedTabIndex.value == index
                              ? AppConstantColors.ipdAccent
                              : AppConstantColors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: controller.selectedTabIndex.value == index
                                ? AppConstantColors.white
                                : AppConstantColors.textPrimary,
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
                color: AppConstantColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppConstantColors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                final filteredTransactions = controller.filteredTransactions;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            'Transactions (${controller.filteredTransactions.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Download or export transactions
                          },
                          icon: const Icon(
                            Icons.download,
                            color: AppConstantColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Obx(
                        () => controller.filteredTransactions.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 48,
                                      color: AppConstantColors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No transactions found',
                                      style: TextStyle(
                                        color: AppConstantColors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount:
                                    controller.filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  return _buildTransactionItem(
                                    controller.filteredTransactions[index],
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppConstantColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(
                transaction['statusColor'],
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(transaction['icon']),
              color: _getStatusColor(transaction['statusColor']),
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
                      transaction['id'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      transaction['amount'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${transaction['patient']} (${transaction['patientId']})',
                      style: const TextStyle(
                        color: AppConstantColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          transaction['statusColor'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction['status'] as String,
                        style: TextStyle(
                          color: _getStatusColor(transaction['statusColor']),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction['description'] as String,
                      style: const TextStyle(
                        color: AppConstantColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      transaction['date'] as String,
                      style: const TextStyle(
                        color: AppConstantColors.textSecondary,
                        fontSize: 12,
                      ),
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

  Color _getStatusColor(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'assignment_ind':
        return Icons.assignment_ind;
      case 'hotel':
        return Icons.hotel;
      case 'medication':
        return Icons.medication;
      case 'medical_services':
        return Icons.medical_services;
      case 'payments':
        return Icons.payments;
      default:
        return Icons.receipt;
    }
  }
}
