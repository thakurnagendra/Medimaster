import 'package:dio/dio.dart';
import 'package:medimaster/models/agent_wise_billing_model.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;

class AgentBillingSummaryService {
  final Dio _dio;
  final _storage = GetStorage();

  AgentBillingSummaryService(this._dio);

  Future<List<AgentBillingSummaryModel>> getAgentBillingSummary() async {
    try {
      // Get the auth token
      final token = _storage.read('token');
      developer.log('Token present: ${token != null}');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Add token to headers
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Log full request details
      developer.log('Making API request:');
      developer.log('URL: ${_dio.options.baseUrl}${ApiConfig.getClientWiseBillings}');
      developer.log('Headers: ${_dio.options.headers}');

      final response = await _dio.get(
        ApiConfig.getClientWiseBillings,
        options: Options(validateStatus: (status) => true),
      );

      // Log response details
      developer.log('Response status code: ${response.statusCode}');
      developer.log('Response headers: ${response.headers}');
      developer.log('Response data type: ${response.data.runtimeType}');
      developer.log('Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data == null) {
          throw Exception('Response data is null');
        }

        if (response.data is! List) {
          developer.log('Unexpected response format. Expected List but got: ${response.data.runtimeType}');
          if (response.data is Map && response.data['data'] is List) {
            developer.log('Found data array in response map');
            final List<dynamic> data = response.data['data'];
            return _parseData(data);
          }
          throw Exception('Unexpected response format');
        }

        final List<dynamic> data = response.data;
        return _parseData(data);
      } else {
        developer.log('Error response: ${response.statusCode} - ${response.statusMessage}');
        developer.log('Error data: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error in getAgentBillingSummary',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow; // Let the UI handle the error
    }
  }

  List<AgentBillingSummaryModel> _parseData(List<dynamic> data) {
    if (data.isEmpty) {
      developer.log('No data returned from API');
      return [];
    }

    developer.log('Parsing ${data.length} items');
    developer.log('First item sample: ${data.first}');
    // Debug bill numbers
    for (var item in data.take(5)) {
      developer.log('Bill number for ${item['agentName']}: ${item['b_BillNo'] ?? item['B_BillNo'] ?? item['bBillNo'] ?? item['BBillNo'] ?? item['billNo'] ?? 'not found'}');
    }

    try {
      return data.map((json) {
        try {
          return AgentBillingSummaryModel.fromJson(json);
        } catch (e, stackTrace) {
          developer.log(
            'Error parsing item: $json',
            error: e,
            stackTrace: stackTrace,
          );
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      developer.log(
        'Error parsing data list',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
