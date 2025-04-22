import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/controllers/main_controller.dart';
import 'package:medimaster/config/module_config.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MainController controller;
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? additionalActions;

  const TopAppBar({
    super.key,
    required this.controller,
    this.title = "MediMaster",
    this.showBackButton = false,
    this.onBackPressed,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get current module info
      final currentModule = controller.currentModule.value;
      final moduleInfo = ModuleConfig.getModuleInfo(currentModule);
      final moduleAccentColor = _getModuleAccentColor(currentModule);
      final moduleBackgroundColor = _getModuleBackgroundColor(currentModule);

      return AppBar(
        title: _buildCompanySwitcher(moduleAccentColor),
        backgroundColor: moduleBackgroundColor,
        titleSpacing: 0,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: moduleAccentColor),
                onPressed: onBackPressed ?? () => Get.back(),
              )
            : IconButton(
                icon: Icon(Icons.menu, color: moduleAccentColor),
                onPressed: controller.toggleDrawer,
              ),
        actions: [
          // Notifications icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: moduleAccentColor),
                onPressed: () {
                  // Handle notifications
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppConstantColors.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: AppConstantColors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          // If there are additional actions, add them
          if (additionalActions != null) ...additionalActions!,

          // Module switcher
          _buildModuleSwitcher(),
        ],
      );
    });
  }

  Widget _buildCompanySwitcher(Color accentColor) {
    return Builder(
      builder: (BuildContext context) => PopupMenuButton<String>(
        offset: const Offset(0, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onSelected: (value) {
          if (value.startsWith('switch_')) {
            final index = int.tryParse(value.substring(7));
            if (index != null) {
              controller.switchCompany(index);
            }
          } else if (value == 'add_company') {
            // Navigate to login screen for adding a new company
            Get.offAllNamed('/login', arguments: {'addingCompany': true});
          }
        },
        itemBuilder: (BuildContext context) {
          final List<PopupMenuEntry<String>> items = [];

          // Header
          items.add(
            const PopupMenuItem<String>(
              enabled: false,
              child: Text(
                'SWITCH COMPANY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppConstantColors.grey,
                ),
              ),
            ),
          );

          // List of companies
          for (int i = 0; i < controller.companies.length; i++) {
            final company = controller.companies[i];
            final isActive = i == controller.activeCompanyIndex.value;
            final Color companyColor = Color(company['color'] as int);

            items.add(
              PopupMenuItem<String>(
                value: 'switch_$i',
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Close the menu first
                        Get.back();
                        // Handle remove company after a short delay to ensure the popup is closed
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () {
                            controller.removeCompany(i);
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.remove_circle,
                          color: AppConstantColors.error,
                          size: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: companyColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          company['shortName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: companyColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            isActive ? 'Active' : 'Available',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstantColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      const Icon(Icons.check, color: AppConstantColors.success),
                  ],
                ),
              ),
            );
          }

          // Divider and add company option
          items.add(const PopupMenuDivider());
          items.add(
            const PopupMenuItem<String>(
              value: 'add_company',
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle,
                    color: AppConstantColors.primaryColor,
                  ),
                  SizedBox(width: 10),
                  Text('Add Company'),
                ],
              ),
            ),
          );

          return items;
        },
        child: Obx(() {
          final activeCompany = controller.activeCompany;
          final Color companyColor = Color(activeCompany['color'] as int);
          // Get company name and trim if too long
          final String companyName = activeCompany['name'] as String;
          final String displayName = companyName.length > 20
              ? '${companyName.substring(0, 20)}...'
              : companyName;

          return Container(
            padding: const EdgeInsets.only(
              left: 2,
              right: 10,
              top: 4,
              bottom: 4,
            ),
            decoration: null,
            constraints: const BoxConstraints(maxWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: accentColor, size: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildModuleSwitcher() {
    return Obx(() {
      final currentModule = controller.currentModule.value;
      final moduleInfo = ModuleConfig.getModuleInfo(currentModule);

      return Builder(
        builder: (BuildContext context) => PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: moduleInfo.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(moduleInfo.icon, color: moduleInfo.color, size: 18),
                const SizedBox(width: 4),
                Text(
                  moduleInfo.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: moduleInfo.color,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_drop_down,
                  color: moduleInfo.color,
                  size: 18,
                ),
              ],
            ),
          ),
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onSelected: (value) {
            controller.switchModule(value);
          },
          itemBuilder: (BuildContext context) {
            final items = <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'SELECT MODULE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppConstantColors.grey,
                  ),
                ),
              ),
            ];

            ModuleConfig.modules.forEach((key, module) {
              items.add(
                PopupMenuItem<String>(
                  value: key,
                  child: _buildModuleItem(
                    icon: module.icon,
                    color: module.color,
                    title: module.name,
                    isSelected: currentModule == key,
                  ),
                ),
              );
            });

            return items;
          },
        ),
      );
    });
  }

  Widget _buildModuleItem({
    required IconData icon,
    required Color color,
    required String title,
    bool isSelected = false,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(icon, color: color, size: 18)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isSelected ? color : AppConstantColors.textPrimary,
          ),
        ),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(Icons.check_circle, color: color, size: 16),
          ),
      ],
    );
  }

  // Helper methods to get module colors
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

  Color _getTextColor(Color backgroundColor) {
    // Assuming light colors have higher brightness
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? AppConstantColors.white
        : AppConstantColors.textPrimary;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
