import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:medimaster/config/module_config.dart';
import 'package:medimaster/widgets/qr_scanner_view.dart';
import 'package:medimaster/widgets/calculator_view.dart';
import 'auth_controllers/signin_controllers.dart';

class MainController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final RxInt selectedIndex = 0.obs;
  final RxString currentModule = 'lab'.obs;
  final GetStorage storage = GetStorage();

  // RxList to store account information
  final RxList<Map<String, dynamic>> accounts = <Map<String, dynamic>>[].obs;
  final RxInt activeAccountIndex = 0.obs;

  // RxList to store company information
  final RxList<Map<String, dynamic>> companies = <Map<String, dynamic>>[].obs;
  final RxInt activeCompanyIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCompanies();
    _checkPendingCompany();
    _loadAccounts();
    _loadCurrentModule();

    // Update activity timestamp when app is initialized
    _updateUserActivity();
  }

  @override
  void onReady() {
    super.onReady();
    // This is called after the widget is rendered on screen
    // Use this to perform operations that need the UI to be ready
    Future.delayed(const Duration(milliseconds: 200), () {
      update(); // Force UI refresh after widgets are laid out
    });
  }

  @override
  void onClose() {
    // Save any pending data before controller is removed
    _saveCompanies();
    _saveAccounts();
    _saveCurrentModule();
    super.onClose();
  }

  // Check for a pending company added during login
  void _checkPendingCompany() {
    final pendingCompany = storage.read<Map<String, dynamic>>('pendingCompany');
    if (pendingCompany != null) {
      // Debug the pending company data
      print(
        'Found pending company data: ${pendingCompany.toString().replaceAll(RegExp(r'"accessToken":"[^"]{10}.*?"'), '"accessToken":"[REDACTED]"')}',
      );
      print(
        'Pending company has token: ${pendingCompany.containsKey('accessToken')}',
      );

      final String? companyToken = pendingCompany['accessToken'];
      if (companyToken != null) {
        print('Pending company token length: ${companyToken.length}');
      } else {
        print('WARNING: Pending company has no token!');
        // If pending company has no token, try to use the user token
        final userToken = storage.read<String>('token');
        if (userToken != null) {
          pendingCompany['accessToken'] = userToken;
          print('Added user token to pending company');
        }
      }

      // Add the company with the stored data
      addCompany(
        pendingCompany['name'],
        pendingCompany['shortName'],
        Color(pendingCompany['color']),
        defaultModule: pendingCompany['defaultModule'],
        companyId: pendingCompany['id'],
        companyToken: pendingCompany['accessToken'],
      );

      // Clear the pending company from storage
      storage.remove('pendingCompany');
    }
  }

  // New: Load companies from storage
  void _loadCompanies() {
    final List<dynamic>? savedCompanies = storage.read<List>('companies');
    if (savedCompanies != null && savedCompanies.isNotEmpty) {
      companies.value = List<Map<String, dynamic>>.from(savedCompanies);

      // Load active company index
      final savedIndex = storage.read<int>('activeCompanyIndex') ?? 0;
      if (savedIndex >= 0 && savedIndex < companies.length) {
        activeCompanyIndex.value = savedIndex;
      } else {
        // Reset index if out of bounds
        activeCompanyIndex.value = 0;
      }
    } else {
      // If no companies found, reset the index
      activeCompanyIndex.value = 0;
    }
  }

  // New: Save companies to storage
  void _saveCompanies() {
    storage.write('companies', companies.toList());
    storage.write('activeCompanyIndex', activeCompanyIndex.value);
  }

  // New method to load accounts from storage
  void _loadAccounts() {
    final List<dynamic>? savedAccounts = storage.read<List>('accounts');
    if (savedAccounts != null && savedAccounts.isNotEmpty) {
      accounts.value = List<Map<String, dynamic>>.from(savedAccounts);

      // Load active account index
      final savedIndex = storage.read<int>('activeAccountIndex') ?? 0;
      if (savedIndex >= 0 && savedIndex < accounts.length) {
        activeAccountIndex.value = savedIndex;
      } else {
        // Reset index if out of bounds
        activeAccountIndex.value = 0;
      }
    } else {
      // If no accounts found, reset the index
      activeAccountIndex.value = 0;
    }
  }

  // Save accounts to storage
  void _saveAccounts() {
    storage.write('accounts', accounts.toList());
    storage.write('activeAccountIndex', activeAccountIndex.value);
  }

  // Method to track user activity in key interactions
  void _updateUserActivity() {
    try {
      // Try to find the SignInController to update activity timestamp
      final signInController = Get.find<SignInController>();
      signInController.updateLastActivityTime();
    } catch (e) {
      // If SignInController is not available, update timestamp in storage directly
      final storage = GetStorage();
      storage.write('lastActiveTime', DateTime.now().millisecondsSinceEpoch);
      print('Activity timestamp updated directly in storage');
    }
  }

  void changePage(int index) {
    if (index < 0 || index > 3) {
      debugPrint('Invalid page index: $index');
      return;
    }

    // Update user activity on page change
    _updateUserActivity();

    selectedIndex.value = index;
    update(['module_content']);

    final moduleInfo = ModuleConfig.getModuleInfo(currentModule.value);
    final pageTitle = _getPageTitle(index);

    debugPrint('Navigation: ${moduleInfo.name} module - $pageTitle page');
  }

  void toggleDrawer() {
    // Update user activity when drawer is opened
    _updateUserActivity();

    // Make sure the scaffold is ready before trying to open the drawer
    if (scaffoldKey.currentState != null &&
        scaffoldKey.currentContext != null &&
        scaffoldKey.currentContext!.mounted) {
      try {
        scaffoldKey.currentState?.openDrawer();
      } catch (e) {
        // If there's still an error, wait a bit and try again
        Future.delayed(const Duration(milliseconds: 100), () {
          if (scaffoldKey.currentState != null &&
              scaffoldKey.currentContext != null &&
              scaffoldKey.currentContext!.mounted) {
            scaffoldKey.currentState?.openDrawer();
          }
        });
      }
    }
  }

  void logout() {
    try {
      // Update companies list in storage before clearing
      _saveCompanies();

      // Clear all app data from storage
      storage.erase();

      // Reset local state
      companies.clear();
      accounts.clear();
      activeCompanyIndex.value = 0;
      activeAccountIndex.value = 0;
      selectedIndex.value = 0;
      currentModule.value = 'lab'; // Reset module to default

      // Keep username for convenience on next login
      final username = storage.read<String>('lastUsername');
      if (username != null) {
        storage.write('lastUsername', username);
      }

      print('All company data removed during logout from MainController');

      Get.snackbar(
        'Logged Out',
        'You have been logged out.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 2, 44, 41),
        colorText: Colors.white,
      );

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error during logout from MainController: $e');
      // Fallback to simple navigation
      Get.offAllNamed('/login');
    }
  }

  void onDrawerItemTap(String title) {
    // Update user activity when drawer item is tapped
    _updateUserActivity();

    Get.back(); // Close drawer first

    if (title == 'QR Code Scanner') {
      showQRScanner();
    } else if (title == 'Barcode Scanner') {
      showBarcodeScanner();
    } else if (title == 'Calculator') {
      showCalculator();
    } else {
      // Handle other menu items
      // Original implementation for other items
    }
  }

  void showQRScanner() {
    // Show QR scanner dialog
    Get.dialog(
      const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: QRScannerView(mode: 'qr'),
      ),
    ).then((result) {
      if (result != null) {
        // Handle the scanned result if needed
        debugPrint('QR scan result: $result');
      }
    });
  }

  void showConfigurationHelp() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "QR Scanner Setup Guide",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHelpSection(
                        "1. Gradle Plugin Version",
                        "Update Android Gradle plugin version in android/build.gradle:\n"
                            "classpath 'com.android.tools.build:gradle:7.0.4'",
                      ),
                      _buildHelpSection(
                        "2. Gradle Wrapper",
                        "Update in android/gradle/wrapper/gradle-wrapper.properties:\n"
                            "distributionUrl=https\\://services.gradle.org/distributions/gradle-7.4-all.zip",
                      ),
                      _buildHelpSection(
                        "3. Android Permissions",
                        "Add to AndroidManifest.xml:\n"
                            "<uses-permission android:name=\"android.permission.CAMERA\" />\n"
                            "<uses-feature android:name=\"android.hardware.camera\" />\n"
                            "<uses-feature android:name=\"android.hardware.camera.autofocus\" />",
                      ),
                      _buildHelpSection(
                        "4. iOS Configuration",
                        "Add to ios/Runner/Info.plist:\n"
                            "<key>NSCameraUsageDescription</key>\n"
                            "<string>This app needs camera access to scan QR codes</string>",
                      ),
                      _buildHelpSection(
                        "5. Alternative Packages",
                        "Consider using alternative packages:\n"
                            "- mobile_scanner: ^3.5.5\n"
                            "- barcode_scan2: ^4.2.4",
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstantColors.labAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("CLOSE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppConstantColors.labAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void showBarcodeScanner() {
    // Show barcode scanner dialog with barcode mode
    Get.dialog(
      const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: QRScannerView(mode: 'barcode'),
      ),
    ).then((result) {
      if (result != null) {
        Get.snackbar(
          'Barcode Detected',
          result,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    });
  }

  void showCalculator() {
    Get.dialog(
      const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: CalculatorView(),
      ),
    );
  }

  // Add a new account to the list
  void addAccount(String name, String email) {
    // Deactivate all existing accounts
    for (var account in accounts) {
      account['isActive'] = false;
    }
    print("Testing");

    print(name);
    print(email);
    // Add the new account and set it as active
    accounts.add({'name': name, 'email': email, 'isActive': true});

    // Update the active account index
    activeAccountIndex.value = accounts.length - 1;

    // Save to storage
    _saveAccounts();

    // Refresh the UI
    accounts.refresh();
  }

  // Switch to a different account
  void switchAccount(int index) {
    if (index < 0 || index >= accounts.length) return;

    // Deactivate all accounts
    for (var account in accounts) {
      account['isActive'] = false;
    }

    // Activate the selected account
    accounts[index]['isActive'] = true;
    activeAccountIndex.value = index;

    // Save to storage
    _saveAccounts();

    // Refresh the UI
    accounts.refresh();
  }

  // Remove an account
  void removeAccount(int index) {
    if (index < 0 || index >= accounts.length) return;

    // Cannot remove the active account
    if (accounts[index]['isActive'] == true) return;

    // Remove the account
    accounts.removeAt(index);

    // Adjust active account index if needed
    if (activeAccountIndex.value > index) {
      activeAccountIndex.value--;
    }

    // Save to storage
    _saveAccounts();

    // Refresh the UI
    accounts.refresh();
  }

  // New: Add a company
  void addCompany(
    String name,
    String shortName,
    Color color, {
    String? defaultModule,
    String? companyId,
    String? companyToken,
  }) {
    // First check if company with same name already exists
    bool exists = false;
    for (var company in companies) {
      if (company['name'] == name) {
        exists = true;
        break;
      }
    }

    if (exists) {
      return;
    }

    // Deactivate all companies
    for (var company in companies) {
      company['isActive'] = false;
    }

    // Add new company as active
    final companyData = {
      'name': name,
      'shortName': shortName,
      'color': color.value,
      'isActive': true,
      // Add token directly in the initial data
      if (companyToken != null && companyToken.isNotEmpty)
        'accessToken': companyToken,
      // Add company ID if provided
      if (companyId != null && companyId.isNotEmpty) 'id': companyId,
      // Add default module if provided
      if (defaultModule != null) 'defaultModule': defaultModule,
    };

    // Log company data for debugging
    print(
      'Company data being added: ${companyData.toString().replaceAll(RegExp(r'"accessToken":"[^"]{10}.*?"'), '"accessToken":"[REDACTED]"')}',
    );

    companies.add(companyData);

    // Update active company index
    activeCompanyIndex.value = companies.length - 1;

    // If default module is provided, switch to it
    if (defaultModule != null) {
      switchModule(defaultModule);
    }

    // Save to storage
    _saveCompanies();

    // Refresh UI
    companies.refresh();

    Get.snackbar(
      "Success",
      "Company '$name' has been added",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // New: Switch to a different company
  void switchCompany(int index) {
    // Update user activity when switching companies
    _updateUserActivity();

    if (index < 0 || index >= companies.length) return;

    // Get the current token before switching
    final currentToken = storage.read<String>('token');
    final Map<String, dynamic> targetCompany = companies[index];

    // Log company token status
    if (targetCompany.containsKey('accessToken')) {
      print(
        'Company has its own token: ${targetCompany['accessToken'].substring(0, 15)}...',
      );
    } else if (currentToken != null) {
      print(
        'Company does not have a token - will use user token: ${currentToken.substring(0, 15)}...',
      );
      // If the company doesn't have its own token, add the current user token
      targetCompany['accessToken'] = currentToken;
    } else {
      print('WARNING: No token available for this company');
    }

    // Deactivate all companies
    for (var company in companies) {
      company['isActive'] = false;
    }

    // Activate selected company
    companies[index]['isActive'] = true;
    activeCompanyIndex.value = index;

    // Log for debugging
    print(
      'Switched to company: ${companies[index]['name']}, ID: ${companies[index]['id']}',
    );
    print(
      'Company token status: ${companies[index].containsKey('accessToken') ? 'Has token' : 'No token'}',
    );

    // Set default module for company if exists
    if (companies[index].containsKey('defaultModule')) {
      switchModule(companies[index]['defaultModule']);
    }

    // Save to storage
    _saveCompanies();

    // Refresh UI
    companies.refresh();

    Get.snackbar(
      "Company Switched",
      "Now using ${companies[index]['name']}",
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppConstantColors.secondaryColor,
      colorText: Colors.white,
    );
  }

  // New: Remove a company
  void removeCompany(int index) {
    if (index < 0 || index >= companies.length) return;

    // Cannot remove the active company if it's the only one
    if (companies.length <= 1) {
      Get.snackbar(
        "Error",
        "Cannot remove the only company",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Get company name before removal
    final companyName = companies[index]['name'];

    // If removing active company, switch to another one first
    if (index == activeCompanyIndex.value) {
      // Switch to previous or next company
      final newIndex = index > 0 ? index - 1 : index + 1;
      switchCompany(newIndex);
    }

    // Remove the company
    companies.removeAt(index);

    // Adjust active company index if needed
    if (activeCompanyIndex.value > index) {
      activeCompanyIndex.value--;
    }

    // Save to storage
    _saveCompanies();

    // Refresh UI
    companies.refresh();

    Get.snackbar(
      "Company Removed",
      "Company '$companyName' has been removed",
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppConstantColors.secondaryColor,
      colorText: Colors.white,
    );
  }

  // Get active company
  Map<String, dynamic> get activeCompany {
    if (companies.isEmpty) {
      return {
        'name': 'No Company',
        'shortName': 'NC',
        'color': Colors.grey.value,
        'isActive': true,
      };
    }
    return companies[activeCompanyIndex.value];
  }

  // Load current module from storage
  void _loadCurrentModule() {
    final savedModule = storage.read<String>('currentModule');
    if (savedModule != null) {
      currentModule.value = savedModule;
    }
  }

  // Save current module to storage
  void _saveCurrentModule() {
    storage.write('currentModule', currentModule.value);
  }

  // Switch to a different module
  void switchModule(String module) {
    if (!ModuleConfig.modules.containsKey(module)) {
      Get.snackbar(
        "Invalid Module",
        "Selected module is not supported",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    selectedIndex.value = 0;
    currentModule.value = module;
    _saveCurrentModule();
    update(['module_content', 'nav_content']);

    Get.snackbar(
      "Module Switched",
      "Now using ${ModuleConfig.getModuleInfo(module).name} module",
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppConstantColors.secondaryColor,
      colorText: Colors.white,
    );
  }

  String _getPageTitle(int index) {
    final moduleInfo = ModuleConfig.getModuleInfo(currentModule.value);
    switch (index) {
      case 0:
        return '${moduleInfo.name} Dashboard';
      case 1:
        return '${moduleInfo.name} Transactions';
      case 2:
        return '${moduleInfo.name} Reports';
      case 3:
        return 'Settings';
      default:
        return 'MediMaster';
    }
  }

  // Get current module
  String get activeModule => currentModule.value;

  Future<void> scanBarcode() async {
    try {
      // Show barcode scanner dialog with barcode mode
      String? result = await Get.dialog<String>(
        const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: QRScannerView(mode: 'barcode'),
        ),
      );

      Get.snackbar(
        'Barcode Scanned',
        'Scanned value: $result',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Scan Error',
        'Error scanning barcode: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<String?> scanQrCode() async {
    String? result;
    await Get.dialog(
      const QRScannerView(mode: 'qr'),
      barrierDismissible: true,
    ).then((value) {
      if (value != null) {
        result = value.toString();
      }
    });
    return result;
  }
}
