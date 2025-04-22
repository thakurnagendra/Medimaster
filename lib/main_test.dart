import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/screens/test/reference_data_test_page.dart';
import 'package:medimaster/test_reference_data.dart';

// This is a test main file to verify the reference data model is working correctly
// To use this file, rename it to main.dart temporarily or copy its content to your main.dart

void main() async {
  // First run console tests
  await testReferenceData();
  
  // Also run manual code test
  manualTest();
  
  // Then run the app with the test page
  runApp(const ReferenceDataTestApp());
}

class ReferenceDataTestApp extends StatelessWidget {
  const ReferenceDataTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Reference Data Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ReferenceDataTestPage(),
    );
  }
} 