import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/controllers/main_controller.dart';

class PharmacyHomeScreen extends StatelessWidget {
  // Added moduleType property to clearly associate this screen with its module
  final String moduleType = 'pharmacy';

  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // No need to get reference to the main controller since it's not used
    
    return Container(
      color: AppConstantColors.pharmacyBackground,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 20),
            _buildStatisticsSection(),
            const SizedBox(height: 20),
            _buildRecentOrdersSection(),
            const SizedBox(height: 20),
            _buildLowStockSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pharmacy Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstantColors.textPrimary,
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
    final selectedPeriod = 'This Week'.obs;

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppConstantColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppConstantColors.grey.withValues(alpha: 26),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: selectedPeriod.value,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppConstantColors.pharmacyAccent,
          ),
          underline: const SizedBox(),
          isDense: true,
          style: const TextStyle(
            color: AppConstantColors.textPrimary,
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
      style: const TextStyle(
        color: AppConstantColors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstantColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstantColors.grey.withValues(alpha: 26),
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
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Sales', 'NPR 86,242', AppConstantColors.info),
              _buildStatItem('Orders', '128', AppConstantColors.pharmacyAccent),
              _buildStatItem('Products', '432', AppConstantColors.warning),
              _buildStatItem(
                'Today',
                'NPR 4,582',
                AppConstantColors.accountsAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            title == 'Sales'
                ? Icons.attach_money
                : title == 'Orders'
                    ? Icons.shopping_cart
                    : title == 'Products'
                        ? Icons.medication
                        : Icons.today,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppConstantColors.grey),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection() {
    final recentOrders = [
      {
        'id': 'ORD-2024-001',
        'patientName': 'Ram Kumar',
        'items': '3 items',
        'amount': 'NPR 1,200',
        'date': '04 Apr 2024',
        'status': 'Completed',
      },
      {
        'id': 'ORD-2024-002',
        'patientName': 'Sita Sharma',
        'items': '2 items',
        'amount': 'NPR 850',
        'date': '03 Apr 2024',
        'status': 'Processing',
      },
      {
        'id': 'ORD-2024-003',
        'patientName': 'Hari Thapa',
        'items': '5 items',
        'amount': 'NPR 2,300',
        'date': '03 Apr 2024',
        'status': 'Completed',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstantColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstantColors.grey.withValues(alpha: 26),
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
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstantColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all orders screen
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppConstantColors.pharmacyAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentOrders.map((order) => _buildOrderItem(order)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final Color statusColor = order['status'] == 'Completed'
        ? AppConstantColors.success
        : order['status'] == 'Processing'
            ? AppConstantColors.warning
            : AppConstantColors.info;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppConstantColors.greyLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstantColors.pharmacyAccent.withValues(alpha: 26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: AppConstantColors.pharmacyAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['patientName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${order['items']} | ID: ${order['id']}',
                  style: const TextStyle(
                    color: AppConstantColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order['amount'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 26),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection() {
    final lowStockItems = [
      {
        'name': 'Paracetamol 500mg',
        'code': 'MED001',
        'stock': '10 strips',
        'threshold': '15 strips',
      },
      {
        'name': 'Amoxicillin 250mg',
        'code': 'MED042',
        'stock': '5 bottles',
        'threshold': '8 bottles',
      },
      {
        'name': 'Insulin Regular',
        'code': 'MED108',
        'stock': '3 vials',
        'threshold': '5 vials',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstantColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstantColors.grey.withValues(alpha: 26),
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
                'Low Stock Alert',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstantColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to inventory screen
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppConstantColors.pharmacyAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...lowStockItems.map((item) => _buildLowStockItem(item)),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppConstantColors.error.withValues(alpha: 26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstantColors.error.withValues(alpha: 39)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.medication,
                  color: AppConstantColors.error, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Code: ${item['code']}',
                    style: const TextStyle(
                      color: AppConstantColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Stock: ${item['stock']}',
                style: const TextStyle(
                  color: AppConstantColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Min: ${item['threshold']}',
                style: const TextStyle(
                  color: AppConstantColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
