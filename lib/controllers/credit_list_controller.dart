import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/credit_list_model.dart';
import '../services/credit_list_service.dart';
import '../utils/jwt_util.dart';
import 'package:get_storage/get_storage.dart';

class CreditListController extends GetxController {
  final RxList<CreditListModel> creditData = <CreditListModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final GetStorage _storage = GetStorage();

  late final CreditListService _creditListService;
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));

  @override
  void onInit() {
    super.onInit();
    _creditListService = CreditListService(_dio);
    _validateAndLoadData();
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }

  Future<bool> _validateToken() async {
    try {
      final token = _storage.read<String>('token');
      if (token == null) return false;

      final tokenContents = JwtUtil.decodeToken(token);
      if (!tokenContents.containsKey('exp')) return false;

      final int expirationTime = tokenContents['exp'] as int;
      final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return currentTime < expirationTime;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  Future<void> _validateAndLoadData() async {
    if (await _validateToken()) {
      loadData();
    } else {
      Get.snackbar(
        'Session Expired',
        'Please log in again',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/login');
    }
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final data = await _creditListService.getCreditList();
      creditData.assignAll(data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          // Only redirect to login if token validation fails
          if (!await _validateToken()) {
            Get.snackbar(
              'Session Expired',
              'Please log in again',
              snackPosition: SnackPosition.BOTTOM,
            );
            Get.offAllNamed('/login');
          }
        } else {
          Get.snackbar(
            'Error',
            'Failed to load data: ${e.message}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load data',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<CreditListModel> get filteredData {
    if (searchQuery.value.isEmpty) return creditData;
    final query = searchQuery.value.toLowerCase();
    return creditData.where((credit) {
      return credit.pName.toLowerCase().contains(query) ||
          credit.pCode.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchQuery.value = '';
  }
}
