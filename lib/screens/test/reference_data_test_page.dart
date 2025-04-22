import 'package:flutter/material.dart';
import 'package:medimaster/models/reference_data_model.dart';
import 'package:medimaster/services/test_api_service.dart';

class ReferenceDataTestPage extends StatefulWidget {
  const ReferenceDataTestPage({super.key});

  @override
  State<ReferenceDataTestPage> createState() => _ReferenceDataTestPageState();
}

class _ReferenceDataTestPageState extends State<ReferenceDataTestPage> {
  bool isLoading = true;
  ReferenceData? referenceData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    try {
      final jsonData = await TestApiService.getReferenceData();
      setState(() {
        referenceData = ReferenceData.fromJson(jsonData);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading reference data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reference Data Test'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : _buildReferenceDataDisplay(),
    );
  }

  Widget _buildReferenceDataDisplay() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Departments',
            count: referenceData?.departments.length ?? 0,
            child: _buildDepartmentsList(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Agents',
            count: referenceData?.agents.length ?? 0,
            child: _buildAgentsList(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Doctors',
            count: referenceData?.doctors.length ?? 0,
            child: _buildDoctorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required int count, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDepartmentsList() {
    if (referenceData?.departments.isEmpty ?? true) {
      return const Text('No departments found');
    }

    return Column(
      children: referenceData!.departments.map((dept) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: const Icon(Icons.business, color: Colors.blue),
            ),
            title: Text(dept.departmentName ?? 'Unknown Department'),
            subtitle: Text('ID: ${dept.id}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAgentsList() {
    if (referenceData?.agents.isEmpty ?? true) {
      return const Text('No agents found');
    }

    return Column(
      children: referenceData!.agents.map((agent) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.green),
            ),
            title: Text(agent.agentName),
            subtitle: Text('ID: ${agent.id}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDoctorsList() {
    if (referenceData?.doctors.isEmpty ?? true) {
      return const Text('No doctors found');
    }

    return Column(
      children: referenceData!.doctors.map((doctor) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.2),
              child: const Icon(Icons.medical_services, color: Colors.purple),
            ),
            title: Text(doctor.docName ?? 'Unknown Doctor'),
            subtitle: Text('ID: ${doctor.id}'),
          ),
        );
      }).toList(),
    );
  }
} 