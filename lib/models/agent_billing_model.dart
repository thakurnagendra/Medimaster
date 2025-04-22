class BillingHistoryItem {
  final String testId;
  final String patientName;
  final DateTime date;
  final double amount;

  BillingHistoryItem({
    required this.testId,
    required this.patientName,
    required this.date,
    required this.amount,
  });

  factory BillingHistoryItem.fromJson(Map<String, dynamic> json) {
    return BillingHistoryItem(
      testId: json['testId'] as String,
      patientName: json['patientName'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'patientName': patientName,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }
}

class AgentBillingModel {
  final String agentId;
  final String agentName;
  final String? contactNumber;
  final String? email;
  final int totalTests;
  final double totalBilling;
  final double totalAmount;
  final double commission;
  final String status;
  final int totalPatients;
  final List<BillingHistoryItem>? billingHistory;

  AgentBillingModel({
    required this.agentId,
    required this.agentName,
    this.contactNumber,
    this.email,
    required this.totalTests,
    required this.totalBilling,
    required this.totalAmount,
    required this.commission,
    required this.status,
    required this.totalPatients,
    this.billingHistory,
  });

  factory AgentBillingModel.fromJson(Map<String, dynamic> json) {
    return AgentBillingModel(
      agentId: json['agentId'] as String,
      agentName: json['agentName'] as String,
      contactNumber: json['contactNumber'] as String?,
      email: json['email'] as String?,
      totalTests: json['totalTests'] as int,
      totalBilling: (json['totalBilling'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      status: json['status'] as String,
      totalPatients: json['totalPatients'] as int,
      billingHistory: json['billingHistory'] != null
          ? (json['billingHistory'] as List)
              .map((item) => BillingHistoryItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'agentName': agentName,
      'contactNumber': contactNumber,
      'email': email,
      'totalTests': totalTests,
      'totalBilling': totalBilling,
      'totalAmount': totalAmount,
      'commission': commission,
      'status': status,
      'totalPatients': totalPatients,
      'billingHistory': billingHistory?.map((item) => item.toJson()).toList(),
    };
  }
}

class AgentBillingSummary {
  final List<AgentBillingModel> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  AgentBillingSummary({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory AgentBillingSummary.fromJson(Map<String, dynamic> json) {
    return AgentBillingSummary(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => AgentBillingModel.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }
}
