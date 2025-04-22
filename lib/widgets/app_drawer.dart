import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/main_controller.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppDrawer extends StatelessWidget {
  final MainController controller;

  const AppDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentModule = controller.currentModule.value;
      final moduleAccentColor = _getModuleAccentColor(currentModule);
      final moduleBackgroundColor = _getModuleBackgroundColor(currentModule);

      return Drawer(
        child: Column(
          children: [
            // White Header
            Container(
              width: double.infinity,
              color: AppConstantColors.white,
              margin: const EdgeInsets.only(top: 30),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/medimasterlogo.png',
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Provide fallback widget if image fails to load
                      return Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: Text(
                          'MediMaster',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: moduleAccentColor,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: moduleAccentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getModuleName(currentModule),
                      style: TextStyle(
                        color: moduleAccentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Drawer Items with Module Background Color
            Expanded(
              child: Container(
                color:
                    moduleBackgroundColor, // Drawer background using module background color
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true, // Remove the padding at the top
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Utility Tools Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Utility Tools',
                          style: TextStyle(
                            color: moduleAccentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildDrawerItem(
                        Icons.qr_code_scanner,
                        'QR Code Scanner',
                        moduleAccentColor,
                      ),
                      const Divider(height: 1, indent: 15, endIndent: 16),
                      _buildDrawerItem(
                        FontAwesomeIcons.barcode,
                        'Barcode Scanner',
                        moduleAccentColor,
                      ),
                      const Divider(height: 1, indent: 15, endIndent: 16),
                      _buildDrawerItem(
                        Icons.calculate,
                        'Calculator',
                        moduleAccentColor,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  ListTile _buildDrawerItem(IconData icon, String title, Color accentColor) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(height: 4),
          Container(
            width: 24,
            height: 1,
            color: accentColor.withOpacity(0.3),
          ),
        ],
      ),
      title: Text(
        title,
        style: TextStyle(color: accentColor),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => controller.onDrawerItemTap(title),
    );
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

  // Helper method to get module name
  String _getModuleName(String module) {
    switch (module) {
      case 'lab':
        return 'Laboratory';
      case 'pharmacy':
        return 'Pharmacy';
      case 'opd':
        return 'OPD';
      case 'ipd':
        return 'IPD';
      case 'accounts':
        return 'Accounts';
      case 'billing':
        return 'Billing';
      default:
        return 'Dashboard';
    }
  }
}
