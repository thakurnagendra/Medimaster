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
    // Helper function to safely parse numeric values
    double parseNumeric(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('Error parsing value: $value');
          return 0.0;
        }
      }
      return 0.0;
    }

    // Helper function to safely get string values
    String getString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    // Helper function to safely get int values
    int getInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('Error parsing int value: $value');
          return 0;
        }
      }
      if (value is double) return value.toInt();
      return 0;
    }

    // Try different possible field names
    final id = getInt(json['id'] ?? json['Id'] ?? json['ID']);
    final agentName = getString(json['agentName'] ?? json['AgentName'] ?? json['agent_name'] ?? json['AGENT_NAME']);
    final clientId = getInt(json['clientId'] ?? json['ClientId'] ?? json['client_id'] ?? json['CLIENT_ID']);
    final billNo = json['b_BillNo'] ?? json['B_BillNo'] ?? json['bBillNo'] ?? json['BBillNo'] ?? json['billNo'];
    final bBillNo = billNo == null ? '' : billNo.toString();
    
    return AgentBillingSummaryModel(
      id: id,
      agentName: agentName,
      clientId: clientId,
      bBillNo: bBillNo,
      bBasicAmt: parseNumeric(json['b_BasicAmt'] ?? json['B_BasicAmt'] ?? json['bBasicAmt'] ?? json['basicAmt']),
      discount: parseNumeric(json['discount'] ?? json['Discount']),
      bNetAmt: parseNumeric(json['b_NetAmt'] ?? json['B_NetAmt'] ?? json['bNetAmt'] ?? json['netAmt']),
      bRecieptAmt: parseNumeric(json['b_RecieptAmt'] ?? json['B_RecieptAmt'] ?? json['bRecieptAmt'] ?? json['recieptAmt']),
      recieptAmount: parseNumeric(json['recieptAmount'] ?? json['RecieptAmount'] ?? json['RECIEPT_AMOUNT']),
    );
  }

  @override
  String toString() {
    return 'AgentBillingSummaryModel(id: $id, agentName: $agentName, clientId: $clientId, bBillNo: $bBillNo, bBasicAmt: $bBasicAmt, discount: $discount, bNetAmt: $bNetAmt, bRecieptAmt: $bRecieptAmt, recieptAmount: $recieptAmount)';
  }
}
