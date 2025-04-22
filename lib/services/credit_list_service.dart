import 'dart:developer' as developer;
import 'dart:math';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio show Response;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/credit_list_model.dart';
import '../config/api_config.dart';
import '../utils/jwt_util.dart';

class CreditListService {
  final Dio _dio;
  final GetStorage _storage = Get.find<GetStorage>();

  CreditListService(this._dio) {
    _setupDio();
  }

  String? _getValidToken() {
    try {
      // First try to get company token
      final companies = _storage.read<List>('companies');
      final activeCompanyIndex = _storage.read<int>('activeCompanyIndex') ?? 0;
      String? token;

      if (companies != null &&
          companies.isNotEmpty &&
          activeCompanyIndex < companies.length) {
        final selectedCompany = companies[activeCompanyIndex];
        token = selectedCompany['accessToken'];
      }

      // If no company token, try user token
      token ??= _storage.read<String>('token');

      if (token != null) {
        // Validate token
        final tokenContents = JwtUtil.decodeToken(token);
        if (tokenContents.containsKey('exp')) {
          final int expirationTime = tokenContents['exp'] as int;
          final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          if (currentTime < expirationTime) {
            return token;
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('Error getting valid token: $e');
      return null;
    }
  }

  void _setupDio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    developer.log('[CreditListService] Using base URL: ${ApiConfig.baseUrl}');

    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _getValidToken();
          if (token == null) {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: dio.Response(
                statusCode: 401,
                requestOptions: options,
                data: {'message': 'No valid authentication token found'},
              ),
            );
          }

          options.headers['Authorization'] = 'Bearer $token';
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 401 ||
              (response.data is Map &&
                  (response.data['message']
                          ?.toString()
                          .toLowerCase()
                          .contains('expired') ??
                      false))) {
            throw DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            developer.log('Authentication error - token may be expired');
          } else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            developer.log('Network timeout error: ${error.message}');
          } else {
            developer.log('API error: ${error.message}', error: error);
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<List<CreditListModel>> getCreditList({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      developer.log('Fetching credit list with pagination...');
      developer.log('Page Number: $pageNumber, Page Size: $pageSize');

      final String endpoint =
          '${ApiConfig.creditList}?pageNumber=$pageNumber&pageSize=$pageSize';

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> jsonData = _extractDataFromResponse(response.data);
        return jsonData
            .map((item) =>
                CreditListModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.badResponse,
        message: 'Failed to load credit list - invalid response format',
      );
    } on DioException catch (e) {
      developer.log('DioException in getCreditList', error: e);
      rethrow;
    } catch (e) {
      developer.log('Unexpected error in getCreditList', error: e);
      throw DioException(
        requestOptions: RequestOptions(path: ApiConfig.creditList),
        type: DioExceptionType.unknown,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  List<dynamic> _extractDataFromResponse(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map<String, dynamic>) {
      for (final key in ['data', 'items', 'records']) {
        final value = responseData[key];
        if (value != null) {
          return value is List ? value : [value];
        }
      }
      return [responseData];
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiConfig.creditList),
      type: DioExceptionType.badResponse,
      message: 'Unexpected response format',
    );
  }
}
