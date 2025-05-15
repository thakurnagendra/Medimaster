import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Print patient record for ID 4373', (WidgetTester tester) async {
    // Create a minimal app for testing
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            // Print the record details
            print('\n=== Patient Record (ID: 4373) ===');
            print('Patient ID (System): 4373');
            print('Patient ID (Medical): MEDI/0399/P');
            print('Patient Name: Mr. DIPENDRA');
            print('Bill Number: MDC/0015/81');
            print('Sample Count: 3');
            print('\nPersonal Information:');
            print('Age: 12');
            print('Sex: M');
            print('Address: Musikot-07 Gulmi');
            print('Mobile: 5646564');
            print('\nDates:');
            print('Visit Date: 09/03/2024 19:18:23');
            print('Nepali Date: 18-05-2081');
            print('========================\n');
            
            return const SizedBox(); // Empty widget for testing
          },
        ),
      ),
    );
  });
}
