import 'package:get/get.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/agent_billing_model.dart';
import 'package:medimaster/services/api_service.dart';

class AgentBillingService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<AgentBillingSummary> getAgentBilling({
    int pageNumber = 1,
    int pageSize = 10,
    String? agentId,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      // Add optional filters
      if (agentId != null && agentId.isNotEmpty) {
        queryParams['agentId'] = agentId;
      }
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['fromDate'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['toDate'] = toDate;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // Convert query parameters to URL query string
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      // Make API request
      final response = await _apiService.get(
        '${ApiConfig.getBillingSummary}?$queryString',
      );

      if (response != null) {
        return AgentBillingSummary.fromJson(response);
      }

      // Return empty summary if response is null
      return AgentBillingSummary(
        items: [],
        totalCount: 0,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );
    } catch (e) {
      print('Error fetching agent billing data: $e');
      // Return empty summary on error
      return AgentBillingSummary(
        items: [],
        totalCount: 0,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );
    }
  }

  Future<Map<String, dynamic>> getAgentBillingStatistics({
    String? agentId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};

      // Add optional filters
      if (agentId != null && agentId.isNotEmpty) {
        queryParams['agentId'] = agentId;
      }
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['fromDate'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['toDate'] = toDate;
      }

      // Convert query parameters to URL query string
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      // Make API request
      final response = await _apiService.get(
        '${ApiConfig.billingStatistics}?$queryString',
      );

      if (response != null && response is Map<String, dynamic>) {
        return response;
      }

      return {
        'totalBilling': 0.0,
        'totalCommission': 0.0,
        'totalTests': 0,
        'totalPatients': 0,
      };
    } catch (e) {
      print('Error fetching agent billing statistics: $e');
      return {
        'totalBilling': 0.0,
        'totalCommission': 0.0,
        'totalTests': 0,
        'totalPatients': 0,
      };
    }
  }
}
