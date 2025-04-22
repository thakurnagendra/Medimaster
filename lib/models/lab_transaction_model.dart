class LabTransaction {
  final int id;
  final String billNo;
  final String date;
  final String miti;
  final String patientId;
  final String patientName;
  final String address;
  final String mobileNo;
  final String age;
  final String sex;
  final String ageType;
  final String bBillType;
  final String departmentName;
  final String? referdBy;
  final double basicAmt;
  final double discount;
  final double disPct;
  final double netAmt;
  final String remarks;
  final double refundDue;
  final double recieptAmt;
  final String? agentName;
  final String? collectionCenter;
  final String products;
  final String entUser;

  LabTransaction({
    required this.id,
    required this.billNo,
    required this.date,
    required this.miti,
    required this.patientId,
    required this.patientName,
    required this.address,
    required this.mobileNo,
    required this.age,
    required this.sex,
    required this.ageType,
    required this.bBillType,
    required this.departmentName,
    this.referdBy,
    required this.basicAmt,
    required this.discount,
    required this.disPct,
    required this.netAmt,
    required this.remarks,
    required this.refundDue,
    required this.recieptAmt,
    this.agentName,
    this.collectionCenter,
    required this.products,
    required this.entUser,
  });

  factory LabTransaction.fromJson(Map<String, dynamic> json) {
    return LabTransaction(
      id: json['id'] ?? 0,
      billNo: json['bill_No'] ?? '',
      date: json['date'] ?? '',
      miti: json['miti'] ?? '',
      patientId: json['patient_Id'] ?? '',
      patientName: json['patient_Name'] ?? '',
      address: json['address'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      age: json['age']?.toString() ?? '',
      sex: json['sex'] ?? '',
      ageType: json['ageType'] ?? '',
      bBillType: json['b_BillType'] ?? '',
      departmentName: json['department_Name'] ?? '',
      referdBy: json['referdBy'],
      basicAmt: (json['basicAmt'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      disPct: (json['disPct'] ?? 0).toDouble(),
      netAmt: (json['netAmt'] ?? 0).toDouble(),
      remarks: json['remarks'] ?? '',
      refundDue: (json['refund_Due'] ?? 0).toDouble(),
      recieptAmt: (json['recieptAmt'] ?? 0).toDouble(),
      agentName: json['agentName'],
      collectionCenter: json['collectionCenter'],
      products: json['products'] ?? '',
      entUser: json['ent_User'] ?? '',
    );
  }

  // Convert to display format for UI
  Map<String, dynamic> toDisplayFormat() {
    return {
      'id': id.toString(),
      'billNumber': billNo,
      'billDate': date,
      'bsDate': miti,
      'patientId': patientId,
      'patientName': patientName,
      'patientAge': age,
      'patientSex': sex,
      'mobile': mobileNo,
      'address': address,
      'testType': products,
      'amount': 'NPR ${netAmt.toStringAsFixed(2)}',
      'date': date,
      'status': getStatusFromBillType(bBillType),
      'statusColor': getStatusColorFromBillType(bBillType),
      'referredBy': referdBy ?? 'Not specified',
      'clientName': departmentName,
      'user': entUser,
    };
  }

  // Helper method to determine status from bill type
  String getStatusFromBillType(String billType) {
    switch (billType) {
      case 'T':
        return 'Completed';
      case 'G':
        return 'Pending';
      default:
        return 'Processing';
    }
  }

  // Helper method to determine status color from bill type
  // This returns a string that will be converted to a Color in the UI
  String getStatusColorFromBillType(String billType) {
    switch (billType) {
      case 'T':
        return 'green';
      case 'G':
        return 'orange';
      default:
        return 'blue';
    }
  }
}

class LabTransactionListResponse {
  final List<LabTransaction> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  LabTransactionListResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory LabTransactionListResponse.fromJson(Map<String, dynamic> json) {
    return LabTransactionListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => LabTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
} 