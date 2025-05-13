import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/lab_controller.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class TestListScreen extends StatelessWidget {
  final String billNo;
  final String patientName;

  const TestListScreen({
    Key? key,
    required this.billNo,
    required this.patientName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LabController controller = Get.find<LabController>();

    // Fetch test list when screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTestList(billNo);
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test List',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              patientName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: AppConstantColors.labBackground,
        child: Obx(() {
          if (controller.isLoadingTests.value) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.testList.isEmpty) {
            return Center(
              child: Text(
                'No tests found',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.testList.length,
            itemBuilder: (context, index) {
              final test = controller.testList[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    test.testName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(Icons.medical_services, color: AppConstantColors.labAccent),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
