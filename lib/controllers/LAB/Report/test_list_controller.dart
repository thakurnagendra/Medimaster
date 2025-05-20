import 'package:get/get.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:medimaster/models/test_model.dart';

class TestListController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxList<TestModel> testList = <TestModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 20.obs;
  final RxInt totalCount = 0.obs;
  final RxBool hasMoreData = true.obs;

  // Test group filter
  final RxList<String> testGroups = <String>[].obs;
  final RxString selectedTestGroup = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTestList();
  }

  Future<void> fetchTestList({bool isRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    if (isRefresh) {
      currentPage.value = 1;
      testList.clear();
      hasMoreData.value = true;
    }
    try {
      String groupFilter = selectedTestGroup.value.isNotEmpty &&
              selectedTestGroup.value != 'All Test Groups'
          ? '&group=${Uri.encodeComponent(selectedTestGroup.value)}'
          : '';
      final endpoint =
          '${ApiConfig.testList}?pageNumber=${currentPage.value}&pageSize=${pageSize.value}&search=${searchQuery.value}$groupFilter';
      final response = await _apiService.get(endpoint);
      // Expecting response as a list of test objects
      final List<TestModel> fetchedTests = (response as List)
          .map((item) => TestModel.fromJson(item as Map<String, dynamic>))
          .toList();
      if (isRefresh) {
        testList.assignAll(fetchedTests);
      } else {
        testList.addAll(fetchedTests);
      }

      // Apply local filtering based on selected test group as a fallback
      if (selectedTestGroup.value.isNotEmpty &&
          selectedTestGroup.value != 'All Test Groups') {
        testList
            .retainWhere((test) => test.category == selectedTestGroup.value);
      }

      // Apply local filtering based on search query as a fallback
      if (searchQuery.value.isNotEmpty) {
        testList.retainWhere((test) => test.testName
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()));
      }

      totalCount.value = fetchedTests.length;
      hasMoreData.value = fetchedTests.length == pageSize.value;
      // Extract unique test groups from the fetched list
      final groups = <String>{'All Test Groups'};
      for (final t in testList) {
        if (t.category != null && t.category!.isNotEmpty)
          groups.add(t.category!);
      }
      testGroups.assignAll(groups);
    } catch (e) {
      print('Error fetching test list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchTestList(isRefresh: true);
  }

  void onTestGroupChanged(String? group) {
    selectedTestGroup.value = group ?? '';
    fetchTestList(isRefresh: true);
  }

  void loadMore() {
    if (hasMoreData.value && !isLoading.value) {
      currentPage.value++;
      fetchTestList();
    }
  }
}
