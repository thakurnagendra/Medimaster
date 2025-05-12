import 'package:get/get.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/send_report_model.dart';
import 'package:medimaster/services/api_service.dart';

class ReportService {
  final ApiService _apiService = Get.find<ApiService>();

  // Send report using the provided model
  Future<bool> sendReport(SendReportModel reportModel) async {
    try {
      final response = await _apiService.post(
        ApiConfig.sendReport,
        reportModel.toJson(),
      );

      // Check if the response indicates success
      if (response != null && (response['success'] == true || response['isSuccess'] == true)) {
        return true;
      }

      // Handle error response
      String errorMessage = 'Failed to send report';
      if (response != null && response['message'] != null) {
        errorMessage = response['message'].toString();
      }

      // Show error message
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );

      return false;
    } catch (e) {
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