
class ReferenceData {
  final List<Department> departments;
  final List<Agent> agents;
  final List<Doctor> doctors;

  ReferenceData({
    required this.departments,
    required this.agents,
    required this.doctors,
  });

  factory ReferenceData.fromJson(Map<String, dynamic> json) {
    try {
      return ReferenceData(
        departments: (json['departments'] as List?)
                ?.map((e) => Department.fromJson(e))
                .toList() ??
            [],
        agents: (json['agents'] as List?)
                ?.map((e) => Agent.fromJson(e))
                .toList() ??
            [],
        doctors: (json['doctors'] as List?)
                ?.map((e) => Doctor.fromJson(e))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error parsing ReferenceData: $e');
      return ReferenceData(
        departments: [],
        agents: [],
        doctors: [],
      );
    }
  }
}

class Department {
  final int id;
  final String? departmentName;

  Department({
    required this.id,
    this.departmentName,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    try {
      return Department(
        id: json['id'] ?? 0,
        departmentName: json['department_Name'] ?? json['departmentName'] ?? 'Unknown Department',
      );
    } catch (e) {
      print('Error parsing Department: $e');
      return Department(id: 0, departmentName: 'Unknown Department');
    }
  }
}

class Agent {
  final int id;
  final String agentName;

  Agent({
    required this.id,
    required this.agentName,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    try {
      return Agent(
        id: json['id'] ?? 0,
        agentName: json['agentName'] ?? 'Unknown Agent',
      );
    } catch (e) {
      print('Error parsing Agent: $e');
      return Agent(id: 0, agentName: 'Unknown Agent');
    }
  }
}

class Doctor {
  final int id;
  final String? docName;

  Doctor({
    required this.id,
    this.docName,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    try {
      return Doctor(
        id: json['id'] ?? 0,
        docName: json['docName'] ?? 'Unknown Doctor',
      );
    } catch (e) {
      print('Error parsing Doctor: $e');
      return Doctor(id: 0, docName: 'Unknown Doctor');
    }
  }
} 