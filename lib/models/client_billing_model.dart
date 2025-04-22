class ClientBillingModel {
  final int id;
  final String agentName;
  final int clientId;
  final String billNo;
  final double basicAmount;
  final double discount;
  final double netAmount;
  final double receiptAmount;
  final double totalReceiptAmount;

  ClientBillingModel({
    required this.id,
    required this.agentName,
    required this.clientId,
    required this.billNo,
    required this.basicAmount,
    required this.discount,
    required this.netAmount,
    required this.receiptAmount,
    required this.totalReceiptAmount,
  });

  factory ClientBillingModel.fromJson(Map<String, dynamic> json) {
    return ClientBillingModel(
      id: json['id'] as int,
      agentName: json['agentName'] as String,
      clientId: json['clientId'] as int,
      billNo: json['b_BillNo'] as String,
      basicAmount: double.parse(json['b_BasicAmt'] as String),
      discount: double.parse(json['discount'] as String),
      netAmount: double.parse(json['b_NetAmt'] as String),
      receiptAmount: double.parse(json['b_RecieptAmt'] as String),
      totalReceiptAmount: double.parse(json['recieptAmount'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentName': agentName,
      'clientId': clientId,
      'b_BillNo': billNo,
      'b_BasicAmt': basicAmount.toStringAsFixed(2),
      'discount': discount.toStringAsFixed(2),
      'b_NetAmt': netAmount.toStringAsFixed(2),
      'b_RecieptAmt': receiptAmount.toStringAsFixed(2),
      'recieptAmount': totalReceiptAmount.toStringAsFixed(2),
    };
  }
}
