import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/send_report_model.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:medimaster/utils/logger.dart';

class ReportService {
  final ApiService _apiService = Get.find<ApiService>();

  // Send report using the provided model
  Future<bool> sendReport(SendReportModel reportModel) async {
    try {
      // Log the request details for debugging
      Logger.i('Sending report with method: ${reportModel.sendMethod} (1=Email, 2=WhatsApp, 3=SMS)');
      Logger.i('Report data: ${jsonEncode(reportModel.toJson())}');
      Logger.i('API endpoint: ${ApiConfig.baseUrl}${ApiConfig.sendReport}');
      
      // Since WhatsApp and SMS are not working, automatically convert to Email if those methods are selected
      int actualSendMethod = reportModel.sendMethod;
      String originalMethodName = '';
      
      if (reportModel.sendMethod == 2) { // WhatsApp
        originalMethodName = 'WhatsApp';
        Logger.i('WhatsApp selected, but automatically using Email instead');
        actualSendMethod = 1; // Change to Email
      } else if (reportModel.sendMethod == 3) { // SMS
        originalMethodName = 'SMS';
        Logger.i('SMS selected, but automatically using Email instead');
        actualSendMethod = 1; // Change to Email
      }
      
      // Create the request model - if original method was WhatsApp or SMS, use Email instead
      final SendReportModel requestModel = reportModel.copyWith(
        sendMethod: actualSendMethod
      );
      
      // Send the report
      final response = await _apiService.post(
        ApiConfig.sendReport,
        requestModel.toJson(),
      );

      // Log the response for debugging
      Logger.i('API response received: ${response != null ? jsonEncode(response) : 'null'}');

      // Check if the response indicates success
      if (response != null && (response['success'] == true || response['isSuccess'] == true)) {
        // If we automatically changed the method, show a notification
        if (originalMethodName.isNotEmpty) {
          Get.snackbar(
            'Report Sent via Email',
            '$originalMethodName is not configured on the server. Your report was sent via Email instead.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.amber[100],
            colorText: Colors.amber[900],
            duration: const Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            'Report Sent',
            'Report sent successfully via Email',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[800],
            duration: const Duration(seconds: 3),
          );
        }
        
        Logger.i('Report sent successfully');
        return true;
      }
      
      // Handle error response
      String errorMessage = 'Failed to send report';
      if (response != null && response['message'] != null) {
        errorMessage = response['message'].toString();
        Logger.e('API error message: $errorMessage');
      }
      
      // Show error message
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 5),
      );
      
      return false;
    } catch (e) {
      // Log the exception
      Logger.e('Exception in sendReport: ${e.toString()}');
      
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to send report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return false;
    }
  }
}