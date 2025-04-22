class AgentBillingSummaryModel {
  final int id;
  final String agentName;
  final int clientId;
  final String bBillNo;
  final double bBasicAmt;
  final double discount;
  final double bNetAmt;
  final double bRecieptAmt;
  final double recieptAmount;

  AgentBillingSummaryModel({
    required this.id,
    required this.agentName,
    required this.clientId,
    required this.bBillNo,
    required this.bBasicAmt,
    required this.discount,
    required this.bNetAmt,
    required this.bRecieptAmt,
    required this.recieptAmount,
  });

  factory AgentBillingSummaryModel.fromJson(Map<String, dynamic> json) {
    return AgentBillingSummaryModel(
      id: json['id'] as int,
      agentName: json['agentName'] as String,
      clientId: json['clientId'] as int,
      bBillNo: json['b_BillNo'] as String,
      bBasicAmt: double.parse(json['b_BasicAmt'] as String),
      discount: double.parse(json['discount'] as String),
      bNetAmt: double.parse(json['b_NetAmt'] as String),
      bRecieptAmt: double.parse(json['b_RecieptAmt'] as String),
      recieptAmount: double.parse(json['recieptAmount'] as String),
    );
  }
}
