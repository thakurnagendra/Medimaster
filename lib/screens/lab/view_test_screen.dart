import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/models/view_test_model.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class TestListScreen extends StatefulWidget {
  final String investigationId;
  final String patientName;

  const TestListScreen({
    Key? key,
    required this.investigationId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  final RxList<ViewTestModel> testList = <ViewTestModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    fetchTestList();
  }

  Future<void> fetchTestList() async {
    try {
      isLoading.value = true;
      final response = await _apiService
          .get('${ApiConfig.getTestNameById}${widget.investigationId}');

      if (response is List) {
        testList.value =
            response.map((json) => ViewTestModel.fromJson(json)).toList();
        // Sort the list by testId
        testList.sort((a, b) => a.testId.compareTo(b.testId));
      } else {
        testList.clear();
      }
    } catch (e) {
      print('Error fetching test list: $e');
      testList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstantColors.labBackground,
      appBar: AppBar(
        backgroundColor: AppConstantColors.labBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Test List',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              ' - ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              widget.patientName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (testList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science_outlined,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No tests found',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: testList.length,
          itemBuilder: (context, index) {
            final test = testList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        color: AppConstantColors.labAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      test.testName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
