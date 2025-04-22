import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalSnackbar {
  static void showNetworkError({String? message}) {
    Get.rawSnackbar(
      messageText: Text(
        message ?? 'No internet connection. Please check your network.',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      isDismissible: true,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
      icon: const Icon(Icons.wifi_off, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      snackPosition: SnackPosition.TOP,
    );
  }

  static void showNetworkRestored() {
    Get.rawSnackbar(
      messageText: const Text(
        'Network connection restored',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      isDismissible: true,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      icon: const Icon(Icons.wifi, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      snackPosition: SnackPosition.TOP,
    );
  }
}
