// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:medimaster/controllers/main_controller.dart';
import 'package:medimaster/controllers/lab_transaction_controller.dart';
import 'package:medimaster/widgets/buttom_navigation_bar.dart';
import 'package:medimaster/widgets/top_app_bar.dart';
import 'package:medimaster/widgets/app_drawer.dart';
import 'package:medimaster/widgets/activity_tracker.dart';
import 'package:medimaster/controllers/auth_controllers/signin_controllers.dart';
import 'package:medimaster/services/back_button_service.dart';

// Import all the separate screen components
import 'package:medimaster/screens/main_screen/finance_chart_screen.dart';
import 'package:medimaster/screens/main_screen/transactions_screen.dart';
import 'package:medimaster/screens/main_screen/reports_screen.dart';
import 'package:medimaster/screens/main_screen/settings_screen.dart';
import 'package:medimaster/screens/main_screen/billing_chart_screen.dart';

// Import module-specific screens
import 'package:medimaster/screens/lab/lab_home_screen.dart';
import 'package:medimaster/screens/lab/lab_transaction_screen.dart';
import 'package:medimaster/screens/lab/lab_report_screen.dart';
import 'package:medimaster/screens/pharmacy/pharmacy_home_screen.dart';
import 'package:medimaster/screens/pharmacy/pharmacy_transaction_screen.dart';
import 'package:medimaster/screens/pharmacy/pharmacy_report_screen.dart';
import 'package:medimaster/screens/opd/opd_home_screen.dart';
import 'package:medimaster/screens/opd/opd_transaction_screen.dart';
import 'package:medimaster/screens/opd/opd_report_screen.dart';
import 'package:medimaster/screens/ipd/ipd_home_screen.dart';
import 'package:medimaster/screens/ipd/ipd_transaction_screen.dart';
import 'package:medimaster/screens/ipd/ipd_report_screen.dart';
import 'package:medimaster/screens/accounts/accounts_home_screen.dart';
import 'package:medimaster/screens/accounts/accounts_transaction_screen.dart';
import 'package:medimaster/screens/accounts/accounts_report_screen.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/widgets/module_wrapper_page.dart';

