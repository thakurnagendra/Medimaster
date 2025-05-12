class ClientBillingDetailModel {
  final String billNo;
  final String date;
  final String miti;
  final String patientName;
  final String patientId;
  final String? mobileNo;
  final String age;
  final String sex;
  final String agentName;
  final String departmentName;
  final String referdBy;
  final String products;
  final double basicAmt;
  final double discount;
  final double netAmt;
  final double recieptAmt;

  ClientBillingDetailModel({
    required this.billNo,
    required this.date,
    required this.miti,
    required this.patientName,
    required this.patientId,
    this.mobileNo,
    required this.age,
    required this.sex,
    required this.agentName,
    required this.departmentName,
    required this.referdBy,
    required this.products,
    required this.basicAmt,
    required this.discount,
    required this.netAmt,
    required this.recieptAmt,
  });

  factory ClientBillingDetailModel.fromJson(Map<String, dynamic> json) {
    return ClientBillingDetailModel(
      billNo: json['billNo'] ?? '',
      date: json['date'] ?? '',
      miti: json['miti'] ?? '',
      patientName: json['patientName'] ?? '',
      patientId: json['patientId'] ?? '',
      mobileNo: json['mobileNo'],
      age: json['age']?.toString() ?? '',
      sex: json['sex'] ?? '',
      agentName: json['agentName'] ?? '',
      departmentName: json['departmentName'] ?? '',
      referdBy: json['referdBy'] ?? '',
      products: json['products'] ?? '',
      basicAmt: (json['basicAmt'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      netAmt: (json['netAmt'] as num?)?.toDouble() ?? 0.0,
      recieptAmt: (json['recieptAmt'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billNo': billNo,
      'date': date,
      'miti': miti,
      'patientName': patientName,
      'patientId': patientId,
      'mobileNo': mobileNo,
      'age': age,
      'sex': sex,
      'agentName': agentName,
      'departmentName': departmentName,
      'referdBy': referdBy,
      'products': products,
      'basicAmt': basicAmt,
      'discount': discount,
      'netAmt': netAmt,
      'recieptAmt': recieptAmt,
    };
  }
} 