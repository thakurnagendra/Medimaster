import 'package:medimaster/models/reference_data_model.dart';

class TestApiService {
  // Simulate the API response with the provided sample data
  static Future<Map<String, dynamic>> getReferenceData() async {
    // Sample data from the user's request
    return {
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
  }

  // Test the model parsing
  static Future<void> testReferenceDataModel() async {
    final jsonData = await getReferenceData();
    
    try {
      final referenceData = ReferenceData.fromJson(jsonData);
      
      print('=================== TEST RESULTS ===================');
      print('Successfully parsed reference data:');
      print('- ${referenceData.departments.length} departments found');
      
      // Print each department
      for (var dept in referenceData.departments) {
        print('  * Department: ID=${dept.id}, Name=${dept.departmentName}');
      }
      
      print('- ${referenceData.agents.length} agents found');
      // Print each agent
      for (var agent in referenceData.agents) {
        print('  * Agent: ID=${agent.id}, Name=${agent.agentName}');
      }
      
      print('- ${referenceData.doctors.length} doctors found');
      // Print each doctor
      for (var doctor in referenceData.doctors) {
        print('  * Doctor: ID=${doctor.id}, Name=${doctor.docName}');
      }
      
      print('====================================================');
    } catch (e) {
      print('Error parsing reference data model: $e');
    }
  }
} 