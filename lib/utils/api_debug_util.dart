import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/send_report_model.dart';
import 'package:medimaster/utils/logger.dart';
import 'package:http/http.dart' as http;

/// Utility class for debugging API requests
class ApiDebugUtil {
  // Private constructor to prevent instantiation
  ApiDebugUtil._();
  
  /// Test the SendReport API with a direct HTTP request to compare with the app's request
  static Future<void> testSendReportApi(SendReportModel reportModel) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Add authorization header if needed
      };
      
      // Add authorization header from the API service
      // This is a simplified version - in a real implementation, you would need to get the actual token
      final storage = Get.find<GetStorage>();
      final String? token = storage.read<String>('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      // Log the request details
      const requestUrl = '${ApiConfig.baseUrl}${ApiConfig.sendReport}';
      final requestBody = jsonEncode(reportModel.toJson());
      
      Logger.i('DIRECT HTTP TEST REQUEST:');
      Logger.i('URL: $requestUrl');
      Logger.i('Headers: ${headers.toString().replaceAll(RegExp(r'Bearer [A-Za-z0-9\._-]+'), 'Bearer [REDACTED]')}');
      Logger.i('Body: $requestBody');
      
      // Make a direct HTTP request
      final response = await http.post(
        Uri.parse(requestUrl),
        headers: headers,
        body: requestBody,
      );
      
      // Log the response
      Logger.i('DIRECT HTTP TEST RESPONSE:');
      Logger.i('Status Code: ${response.statusCode}');
      Logger.i('Response Headers: ${response.headers}');
      if (response.body.length < 1000) {
        Logger.i('Response Body: ${response.body}');
      } else {
        Logger.i('Response Body Length: ${response.body.length} characters (too long to print)');
      }
      
      // Compare with Swagger format
      Logger.i('SWAGGER EQUIVALENT:');
      Logger.i('curl -X POST "$requestUrl" \\');
      Logger.i('  -H "Content-Type: application/json" \\');
      Logger.i('  -H "Accept: application/json" \\');
      Logger.i('  -H "Authorization: Bearer [YOUR_TOKEN]" \\');
      Logger.i('  -d \'$requestBody\'');
      
    } catch (e) {
      Logger.e('Error in testSendReportApi: $e');
    }
  }
}
