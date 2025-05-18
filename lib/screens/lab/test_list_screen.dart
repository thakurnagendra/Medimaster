import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/LAB/lab_controller.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class TestListScreen extends StatelessWidget {
  final String investigationId;
  final String patientName;

  const TestListScreen({
    Key? key,
    required this.investigationId,
    required this.patientName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LabController controller = Get.find<LabController>();

    // Fetch test list when screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTestList(investigationId);
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Tests for $patientName',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: AppConstantColors.labBackground,
        child: Obx(() {
          if (controller.isLoadingTests.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.testList.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: controller.testList.length,
            itemBuilder: (context, index) {
              final test = controller.testList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppConstantColors.labAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.science_outlined,
                          color: AppConstantColors.labAccent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          test.testName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
