import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/main_controller.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final MainController controller;

  const CustomBottomNavigationBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentModule = controller.currentModule.value;
      final Color moduleAccentColor = _getModuleAccentColor(currentModule);
      final Color moduleBackgroundColor = _getModuleBackgroundColor(
        currentModule,
      );

      return BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        backgroundColor: AppConstantColors.white,
        selectedItemColor: moduleAccentColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: controller.changePage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet, size: 30),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report, size: 30),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: "Settings",
          ),
        ],
      );
    });
  }

  // Helper method to get module accent color
  Color _getModuleAccentColor(String module) {
    switch (module) {
      case 'lab':
        return AppConstantColors.labAccent;
      case 'pharmacy':
        return AppConstantColors.pharmacyAccent;
      case 'opd':
        return AppConstantColors.opdAccent;
      case 'ipd':
        return AppConstantColors.ipdAccent;
      case 'accounts':
        return AppConstantColors.accountsAccent;
      case 'billing':
        return AppConstantColors.billingAccent;
      default:
        return AppConstantColors.defaultAccent;
    }
  }

  // Helper method to get module background color
  Color _getModuleBackgroundColor(String module) {
    switch (module) {
      case 'lab':
        return AppConstantColors.labBackground;
      case 'pharmacy':
        return AppConstantColors.pharmacyBackground;
      case 'opd':
        return AppConstantColors.opdBackground;
      case 'ipd':
        return AppConstantColors.ipdBackground;
      case 'accounts':
        return AppConstantColors.accountsBackground;
      case 'billing':
        return AppConstantColors.billingBackground;
      default:
        return AppConstantColors.background;
    }
  }
}
