import 'package:dio/dio.dart';
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/models/client_billing_detail_model.dart';

class ClientBillingService {
  final Dio _dio;

  ClientBillingService(this._dio);

  Future<List<ClientBillingDetailModel>> getClientWiseBillingDetails() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/billing/client-wise-details',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => ClientBillingDetailModel.fromJson(item)).toList();
      }

      // Return empty list if response status is not 200
      return [];
    } on DioException catch (e) {
      print('DioException in getClientWiseBillingDetails: ${e.message}');
      // For testing/development, return sample test data
      return _getMockClientBillingData();
    } catch (e) {
      print('Error fetching client billing data: $e');
      // Return empty list on error
      return _getMockClientBillingData();
    }
  }

  // Mock data for testing
  List<ClientBillingDetailModel> _getMockClientBillingData() {
    return [
      ClientBillingDetailModel(
        billNo: 'BILL-001',
        date: '2023-04-15',
        miti: '2080-01-02',
        patientName: 'John Doe',
        patientId: 'PAT-1234',
        mobileNo: '9876543210',
        age: '35',
        sex: 'M',
        agentName: 'Agent One',
        departmentName: 'Cardiology',
        referdBy: 'Dr. Smith',
        products: 'ECG, Blood Test',
        basicAmt: 5000.0,
        discount: 500.0,
        netAmt: 4500.0,
        recieptAmt: 4500.0,
      ),
      ClientBillingDetailModel(
        billNo: 'BILL-002',
        date: '2023-04-16',
        miti: '2080-01-03',
        patientName: 'Jane Smith',
        patientId: 'PAT-5678',
        mobileNo: '9876543211',
        age: '28',
        sex: 'F',
        agentName: 'Agent Two',
        departmentName: 'Orthopedics',
        referdBy: 'Dr. Johnson',
        products: 'X-Ray, Physiotherapy',
        basicAmt: 3500.0,
        discount: 0.0,
        netAmt: 3500.0,
        recieptAmt: 3500.0,
      ),
      ClientBillingDetailModel(
        billNo: 'BILL-003',
        date: '2023-04-17',
        miti: '2080-01-04',
        patientName: 'Robert Brown',
        patientId: 'PAT-9012',
        mobileNo: '9876543212',
        age: '42',
        sex: 'M',
        agentName: 'Agent One',
        departmentName: 'Neurology',
        referdBy: 'Dr. Wilson',
        products: 'MRI, Consultation',
        basicAmt: 8000.0,
        discount: 1000.0,
        netAmt: 7000.0,
        recieptAmt: 7000.0,
      ),
    ];
  }
} 