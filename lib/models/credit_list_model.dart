class CreditListModel {
  final int id;
  final String pCode;
  final String pName;
  final int age;
  final String pAddress;
  final String pMobile;
  final double balance;
  final int recCount;
  final bool active;
  final String ageGender;
  final double serviceBillCredit;
  final double pharmacyCredit;
  final double totalCredit;
  final double receipt;
  final double payment;

  CreditListModel({
    required this.id,
    required this.pCode,
    required this.pName,
    required this.age,
    required this.pAddress,
    required this.pMobile,
    required this.balance,
    required this.recCount,
    required this.active,
    required this.ageGender,
    required this.serviceBillCredit,
    required this.pharmacyCredit,
    required this.totalCredit,
    required this.receipt,
    required this.payment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'p_code': pCode,
      'p_Name': pName,
      'age': age,
      'p_address': pAddress,
      'p_mobile': pMobile,
      'balance': balance,
      'recCount': recCount,
      'active': active,
      'ageGender': ageGender,
      'serviceBillCredit': serviceBillCredit,
      'pharmacyCredit': pharmacyCredit,
      'totalCredit': totalCredit,
      'receipt': receipt,
      'payment': payment,
    };
  }

  factory CreditListModel.fromJson(Map<String, dynamic> json) {
    return CreditListModel(
      id: json['id'] as int,
      pCode: json['p_code'] as String,
      pName: json['p_Name'] as String,
      age: json['age'] as int? ?? 0,
      pAddress: json['p_address'] as String? ?? '',
      pMobile: json['p_mobile'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      recCount: json['recCount'] as int? ?? 0,
      active: json['active'] as bool? ?? false,
      ageGender: json['ageGender'] as String? ?? '',
      serviceBillCredit: (json['serviceBillCredit'] as num?)?.toDouble() ?? 0.0,
      pharmacyCredit: (json['pharmacyCredit'] as num?)?.toDouble() ?? 0.0,
      totalCredit: (json['totalCredit'] as num?)?.toDouble() ?? 0.0,
      receipt: (json['receipt'] as num?)?.toDouble() ?? 0.0,
      payment: (json['payment'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
