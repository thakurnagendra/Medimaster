import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Print patient details', (WidgetTester tester) async {
    // Create a minimal app for testing
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            // Print the details we want to check
            print('\n=== Patient Details ===');
            print('Investigation ID: 4373');
            print('Patient Name: Mr. Mukesh');
            print('Patient ID: MEDI/0396/P');
            print('Bill Number: MDC/0009/81');
            print('Age: 21');
            print('Sex: M');
            print('Address: Musikot-07 Gulmi');
            print('Mobile: 079412172');
            print('Date: 09/02/2024 17:11:40');
            print('========================\n');
            
            return const SizedBox(); // Empty widget for testing
          },
        ),
      ),
    );
  });
}
