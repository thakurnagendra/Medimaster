import 'package:get/get.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/lab_transaction_model.dart';
import 'package:medimaster/services/api_service.dart';

class LabTransactionService {
  final ApiService _apiService = Get.find<ApiService>();

  // Fetch lab transactions with pagination and optional filters
  Future<LabTransactionListResponse> getTransactions({
    int pageNumber = 1,
    int pageSize = 10,
    String dateFilter = '',
    String searchTerm = '',
    String referredBy = '',
    String departmentId = '',
    String agentName = '',
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      // Add optional filters if they are not empty
      if (dateFilter.isNotEmpty) queryParams['dateFilter'] = dateFilter;
      if (searchTerm.isNotEmpty) queryParams['searchText'] = searchTerm;
      if (referredBy.isNotEmpty) queryParams['referredBy'] = referredBy;
      if (departmentId.isNotEmpty) queryParams['departmentId'] = departmentId;
      if (agentName.isNotEmpty) queryParams['agentName'] = agentName;

      // Convert query parameters to URL query string
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      // Make API request
      final response = await _apiService.get(
          '${ApiConfig.getBillingSummary}?$queryString');

      // Parse response into model
      return LabTransactionListResponse.fromJson(response);
    } catch (e) {
      print('Error fetching lab transactions: $e');
      // Return empty response on error
      return LabTransactionListResponse(
        items: [],
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalCount: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }
  }
} 