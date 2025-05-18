import 'dart:convert';
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
      Logger.i(
          'Sending report with method: ${reportModel.sendMethod} (1=Email, 2=WhatsApp, 3=SMS)');

      // Get a copy of the report model
      SendReportModel formattedModel = reportModel;

      // Handle phone number formatting for WhatsApp and SMS
      if (reportModel.sendMethod == 2 || reportModel.sendMethod == 3) {
        // Format the phone number - ensure it's digits only
        String formattedNumber =
            reportModel.recipientAddress.replaceAll(RegExp(r'\D'), '');

        // Use the formatted number
        formattedModel =
            reportModel.copyWith(recipientAddress: formattedNumber);
      }

      Logger.i('Report data: ${jsonEncode(formattedModel.toJson())}');
      Logger.i('API endpoint: ${ApiConfig.baseUrl}${ApiConfig.sendReport}');

      // Make sure we have a valid report ID
      if (formattedModel.id <= 0) {
        Logger.e('Invalid report ID: ${formattedModel.id}');
        throw Exception('Invalid report ID');
      }

      // Make sure we have a valid send method
      if (formattedModel.sendMethod < 1 || formattedModel.sendMethod > 3) {
        Logger.e('Invalid send method: ${formattedModel.sendMethod}');
        throw Exception('Invalid send method');
      }

      // Send the report with the selected method
      final response = await _apiService.post(
        ApiConfig.sendReport,
        formattedModel.toJson(),
      );

      // Log the response for debugging
      Logger.i(
          'API response received: ${response != null ? jsonEncode(response) : 'null'}');

      // Check if the response indicates success
      if (response != null &&
          (response['success'] == true || response['isSuccess'] == true)) {
        Logger.i('Report sent successfully');
        return true;
      }

      // Handle error response
      String errorMessage = 'Failed to send report';
      if (response != null && response['message'] != null) {
        errorMessage = response['message'].toString();
        Logger.e('API error message: $errorMessage');
      } else if (response != null && response.containsKey('error')) {
        errorMessage = response['error'].toString();
        Logger.e('API error message: $errorMessage');
      }

      Logger.e('Report sending failed: $errorMessage');
      return false;
    } catch (e) {
      // Log the exception
      Logger.e('Exception in sendReport: ${e.toString()}');
      return false;
    }
  }
}
