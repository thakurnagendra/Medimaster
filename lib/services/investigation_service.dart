import 'package:get/get.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/investigation_model.dart';
import 'package:medimaster/models/investigation_api_response.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class InvestigationService {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = Get.find<GetStorage>();

  // Method to fetch test details by numeric ID
  Future<InvestigationApiResponse> getInvestigationById(String id) async {
    try {
      print('DEBUG: Fetching test details with ID: $id');
      
      // Use the GetTestNameById endpoint
      final response = await _apiService.get('${ApiConfig.getTestNameById}$id');
      print('DEBUG: API Response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        // Create a wrapper response since the API returns direct items
        return InvestigationApiResponse(
          totalCount: 1,
          pageNumber: 1,
          pageSize: 1,
          totalPages: 1,
          hasPreviousPage: false,
          hasNextPage: false,
          items: response.data is List
              ? (response.data as List).map((item) => InvestigationItem.fromJson(item)).toList()
              : [InvestigationItem.fromJson(response.data)],
        );
      }
      
      // Return empty response if no data
      return InvestigationApiResponse(
        totalCount: 0,
        pageNumber: 1,
        pageSize: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false,
        items: [],
      );
    } catch (e) {
      print('Error fetching test details: $e');
      rethrow;
    }
  }

  // Get the active company ID
  String? get _activeCompanyId {
    try {
      final List<dynamic>? companies = _storage.read<List>('companies');
      final int activeIndex = _storage.read<int>('activeCompanyIndex') ?? 0;
      
      if (companies != null && companies.isNotEmpty && activeIndex < companies.length) {
        final Map<String, dynamic> activeCompany = companies[activeIndex];
        final companyId = activeCompany['id']?.toString();
        
        print('Active company for API request: ${activeCompany['name']}, ID: $companyId');
        
        // Check if the company has a token
        if (activeCompany.containsKey('accessToken')) {
          print('Company has its own token available for API requests');
        } else {
          print('Company will use the main user token for API requests');
        }
        
        return companyId;
      }
    } catch (e) {
      print('Error getting active company ID: $e');
    }
    
    // If we get here, no valid company was found
    print('No active company found, API request may use default context');
    return null;
  }

  // Show company access error message
  void _showCompanyError(String message) {
    Get.snackbar(
      'Company Access Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  // Get investigation list with pagination and filters using original model
  Future<InvestigationListResponse> getInvestigationList({
    String status = '',
    String dateFilter = '',
    String searchTerm = '',
    String agent = '',
    String doctorId = '',
    String testFilter = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = {
        'status': status,
        'dateFilter': dateFilter,
        'searchTerm': searchTerm,
        'agent': agent,
        'doctorId': doctorId,
        'testFilter': testFilter,
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      // Add company ID if available - this is important for filtering data by company
      final companyId = _activeCompanyId;
      if (companyId != null && companyId.isNotEmpty) {
        queryParams['companyId'] = companyId;
        print('Added companyId: $companyId to query parameters');
      }

      // Convert query parameters to URL query string
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = '${ApiConfig.getInvestigationList}?$queryString';
      print('Investigation endpoint: $endpoint');
      
      try {
        final response = await _apiService.get(endpoint);
        print(response);
        return InvestigationListResponse.fromJson(response);
      } catch (e) {
        if (e is ApiException && e.isCompanyError) {
          // If it's a company error, show message to user
          _showCompanyError(e.message);
        }
        rethrow;
      }
    } catch (e) {
      // Handle error and return empty response
      print('Error fetching investigation list: $e');
      return InvestigationListResponse(
        data: [],
        totalCount: 0,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalPages: 0,
      );
    }
  }

  // Get investigation list with pagination and filters using new API response model
  Future<InvestigationApiResponse> getInvestigations({
    String status = '',
    String dateFilter = '',
    String searchTerm = '',
    String agent = '',
    String doctorId = '',
    String testFilter = '',
    String fromDate = '',
    String toDate = '',
    int pageNumber = 1,
    int pageSize = 10,
    bool useDefaultCompanyOnError = true,
  }) async {
    try {
      final queryParams = {
        'status': status,
        'dateFilter': dateFilter,
        'searchTerm': searchTerm,
        'agent': agent,
        'doctorId': doctorId,
        'testFilter': testFilter,
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      // Add date range parameters if provided
      if (fromDate.isNotEmpty) {
        queryParams['fromDate'] = fromDate;
      }
      
      if (toDate.isNotEmpty) {
        queryParams['toDate'] = toDate;
      }

      // Log important parameters for debugging
      print('DEBUG: Fetching investigations with filters:');
      print('DEBUG: - Status: "$status"');
      print('DEBUG: - SearchTerm: "$searchTerm"');
      print('DEBUG: - Doctor ID: "$doctorId"');
      print('DEBUG: - Agent: "$agent"');
      print('DEBUG: - From Date: "$fromDate"');
      print('DEBUG: - To Date: "$toDate"');
      print('DEBUG: - Page Number: $pageNumber');
      print('DEBUG: - Page Size: $pageSize');

      // Convert query parameters to URL query string
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = '${ApiConfig.getInvestigationList}?$queryString';
      print('Investigation endpoint: $endpoint');
      
      try {
        final response = await _apiService.get(endpoint);
        return InvestigationApiResponse.fromJson(response);
      } catch (e) {
        if (e is ApiException && e.isCompanyError && useDefaultCompanyOnError) {
          // Show error message
          _showCompanyError('${e.message}. Trying with default company.');
          
          // Try again without company ID (using default)
          final defaultQueryParams = {
            'status': status,
            'dateFilter': dateFilter,
            'searchTerm': searchTerm,
            'agent': agent,
            'doctorId': doctorId,
            'testFilter': testFilter,
            'pageNumber': pageNumber.toString(),
            'pageSize': pageSize.toString(),
          };
          
          // Add date range parameters if provided
          if (fromDate.isNotEmpty) {
            defaultQueryParams['fromDate'] = fromDate;
          }
          
          if (toDate.isNotEmpty) {
            defaultQueryParams['toDate'] = toDate;
          }
          
          final defaultQueryString = defaultQueryParams.entries
              .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
              .join('&');
              
          final defaultEndpoint = '${ApiConfig.getInvestigationList}?$defaultQueryString';
          
          try {
            final fallbackResponse = await _apiService.get(defaultEndpoint);
            return InvestigationApiResponse.fromJson(fallbackResponse);
          } catch (fallbackError) {
            print('Error fetching investigations with default company: $fallbackError');
            rethrow;
          }
        }
        rethrow;
      }
    } catch (e) {
      // Handle error and return empty response
      print('Error fetching investigations: $e');
      return InvestigationApiResponse(
        items: [],
        totalCount: 0,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }
  }
} 