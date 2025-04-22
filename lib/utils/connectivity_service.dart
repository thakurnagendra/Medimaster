import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // Initialize connectivity checking
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      isConnected.value = false;
    }
  }

  // Update connection status based on connectivity results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Consider connected if any result indicates connectivity
    isConnected.value = results.any((result) => result != ConnectivityResult.none);
  }

  // Method to check connectivity manually
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    isConnected.value = results.any((result) => result != ConnectivityResult.none);
    return isConnected.value;
  }

  // Show a snackbar when connectivity changes
  void showConnectivitySnackbar() {
    if (!isConnected.value) {
      Get.rawSnackbar(
        message: 'No Internet Connection',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.rawSnackbar(
        message: 'Connected to Internet',
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}