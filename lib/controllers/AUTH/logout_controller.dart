import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../main_controller.dart';

class LogoutController extends GetxController {
  void logout() {
    try {
      final storage = GetStorage();
      
      // Try to find MainController to clear companies directly
      try {
        final mainController = Get.find<MainController>();
        // Clear companies from controller
        mainController.companies.clear();
        mainController.activeCompanyIndex.value = 0;
        print('Companies cleared from MainController');
      } catch (e) {
        print('MainController not found, clearing companies from storage directly');
      }
      
      // Clear all company-related data from storage
      storage.remove('companies');
      storage.remove('activeCompanyIndex');
      storage.remove('pendingCompany');
      
      // Keep username for convenience on next login
      final username = storage.read<String>('username');
      
      // Clear all token and session data
      storage.remove('token');
      storage.remove('refreshToken'); // Explicitly remove refresh token as well
      
      // Remove any other session-related data
      storage.remove('lastActiveTime');
      storage.remove('lastPausedTime');
      
      if (username != null) {
        storage.write('lastUsername', username);
      }
      
      print('All company data and tokens removed during logout');
      
      Get.snackbar(
        'Logged Out',
        'You have been logged out.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF022C29),
        colorText: Colors.white,
      );
      
      Get.offAllNamed('/login'); // Navigate to the login screen
    } catch (e) {
      print('Error during logout: $e');
      // Fallback to simple navigation if error occurs
      Get.offAllNamed('/login');
    }
  }
}
