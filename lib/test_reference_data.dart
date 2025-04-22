import 'package:medimaster/models/reference_data_model.dart';
import 'package:medimaster/services/test_api_service.dart';

/*
 * This is a test script to verify the ReferenceData model can parse the API response correctly.
 * To run this script, modify your main.dart file temporarily to call testReferenceData() 
 * before initializing the app.
 */
Future<void> testReferenceData() async {
  await TestApiService.testReferenceDataModel();
}

// Sample data from API response
final sampleData = {
  "departments": [
    {
      "id": 3,
      "department_Name": "OPD"
    }
  ],
  "agents": [
    {
      "id": 1,
      "agentName": "sugun"
    },
    {
      "id": 34,
      "agentName": "bulk rate"
    },
    {
      "id": 39,
      "agentName": "H.S. HEALTH CARE PVT. LDT."
    }
  ],
  "doctors": [
    {
      "id": 59,
      "docName": "Dr. Abishekh Ranjan Sah "
    },
    {
      "id": 60,
      "docName": "Dr. Ramkishor Goit"
    },
    {
      "id": 61,
      "docName": "Dr. Lakhan Lal Sah"
    }
  ]
};

// Directly test parsing in code
void manualTest() {
  try {
    final referenceData = ReferenceData.fromJson(sampleData);
    
    print('Manual test results:');
    print('Departments: ${referenceData.departments.length}');
    print('First department: ${referenceData.departments.first.departmentName}');
    print('Agents: ${referenceData.agents.length}');
    print('Doctors: ${referenceData.doctors.length}');
    
    // Verify department name parsing
    final dept = referenceData.departments.first;
    if (dept.departmentName == 'OPD') {
      print('SUCCESS: Department name parsed correctly from department_Name field');
    } else {
      print('ERROR: Department name parsing failed. Expected "OPD", got "${dept.departmentName}"');
    }
  } catch (e) {
    print('Error in manual test: $e');
  }
} 