// Factory class for module-specific screens
class ModuleScreenFactory {
  // Get the appropriate color for a module
  static Color getModuleColor(String module) {
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

  // Get the appropriate accent color for a module
  static Color getModuleAccentColor(String module) {
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

  static Widget getHomeScreen(String module) {
    Widget screen;
    switch (module) {
      case 'lab':
        screen = const LabHomeScreen();
        break;
      case 'pharmacy':
        screen = const PharmacyHomeScreen();
        break;
      case 'opd':
        screen = const OpdHomeScreen();
        break;
      case 'ipd':
        screen = const IpdHomeScreen();
        break;
      case 'accounts':
        screen = const AccountsHomeScreen();
        break;
      case 'billing':
        screen = BillingChartScreen();
        break;
      default:
        screen = FinanceChartScreen();
        break;
    }

    // Wrap all home screens with our ModuleWrapperPage
    return ModuleWrapperPage(moduleName: module, child: screen);
  }

  static Widget getTransactionsScreen(String module) {
    Widget screen;
    switch (module) {
      case 'lab':
        // Initialize lab binding if not already initialized
        if (!Get.isRegistered<LabTransactionController>()) {
          Get.lazyPut<LabTransactionController>(
            () => LabTransactionController(),
          );
        }
        screen = const LabTransactionScreen();
        break;
      case 'pharmacy':
        screen = const PharmacyTransactionScreen();
        break;
      case 'opd':
        screen = const OpdTransactionScreen();
        break;
      case 'ipd':
        screen = IpdTransactionScreen();
        break;
      case 'accounts':
        screen = const AccountsTransactionScreen();
        break;
      case 'billing':
        screen = const TransactionsScreen(moduleType: 'billing');
        break;
      default:
        screen = const TransactionsScreen(moduleType: 'default');
        break;
    }

    // Wrap all transaction screens with our ModuleWrapperPage
    return ModuleWrapperPage(moduleName: module, child: screen);
  }

  static Widget getReportsScreen(String module) {
    Widget screen;
    switch (module) {
      case 'lab':
        screen = const LabReportScreen();
        break;
      case 'pharmacy':
        screen = const PharmacyReportScreen();
        break;
      case 'opd':
        screen = const OpdReportScreen();
        break;
      case 'ipd':
        screen = const IpdReportScreen();
        break;
      case 'accounts':
        screen = const AccountsReportScreen();
        break;
      case 'billing':
        screen = const ReportsScreen(moduleType: 'billing');
        break;
      default:
        screen = const ReportsScreen(moduleType: 'default');
        break;
    }

    // Wrap all report screens with our ModuleWrapperPage
    return ModuleWrapperPage(moduleName: module, child: screen);
  }

  // Get a descriptive title for the current module and page
  static String getPageTitle(String module, int pageIndex) {
    switch (pageIndex) {
      case 0:
        switch (module) {
          case 'lab':
            return 'Lab Dashboard';
          case 'pharmacy':
            return 'Pharmacy Dashboard';
          case 'opd':
            return 'OPD Dashboard';
          case 'ipd':
            return 'IPD Dashboard';
          case 'accounts':
            return 'Accounts Dashboard';
          case 'billing':
            return 'Billing Dashboard';
          default:
            return 'Dashboard';
        }
      case 1:
        switch (module) {
          case 'lab':
            return 'Lab Transactions';
          case 'pharmacy':
            return 'Pharmacy Transactions';
          case 'opd':
            return 'OPD Transactions';
          case 'ipd':
            return 'IPD Transactions';
          case 'accounts':
            return 'Accounts Transactions';
          case 'billing':
            return 'Billing Transactions';
          default:
            return 'Transactions';
        }
      case 2:
        switch (module) {
          case 'lab':
            return 'Lab Reports';
          case 'pharmacy':
            return 'Pharmacy Reports';
          case 'opd':
            return 'OPD Reports';
          case 'ipd':
            return 'IPD Reports';
          case 'accounts':
            return 'Accounts Reports';
          case 'billing':
            return 'Billing Reports';
          default:
            return 'Reports';
        }
      case 3:
        return 'Settings';
      default:
        return 'MediMaster';
    }
  }
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  // Get the controller
  final MainController controller = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    // Add a delay for the UI to fully initialize before any interactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Allow the scaffold to be fully laid out first
      Future.delayed(const Duration(milliseconds: 100), () {
        // Force UI refresh after layout is complete
        controller.update();

        // Update the activity timestamp when screen is built
        try {
          Get.find<SignInController>().updateLastActivityTime();
        } catch (e) {
          // Silently ignore if controller is not found
        }
      });
    });

    return Obx(() {
      final currentModule = controller.currentModule.value;
      final Color moduleAccentColor = _getModuleAccentColor(currentModule);
      final Color moduleBackgroundColor = _getModuleBackgroundColor(
        currentModule,
      );

      // Update system UI overlay style to match the module background color
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: moduleBackgroundColor,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: moduleBackgroundColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      return Builder(
        builder: (context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;

              // Show exit confirmation dialog with current module name
              final BackButtonService backButtonService =
                  Get.find<BackButtonService>();
              final String activeModule = controller.currentModule.value;
              await backButtonService.showExitConfirmationDialog(
                moduleName: activeModule,
              );
            },
            child: ActivityTracker(
              child: Scaffold(
                key: controller.scaffoldKey,
                appBar: TopAppBar(controller: controller),
                drawer: AppDrawer(controller: controller),
                body: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Use GetBuilder to listen for specific updates to module_content
                      return GetBuilder<MainController>(
                        id: 'module_content',
                        builder: (_) {
                          // Access reactive variables directly to ensure they're tracked
                          final String activeModule =
                              controller.currentModule.value;
                          final int selectedIndex =
                              controller.selectedIndex.value;

                          // Return the correct screen based on the selected index
                          switch (selectedIndex) {
                            case 0:
                              return ModuleScreenFactory.getHomeScreen(
                                activeModule,
                              );
                            case 1:
                              return ModuleScreenFactory.getTransactionsScreen(
                                activeModule,
                              );
                            case 2:
                              return ModuleScreenFactory.getReportsScreen(
                                activeModule,
                              );
                            case 3:
                              return const ModuleWrapperPage(
                                moduleName: 'settings',
                                child: SettingsScreen(),
                              );
                            default:
                              return ModuleScreenFactory.getHomeScreen(
                                activeModule,
                              );
                          }
                        },
                      );
                    },
                  ),
                ),
                bottomNavigationBar: CustomBottomNavigationBar(
                  controller: controller,
                ),
              ),
            ),
          );
        },
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
