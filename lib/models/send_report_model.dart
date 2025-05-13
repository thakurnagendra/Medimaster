class SendReportModel {
  final int id; // Print ID
  final int sendMethod; // 1 for email, 2 for WhatsApp, 3 for SMS
  final String recipientAddress; // Email, phone number, etc.
  final int designId; // Design ID
  final bool usePatientContact; // Whether to use patient's contact info
  final bool sendToClient; // Whether to send to client
  final bool sendToDoctor; // Whether to send to doctor

  SendReportModel({
    required this.id,
    required this.sendMethod,
    required this.recipientAddress,
    this.designId = 0,
    this.usePatientContact = true,
    this.sendToClient = true,
    this.sendToDoctor = true,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    // Base fields that are always included
    final Map<String, dynamic> json = {
      'id': id,
      'sendMethod': sendMethod,
      'recipientAddress': recipientAddress,
      'designId': designId,
      'usePatientContact': usePatientContact,
      'sendToClient': sendToClient,
      'sendToDoctor': sendToDoctor,
    };
    
    return json;
  }

  // Create a copy with modified fields
  SendReportModel copyWith({
    int? id,
    int? sendMethod,
    String? recipientAddress,
    int? designId,
    bool? usePatientContact,
    bool? sendToClient,
    bool? sendToDoctor,
  }) {
    return SendReportModel(
      id: id ?? this.id,
      sendMethod: sendMethod ?? this.sendMethod,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      designId: designId ?? this.designId,
      usePatientContact: usePatientContact ?? this.usePatientContact,
      sendToClient: sendToClient ?? this.sendToClient,
      sendToDoctor: sendToDoctor ?? this.sendToDoctor,
    );
  }
} 