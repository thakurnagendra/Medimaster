import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/api_config.dart';
import '../controllers/auth_controllers/signin_controllers.dart';
import '../utils/jwt_util.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // Network status tracking
  final RxBool isNetworkAvailable = true.obs;
  Timer? _networkRecoveryTimer;

  ApiService._internal() {
    // Start monitoring network status
    _startNetworkMonitoring();
  }

  void _startNetworkMonitoring() {
    // Check network every 30 seconds
    _networkRecoveryTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) {
      _checkNetworkStatus();
    });
  }

  Future<void> _checkNetworkStatus() async {
    try {
      // Simple ping to Google to check connectivity
      final response =
          await http.get(Uri.parse('https://www.google.com')).timeout(
                const Duration(seconds: 5),
                onTimeout: () => http.Response('Timeout', 408),
              );

      final bool previousStatus = isNetworkAvailable.value;
      isNetworkAvailable.value =
          response.statusCode >= 200 && response.statusCode < 400;

      // If network was down but now it's back up
      if (!previousStatus && isNetworkAvailable.value) {
        print('Network connectivity restored');
        // Try to refresh token to maintain session
        _refreshTokenViaController();
      }
    } catch (e) {
      print('Network check failed: $e');
      isNetworkAvailable.value = false;
    }
  }

  // Check network before each request
  Future<bool> _ensureNetworkAvailable() async {
    if (!isNetworkAvailable.value) {
      await _checkNetworkStatus();
    }
    return isNetworkAvailable.value;
  }

  // Common headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Add auth token and selected company token to headers if available
  Map<String, String> _getAuthHeaders() {
    try {
      final GetStorage storage = Get.find<GetStorage>();
      final Map<String, String> headers = {..._headers};

      // Get companies and active index
      final List<dynamic>? companies = storage.read<List>('companies');
      final int activeCompanyIndex =
          storage.read<int>('activeCompanyIndex') ?? 0;

      // Get auth token from active company
      if (companies != null &&
          companies.isNotEmpty &&
          activeCompanyIndex < companies.length) {
        final Map<String, dynamic> selectedCompany =
            companies[activeCompanyIndex];

        // Add the authorization header with the token
        final String? companyToken = selectedCompany['accessToken'];
        if (companyToken != null) {
          headers['Authorization'] = 'Bearer $companyToken';
          print('Using company token for request');
        } else {
          // Fallback to user token if company token is not available
          final String? userToken = storage.read<String>('token');
          if (userToken != null) {
            headers['Authorization'] = 'Bearer $userToken';
            print('Using user token for request (company token missing)');
          } else {
            print('No token available for request');
          }
        }
      } else {
        // If no companies are available, try to use the user token
        final String? userToken = storage.read<String>('token');
        if (userToken != null) {
          headers['Authorization'] = 'Bearer $userToken';
          print('Using user token for request (no companies)');
        }
      }

      return headers;
    } catch (e) {
      print('Error getting auth headers: $e');
      // If GetStorage is not registered yet, use default headers
      return _headers;
    }
  }

  // Generic GET request with retry
  Future<dynamic> get(String endpoint, {int retryCount = 0}) async {
    try {
      // Check network status first
      if (!await _ensureNetworkAvailable()) {
        throw ApiException(
          message: 'No network connection available',
          statusCode: 0,
          isNetworkError: true,
        );
      }

      final headers = _getAuthHeaders();
      print('GET Request to ${ApiConfig.baseUrl}$endpoint');
      print(
        'Headers: ${headers.toString().replaceAll(RegExp(r'Bearer [A-Za-z0-9\._-]+'), 'Bearer [REDACTED]')}',
      );
      print('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: headers);

      // Check for authentication error
      if (response.statusCode == 401 && retryCount < 2) {
        print('Received 401 on GET request, attempting token refresh');
        // Try to refresh token through signin controller
        final refreshResult = await _refreshTokenViaController();
        if (refreshResult) {
          print('Token refreshed successfully, retrying request');
          // Retry the request with new token
          return await get(endpoint, retryCount: retryCount + 1);
        } else {
          print('Token refresh failed, throwing auth error');
          throw ApiException(
            message: 'Authentication failed after token refresh attempt',
            statusCode: 401,
          );
        }
      }

      return _handleResponse(response, endpoint, 'GET', null, retryCount);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('API GET Error: $e');
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Generic POST request with retry
  Future<dynamic> post(
    String endpoint,
    dynamic body, {
    String? token,
    int retryCount = 0,
  }) async {
    try {
      // Check network status first
      if (!await _ensureNetworkAvailable()) {
        throw ApiException(
          message: 'No network connection available',
          statusCode: 0,
          isNetworkError: true,
        );
      }

      Map<String, String> headers = _getAuthHeaders();

      // If a specific token is provided, use it instead of the one from storage
      if (token != null) {
        headers = {..._headers};
        headers['Authorization'] = 'Bearer $token';
      }

      print('POST Request to ${ApiConfig.baseUrl}$endpoint');
      print(
        'Headers: ${headers.toString().replaceAll(RegExp(r'Bearer [A-Za-z0-9\._-]+'), 'Bearer [REDACTED]')}',
      );
      // Only log the body if it's not a sensitive endpoint
      if (!endpoint.contains('login') && !endpoint.contains('refresh')) {
        print('Body: ${jsonEncode(body)}');
      } else {
        print('Body: [REDACTED - SENSITIVE DATA]');
      }

      // For token refresh requests, we need to handle 302 redirects
      bool isTokenRefresh = endpoint.contains('refreshToken');
      http.Response response;

      if (isTokenRefresh) {
        print('Using client with redirect handling for token refresh');
        // For token refresh, use a client that can properly handle redirects
        final client = http.Client();
        try {
          // First, try a normal request but handle 302 responses specially
          response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          );

          // If we got a redirect, check the location header for a token
          if (response.statusCode == 302) {
            final location = response.headers['location'];
            if (location != null) {
              print('Received redirect to: $location');

              // Check if location contains token information
              if (location.contains('token=')) {
                try {
                  final uri = Uri.parse(location);
                  final params = uri.queryParameters;
                  if (params.containsKey('token')) {
                    final newToken = params['token']!;
                    print(
                      'Found token in redirect location. Token length: ${newToken.length}',
                    );

                    // Return token in expected format without throwing an exception
                    return {'accessToken': newToken};
                  }
                } catch (e) {
                  print('Error parsing redirect URI: $e');
                }
              }

              // Try to follow the redirect manually
              try {
                // Determine if it's a relative or absolute URL
                Uri redirectUri;
                if (location.startsWith('http')) {
                  redirectUri = Uri.parse(location);
                } else {
                  // Handle relative URLs
                  final baseUri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
                  redirectUri = baseUri.resolve(location);
                }

                print('Following redirect to: $redirectUri');
                // Follow the redirect with a GET request
                final redirectResponse = await client.get(
                  redirectUri,
                  headers: headers,
                );

                response = redirectResponse;
              } catch (e) {
                print('Error following redirect: $e');
              }
            }
          }
        } finally {
          client.close();
        }
      } else {
        // For regular requests, use the standard approach
        // Enhanced logging for debugging API discrepancies
        final requestUrl = '${ApiConfig.baseUrl}$endpoint';
        final requestBody = jsonEncode(body);

        print('DETAILED REQUEST INFO:');
        print('URL: $requestUrl');
        print(
            'Headers: ${headers.toString().replaceAll(RegExp(r'Bearer [A-Za-z0-9\._-]+'), 'Bearer [REDACTED]')}');
        print('Body: $requestBody');

        response = await http.post(
          Uri.parse(requestUrl),
          headers: headers,
          body: requestBody,
        );

        print('DETAILED RESPONSE INFO:');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        if (response.body.length < 1000) {
          print('Response Body: ${response.body}');
        } else {
          print(
              'Response Body Length: ${response.body.length} characters (too long to print)');
        }
      }

      return _handleResponse(response, endpoint, 'POST', body, retryCount);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Generic PUT request with retry
  Future<dynamic> put(
    String endpoint,
    dynamic body, {
    int retryCount = 0,
  }) async {
    try {
      // Check network status first
      if (!await _ensureNetworkAvailable()) {
        throw ApiException(
          message: 'No network connection available',
          statusCode: 0,
          isNetworkError: true,
        );
      }

      final headers = _getAuthHeaders();
      print('PUT Request to ${ApiConfig.baseUrl}$endpoint');
      print(
        'Headers: ${headers.toString().replaceAll(RegExp(r'Bearer [A-Za-z0-9\._-]+'), 'Bearer [REDACTED]')}',
      );
      print('Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response, endpoint, 'PUT', body, retryCount);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Improved generic DELETE request with retry
  Future<dynamic> delete(String endpoint, {int retryCount = 0}) async {
    try {
      final headers = _getAuthHeaders();
      print('DELETE Request to ${ApiConfig.baseUrl}$endpoint');
      print(
        'Headers: ${headers.toString().replaceAll(RegExp(r'Bearer [A-Za-z0-9\._-]+'), 'Bearer [REDACTED]')}',
      );

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response, endpoint, 'DELETE', null, retryCount);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle API response with retry logic
  dynamic _handleResponse(
    http.Response response,
    String endpoint,
    String method,
    dynamic body,
    int retryCount,
  ) {
    print('API Response Status: ${response.statusCode} for $method $endpoint');

    // Skip printing large responses or sensitive data
    if (endpoint.contains("login") ||
        endpoint.contains("token") ||
        response.body.length > 1000) {
      print(
        'Response body length: ${response.body.length} [Content not logged]',
      );
    } else {
      print('Response body: ${response.body}');
    }

    // Special case: 302 redirects for token refresh attempts - treat as normal error
    // but don't throw exceptions for token refresh endpoint
    if (response.statusCode == 302 && endpoint.contains('refreshToken')) {
      print(
        'Received redirect for token refresh request. This is normal server behavior.',
      );

      // For refresh token endpoints, 302 is potentially a valid response pattern
      // Try to extract token from location header as some servers implement token refresh as a redirect
      final locationHeader = response.headers['location'];
      if (locationHeader != null && locationHeader.contains('token=')) {
        try {
          // Attempt to extract new token from query params
          final uri = Uri.parse(locationHeader);
          final params = uri.queryParameters;
          if (params.containsKey('token')) {
            final newToken = params['token']!;
            print(
              'Found token in redirect location. Token length: ${newToken.length}',
            );

            // Return token in expected format
            return {'accessToken': newToken};
          }
        } catch (e) {
          print('Error parsing redirect location: $e');
        }
      }

      // If token refresh with redirect pattern, return empty response
      // but don't throw an exception
      if (endpoint.contains('refreshToken')) {
        print('Returning empty response for redirect on token refresh');
        return {'redirected': true};
      }
    }

    // Check if response contains HTML instead of JSON (likely a login page or error page)
    if (response.body.trim().toLowerCase().startsWith('<!doctype html>') ||
        response.body.trim().toLowerCase().startsWith('<html')) {
      print('Received HTML response when expecting JSON');

      // Log headers for debugging the redirect
      print('Response headers: ${response.headers}');

      // For token refresh, treat this as a special case
      if (endpoint.contains('refreshToken')) {
        print(
          'HTML response on token refresh - server may be redirecting. Using empty response.',
        );

        // Look for token in headers (sometimes servers include JWT in headers)
        String? newToken;
        if (response.headers.containsKey('authorization')) {
          final authHeader = response.headers['authorization'];
          if (authHeader != null && authHeader.startsWith('Bearer ')) {
            newToken = authHeader.substring(7); // Remove 'Bearer ' prefix
            print('Found token in Authorization header');
          }
        }

        // If token found in headers, return it
        if (newToken != null && newToken.isNotEmpty) {
          return {'accessToken': newToken};
        }

        // If no token in headers, check if current token is still valid
        final storage = Get.find<GetStorage>();
        final currentToken = storage.read<String>('token');

        if (currentToken != null) {
          try {
            // Verify if token is still valid
            final tokenContents = JwtUtil.decodeToken(currentToken);

            if (tokenContents.containsKey('exp')) {
              final expirationTime = tokenContents['exp'] as int;
              final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
              final timeToExpiry = expirationTime - currentTime;

              // If token is still valid for more than 5 minutes
              if (timeToExpiry > 300) {
                print(
                  'Current token is still valid (${timeToExpiry}s remaining). Continuing with session.',
                );
                return {
                  'current_token_valid': true,
                  'accessToken': currentToken,
                };
              }
            }
          } catch (e) {
            print('Error checking token validity: $e');
          }
        }

        return {'html_response': true};
      }

      throw ApiException(
        message:
            'Server returned HTML instead of JSON. Server may be down or redirecting to login page.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 401 && retryCount < 2) {
      // Auth error - try to refresh token and retry
      return _handleAuthError(endpoint, method, body, retryCount);
    }

    // Handle company authorization issues
    if (response.statusCode == 403) {
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        if (errorData['message']?.toString().toLowerCase().contains(
                  'company',
                ) ==
            true) {
          throw ApiException(
            message: errorData['message'] ?? 'Company authorization failed',
            statusCode: 403,
            isCompanyError: true,
          );
        }
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }
        throw ApiException(
          message: 'Company authorization failed',
          statusCode: 403,
          isCompanyError: true,
        );
      }
    }

    if (response.body.isEmpty) {
      // Special case: Empty responses on token refresh with redirect status (302)
      // This is likely the server's way of handling token refresh
      if (response.statusCode == 302 && endpoint.contains('refreshToken')) {
        print(
          'Empty response with redirect for token refresh - special handling',
        );
        return {'redirected': true};
      }

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized: Authentication required',
          statusCode: 401,
        );
      }
      if (response.statusCode == 403) {
        throw ApiException(
          message: 'Forbidden: Company authorization required',
          statusCode: 403,
          isCompanyError: true,
        );
      }
      throw ApiException(
        message: 'Empty response received',
        statusCode: response.statusCode,
      );
    }

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }
      // Handle specific error status codes
      else if (response.statusCode == 401) {
        final errorMsg = data['message'] ??
            data['error'] ??
            'Unauthorized: Authentication failed';
        throw ApiException(message: errorMsg, statusCode: 401);
      } else if (response.statusCode == 403) {
        final errorMsg =
            data['message'] ?? 'Forbidden: Company authorization failed';
        final bool isCompanyError = errorMsg.toLowerCase().contains('company');
        throw ApiException(
          message: errorMsg,
          statusCode: 403,
          isCompanyError: isCompanyError,
        );
      } else if (response.statusCode == 404) {
        final errorMsg = data['message'] ?? 'Resource not found';
        throw ApiException(message: errorMsg, statusCode: 404);
      }
      // Handle other error responses
      else {
        final errorMsg =
            data['message'] ?? data['error'] ?? 'Something went wrong';
        throw ApiException(message: errorMsg, statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to process response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle auth errors with token refresh
  Future<dynamic> _handleAuthError(
    String endpoint,
    String method,
    dynamic body,
    int retryCount,
  ) async {
    print('Handling auth error for $method $endpoint (retry $retryCount)');

    // Try to refresh the token
    final refreshResult = await _refreshTokenViaController();
    if (!refreshResult) {
      throw ApiException(
        message: 'Authentication failed after token refresh attempt',
        statusCode: 401,
      );
    }

    print('Token refreshed successfully, retrying $method request');

    // Retry the original request with the new token
    if (method == 'GET') {
      return await get(endpoint, retryCount: retryCount + 1);
    } else if (method == 'POST') {
      return await post(endpoint, body, retryCount: retryCount + 1);
    } else if (method == 'PUT') {
      return await put(endpoint, body, retryCount: retryCount + 1);
    } else {
      throw ApiException(
        message: 'Unsupported method for retry',
        statusCode: 500,
      );
    }
  }

  // Refresh token via SignInController
  Future<bool> _refreshTokenViaController() async {
    try {
      // Try to find SignInController
      final signInController = Get.find<SignInController>();
      return await signInController.refreshTokenForApiService();
    } catch (e) {
      print('Error finding SignInController: $e');
      // Fall back to our own refresh token implementation
      return await _refreshToken();
    }
  }

  // Improved refresh token method
  Future<bool> _refreshToken() async {
    try {
      final storage = Get.find<GetStorage>();

      // Check network status first
      if (!await _ensureNetworkAvailable()) {
        print(
          'Network not available for token refresh. Will retry when network is restored.',
        );
        return false;
      }

      // Try to get user token and username first
      final String? currentToken = storage.read<String>('token');
      final String? username = storage.read<String>('username');

      if (currentToken != null && username != null) {
        print('Attempting to refresh token directly');

        // Simple headers for refresh request
        final Map<String, String> refreshHeaders = {..._headers};
        refreshHeaders['Authorization'] = 'Bearer $currentToken';

        // Check if the current token is still valid before attempting refresh
        try {
          final tokenContents = JwtUtil.decodeToken(currentToken);
          if (tokenContents.containsKey('exp')) {
            final expirationTime = tokenContents['exp'] as int;
            final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            final timeToExpiry = expirationTime - currentTime;

            // If token is still valid with plenty of time remaining, avoid unnecessary refresh
            if (timeToExpiry > 600) {
              // More than 10 minutes remaining
              print(
                'Current token still has ${timeToExpiry}s remaining. Skipping refresh.',
              );
              return true;
            }

            print(
              'Token has ${timeToExpiry}s remaining. Proceeding with refresh attempt.',
            );
          }
        } catch (e) {
          print('Error checking token expiration: $e');
          // Continue with refresh attempt
        }

        // Attempt refresh with timeout to avoid hanging
        try {
          final response = await http
              .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshToken}'),
            headers: refreshHeaders,
            body: json.encode({
              'username': username,
              'currentToken': currentToken,
            }),
          )
              .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('Token refresh request timed out');
              throw TimeoutException('Token refresh timed out');
            },
          );

          if (response.statusCode >= 200 && response.statusCode < 300) {
            // Handle HTML responses here too
            if (response.body.trim().toLowerCase().startsWith(
                      '<!doctype html>',
                    ) ||
                response.body.trim().toLowerCase().startsWith('<html')) {
              print('Received HTML response on direct token refresh');

              // Check if current token is still valid
              final tokenContents = JwtUtil.decodeToken(currentToken);
              if (tokenContents.containsKey('exp')) {
                final expirationTime = tokenContents['exp'] as int;
                final currentTime =
                    DateTime.now().millisecondsSinceEpoch ~/ 1000;
                if (currentTime < expirationTime) {
                  print(
                    'Current token is still valid. Continuing with session.',
                  );
                  return true;
                }
              }

              return false;
            }

            // Try to parse JSON response
            try {
              final data = json.decode(response.body);
              if (data.containsKey('accessToken')) {
                final newToken = data['accessToken'];

                // Update user token
                storage.write('token', newToken);

                // Also try to update company token
                _updateCompanyToken(newToken);

                print('Token refreshed successfully');
                return true;
              }
            } catch (e) {
              print('Error parsing refresh response: $e');
            }
          } else {
            print(
              'Token refresh failed with status code: ${response.statusCode}',
            );
          }
        } catch (e) {
          print('Error during token refresh HTTP request: $e');
          // If timeout or network error, check if current token is still valid
          if (e is TimeoutException) {
            try {
              final tokenContents = JwtUtil.decodeToken(currentToken);
              if (tokenContents.containsKey('exp')) {
                final expirationTime = tokenContents['exp'] as int;
                final currentTime =
                    DateTime.now().millisecondsSinceEpoch ~/ 1000;
                if (currentTime < expirationTime) {
                  print(
                    'Token refresh timed out but current token is still valid.',
                  );
                  return true;
                }
              }
            } catch (tokenError) {
              print('Error checking token: $tokenError');
            }
          }
        }
      }

      // If we can't refresh with user token, try company refresh token
      final companies = storage.read<List>('companies');
      final activeCompanyIndex = storage.read<int>('activeCompanyIndex') ?? 0;

      if (companies != null &&
          companies.isNotEmpty &&
          activeCompanyIndex < companies.length) {
        final selectedCompany = companies[activeCompanyIndex];
        final refreshToken = selectedCompany['refreshToken'];

        if (refreshToken != null) {
          print('Attempting to refresh with company refresh token');

          final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshToken}'),
            headers: _headers,
            body: json.encode({'refreshToken': refreshToken}),
          );

          if (response.statusCode >= 200 && response.statusCode < 300) {
            final data = json.decode(response.body);
            if (data.containsKey('accessToken')) {
              final newToken = data['accessToken'];

              // Update company token
              companies[activeCompanyIndex]['accessToken'] = newToken;
              storage.write('companies', companies);

              // Also update user token
              storage.write('token', newToken);

              print('Token refreshed successfully with company refresh token');
              return true;
            }
          }
        }
      }

      print('All token refresh attempts failed');
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  // Update company token
  void _updateCompanyToken(String newToken) {
    try {
      final storage = Get.find<GetStorage>();
      final companies = storage.read<List>('companies');
      final activeCompanyIndex = storage.read<int>('activeCompanyIndex') ?? 0;

      if (companies != null &&
          companies.isNotEmpty &&
          activeCompanyIndex < companies.length) {
        final List<dynamic> updatedCompanies = List.from(companies);
        updatedCompanies[activeCompanyIndex] = {
          ...updatedCompanies[activeCompanyIndex] as Map<String, dynamic>,
          'accessToken': newToken,
        };

        storage.write('companies', updatedCompanies);
        print('Company token updated');
      }
    } catch (e) {
      print('Error updating company token: $e');
    }
  }

  // Handle API errors
  dynamic _handleError(dynamic error) {
    if (error is ApiException) {
      throw error;
    }
    throw ApiException(message: 'Network error occurred', statusCode: 500);
  }

  // Method to get the lab report PDF URL
  Future<dynamic> getLabReportPdfUrl(int printId, {int groupId = 0}) async {
    try {
      // For PDF files, we need to use direct http client to get binary data
      final url = Uri.parse(
          '${ApiConfig.baseUrl}/Report/LabReportPdf?id=$printId&groupId=$groupId');
      print('Fetching PDF directly from: $url');

      final headers = _getAuthHeaders();
      // Add specific headers for PDF acceptance
      headers['Accept'] = 'application/pdf';

      try {
        // Try direct HTTP request for binary PDF data
        final http.Response response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          // Check if the content type indicates it's a PDF
          final contentType = response.headers['content-type'] ?? '';
          print('PDF response content type: $contentType');

          if (contentType.contains('application/pdf')) {
            print(
                'Received direct PDF data: ${response.bodyBytes.length} bytes');
            // Return raw PDF bytes
            return response.bodyBytes;
          } else {
            // If not a PDF, it might be JSON or other format, return the string
            print('Received non-PDF response, length: ${response.body.length}');
            return response.body;
          }
        } else {
          print('PDF fetch error: ${response.statusCode} - ${response.body}');
          return null;
        }
      } catch (e) {
        print('Direct PDF download error: $e, falling back to API service');
        // Fall back to standard API get method if direct HTTP fails
        final response = await get(
          '/Report/LabReportPdf?id=$printId&groupId=$groupId',
        );

        print('Fallback API response type: ${response.runtimeType}');
        return response;
      }
    } catch (e) {
      print('Error fetching lab report PDF: $e');
      return null;
    }
  }

  // Get raw PDF data with authenticated HTTP request
  Future<http.Response> getRawPdf(int printId, int groupId) async {
    try {
      // Use Uri.https for secure connection
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.reportPdf}?id=$printId&groupId=$groupId');

      // Get auth headers with token
      final headers = _getAuthHeaders();
      headers['Accept'] = 'application/pdf, application/json';

      print('Making authenticated request for PDF: $url');
      final response = await http.get(url, headers: headers);

      print(
          'Raw PDF response status: ${response.statusCode}, contentType: ${response.headers['content-type']}');
      return response;
    } catch (e) {
      print('Error in raw PDF request: $e');
      // Return an error response
      return http.Response('Request failed: $e', 500);
    }
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final bool isCompanyError;
  final bool isNetworkError;

  ApiException({
    required this.message,
    required this.statusCode,
    this.isCompanyError = false,
    this.isNetworkError = false,
  });

  @override
  String toString() =>
      'ApiException: $message (Status: $statusCode${isCompanyError ? ', Company Error' : ''}${isNetworkError ? ', Network Error' : ''})';
}
