import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/LAB/lab_controller.dart';

class TestListScreen extends StatelessWidget {
  final String investigationId;
  final String patientName;
  final TextEditingController searchController = TextEditingController();

  TestListScreen({
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test List',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Obx(() {
              final totalTests = controller.testList.length;
              final shownTests = totalTests > 10 ? 10 : totalTests;
              return Text(
                'Showing $shownTests of $totalTests tests',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              );
            }),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Row(
                          children: [
                            Icon(Icons.people_outline, size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'All Test Groups',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                        items: const ['All Test Groups', 'BIOCHEMISTRY TEST', 'IMMUNOLOGY', 'HAEMATOLOGY TEST']
                            .map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              children: [
                                Icon(Icons.people_outline, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Row(
                          children: [
                            Icon(Icons.science_outlined, size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Select Test',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                        items: controller.testList.map((test) {
                          return DropdownMenuItem<String>(
                            value: test.testName,
                            child: Row(
                              children: [
                                Icon(Icons.science_outlined, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  test.testName,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          // Handle test selection
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by test name...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingTests.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.testList.isEmpty) {
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
                  itemCount: controller.testList.length,
                  itemBuilder: (context, index) {
                    final test = controller.testList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  test.testName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Rate',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.science_outlined, 
                                      size: 16, 
                                      color: Colors.blue[700]
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      test.category ?? 'BIOCHEMISTRY TEST',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'NPR ${test.rate ?? '0.00'}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.home_outlined, 
                                  size: 16, 
                                  color: Colors.grey[600]
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  test.type ?? 'InHouse',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
