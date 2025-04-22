class Investigation {
  final int id;
  final String? patientName;
  final int? patientAge;
  final String? patientSex;
  final String? patientMobile;
  final String? patientAddress;
  final String? referredBy;
  final String? clientName;
  final String? testType;
  final String? date;
  final String? status;
  final String? sampleDate;
  final String? dueDate;
  final String? billingStatus;
  final double? amount;
  final String? testId;

  Investigation({
    required this.id,
    this.patientName,
    this.patientAge,
    this.patientSex,
    this.patientMobile,
    this.patientAddress,
    this.referredBy,
    this.clientName,
    this.testType,
    this.date,
    this.status,
    this.sampleDate,
    this.dueDate,
    this.billingStatus,
    this.amount,
    this.testId,
  });

  factory Investigation.fromJson(Map<String, dynamic> json) {
    return Investigation(
      id: json['id'] ?? 0,
      patientName: json['patientName'],
      patientAge: json['patientAge'],
      patientSex: json['patientSex'],
      patientMobile: json['patientMobile'],
      patientAddress: json['patientAddress'],
      referredBy: json['referredBy'],
      clientName: json['clientName'],
      testType: json['testType'],
      date: json['date'],
      status: json['status'],
      sampleDate: json['sampleDate'],
      dueDate: json['dueDate'],
      billingStatus: json['billingStatus'],
      amount: json['amount']?.toDouble(),
      testId: json['testId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientSex': patientSex,
      'patientMobile': patientMobile,
      'patientAddress': patientAddress,
      'referredBy': referredBy,
      'clientName': clientName,
      'testType': testType,
      'date': date,
      'status': status,
      'sampleDate': sampleDate,
      'dueDate': dueDate,
      'billingStatus': billingStatus,
      'amount': amount,
      'testId': testId,
    };
  }

  // Converting to the format expected by the existing UI
  Map<String, dynamic> toDisplayFormat() {
    return {
      'id': testId ?? id.toString(),
      'patientName': patientName ?? 'Unknown',
      'patientAge': patientAge ?? 0,
      'patientSex': patientSex ?? 'Unknown',
      'patientMobile': patientMobile ?? 'Unknown',
      'patientAddress': patientAddress ?? 'Unknown',
      'referredBy': referredBy ?? 'Unknown',
      'clientName': clientName ?? 'Unknown',
      'testType': testType ?? 'Unknown',
      'date': date ?? DateTime.now().toString().split(' ')[0],
      'bsDate': '', // The API doesn't return BS date, we'll calculate it if needed
      'status': status ?? 'Pending',
    };
  }
}

class InvestigationListResponse {
  final List<Investigation> data;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  InvestigationListResponse({
    required this.data,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory InvestigationListResponse.fromJson(Map<String, dynamic> json) {
    return InvestigationListResponse(
      data: (json['data'] as List?)
              ?.map((item) => Investigation.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
} 