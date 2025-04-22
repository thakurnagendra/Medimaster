import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// A service to handle back button press behavior across the app
class BackButtonService extends GetxService {
  
  // Singleton instance
  static final BackButtonService _instance = BackButtonService._internal();
  factory BackButtonService() => _instance;
  BackButtonService._internal();
  
  // Track if we're already showing a dialog
  final RxBool isDialogShowing = false.obs;
  
  /// Shows a confirmation dialog when user attempts to exit
  /// Returns true if user confirmed exit, false otherwise
  Future<bool> showExitConfirmationDialog({String moduleName = ''}) async {
    // If already showing dialog, don't show another one
    if (isDialogShowing.value) {
      return false;
    }
    
    isDialogShowing.value = true;
    
    try {
      // Get module-specific message
      final String moduleText = _getModuleSpecificText(moduleName);
      
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text(
            'Exit App?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF022C29),
            ),
          ),
          content: Text(
            moduleText,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: const Text('No, Stay'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(result: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A884),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes, Exit'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        barrierDismissible: false, // Prevent dismissing by tapping outside
      );
      
      // If user confirmed exit, close the app
      if (result == true) {
        SystemNavigator.pop(); // This will close the app
        return true;
      }
      return false;
    } finally {
      // Always reset dialog status when done
      isDialogShowing.value = false;
    }
  }
  
  // Get module-specific exit message
  String _getModuleSpecificText(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'lab':
        return 'Do you want to exit the Lab module and close MediMaster app?';
      case 'pharmacy':
        return 'Do you want to exit the Pharmacy module and close MediMaster app?';
      case 'opd':
        return 'Do you want to exit the OPD module and close MediMaster app?';
      case 'ipd':
        return 'Do you want to exit the IPD module and close MediMaster app?';
      case 'accounts':
        return 'Do you want to exit the Accounts module and close MediMaster app?';
      case 'billing':
        return 'Do you want to exit the Billing module and close MediMaster app?';
      case 'settings':
        return 'Do you want to exit Settings and close MediMaster app?';
      default:
        return 'Do you want to exit the MediMaster app?';
    }
  }
}

extension BackButtonExtension on GetInterface {
  BackButtonService get backButton => Get.find<BackButtonService>();
} 