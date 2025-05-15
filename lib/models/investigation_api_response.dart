class InvestigationApiResponse {
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final List<InvestigationItem> items;

  InvestigationApiResponse({
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.items,
  });

  factory InvestigationApiResponse.fromJson(Map<String, dynamic> json) {
    return InvestigationApiResponse(
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
      items: (json['items'] as List?)
              ?.map((item) => InvestigationItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class InvestigationItem {
  final int id;
  final int bId;
  final String? bPatientId;
  final String? bBillType;
  final String? bBillNo;
  final String? bDate;
  final String? bMiti;
  final String? bTime;
  final String? bName;
  final String? bAddress;
  final String? bMobileNo;
  final String? bSex;
  final String? bAge;
  final String? bMonth;
  final String? bDay;
  final String? bSampleBy;
  final String? bReferdBy;
  final String? bDepartment;
  final String? bEmail;
  final String? bPaymentType;
  final double? bBasicAmt;
  final double? bDiscount;
  final double? bDisPct;
  final double? bAddDiscount;
  final double? bTaxAmt;
  final double? bRecieptAmt;
  final String? bRefundDue;
  final double? bRoundOff;
  final double? bNetAmt;
  final String? agentName;
  final String? agentEmail;
  final String? doctorEmail;
  final String? testGroupIds;
  final String? bRemarks;
  final int printId;
  final int sampleCount;
  final bool edit;
  final String? mode;
  final int isCollected;
  final String? pdfurl;
  final String? verifyer;
  final String? approver;
  final bool? isVerified;
  final bool? isRejected;
  final String? verifyedDate;
  final String? approvedDate;
  final String? reportPerforedBy;
  final int status;
  final String? printUser;
  final String? printCode;
  final String? testGroupName;
  final String? groupId;
  final int testId;
  final int testReportDetailsId;
  final String? performDetails;
  final String? newalyAdded;
  final String? reportApproverDetails;
  final bool sendToWhatsApp;
  final bool sendToEmail;
  final bool notifyToWhatsApp;
  final bool notifyToSms;
  final bool sendToWhatsAppClient;
  final bool sendToEmailClinet;
  final bool notifyToWhatsAppClient;
  final bool notifyToSmsClient;
  final String? reportStatus;
  final int rowNo;
  final int recCount;
  final String? token;

  InvestigationItem({
    required this.id,
    this.bId = 0,
    this.bPatientId,
    this.bBillType,
    this.bBillNo,
    this.bDate,
    this.bMiti,
    this.bTime,
    this.bName,
    this.bAddress,
    this.bMobileNo,
    this.bSex,
    this.bAge,
    this.bMonth,
    this.bDay,
    this.bSampleBy,
    this.bReferdBy,
    this.bDepartment,
    this.bEmail,
    this.bPaymentType,
    this.bBasicAmt,
    this.bDiscount,
    this.bDisPct,
    this.bAddDiscount,
    this.bTaxAmt,
    this.bRecieptAmt,
    this.bRefundDue,
    this.bRoundOff,
    this.bNetAmt,
    this.agentName,
    this.agentEmail,
    this.doctorEmail,
    this.testGroupIds,
    this.bRemarks,
    this.printId = 0,
    this.sampleCount = 0,
    this.edit = false,
    this.mode,
    this.isCollected = 0,
    this.pdfurl,
    this.verifyer,
    this.approver,
    this.isVerified,
    this.isRejected,
    this.verifyedDate,
    this.approvedDate,
    this.reportPerforedBy,
    this.status = 0,
    this.printUser,
    this.printCode,
    this.testGroupName,
    this.groupId,
    this.testId = 0,
    this.testReportDetailsId = 0,
    this.performDetails,
    this.newalyAdded,
    this.reportApproverDetails,
    this.sendToWhatsApp = false,
    this.sendToEmail = false,
    this.notifyToWhatsApp = false,
    this.notifyToSms = false,
    this.sendToWhatsAppClient = false,
    this.sendToEmailClinet = false,
    this.notifyToWhatsAppClient = false,
    this.notifyToSmsClient = false,
    this.reportStatus,
    this.rowNo = 0,
    this.recCount = 0,
    this.token,
  });

  factory InvestigationItem.fromJson(Map<String, dynamic> json) {
    return InvestigationItem(
      id: json['id'] ?? 0,
      bId: json['b_Id'] ?? 0,
      bPatientId: json['b_Patient_Id'],
      bBillType: json['b_BillType'],
      bBillNo: json['b_BillNo'],
      bDate: json['b_Date'],
      bMiti: json['b_Miti'],
      bTime: json['b_Time'],
      bName: json['b_Name'],
      bAddress: json['b_Address'],
      bMobileNo: json['b_MobileNo'],
      bSex: json['b_Sex'],
      bAge: json['b_Age'],
      bMonth: json['b_Month'],
      bDay: json['b_Day'],
      bSampleBy: json['b_SampleBy'],
      bReferdBy: json['b_ReferdBy'],
      bDepartment: json['b_Department'],
      bEmail: json['b_Email'],
      bPaymentType: json['b_PaymentType'],
      bBasicAmt: json['b_BasicAmt']?.toDouble(),
      bDiscount: json['b_Discount']?.toDouble(),
      bDisPct: json['b_DisPct']?.toDouble(),
      bAddDiscount: json['b_Add_Discount']?.toDouble(),
      bTaxAmt: json['b_TaxAmt']?.toDouble(),
      bRecieptAmt: json['b_RecieptAmt']?.toDouble(),
      bRefundDue: json['b_Refund_Due'],
      bRoundOff: json['b_RoundOff']?.toDouble(),
      bNetAmt: json['b_NetAmt']?.toDouble(),
      agentName: json['agentName'],
      agentEmail: json['agentEmail'],
      doctorEmail: json['doctorEmail'],
      testGroupIds: json['testGroupIds'],
      bRemarks: json['b_Remarks'],
      printId: json['printId'] ?? 0,
      sampleCount: json['sampleCount'] ?? 0,
      edit: json['edit'] ?? false,
      mode: json['mode'],
      isCollected: json['isCollected'] ?? 0,
      pdfurl: json['pdfurl'],
      verifyer: json['verifyer'],
      approver: json['approver'],
      isVerified: json['isVerified'],
      isRejected: json['isRejected'],
      verifyedDate: json['verifyedDate'],
      approvedDate: json['approvedDate'],
      reportPerforedBy: json['reportPerforedBy'],
      status: json['status'] ?? 0,
      printUser: json['printUser'],
      printCode: json['printCode'],
      testGroupName: json['testGroup_Name'],
      groupId: json['groupId'],
      testId: json['test_Id'] ?? 0,
      testReportDetailsId: json['testReportDetailsId'] ?? 0,
      performDetails: json['performDetails'],
      newalyAdded: json['newalyAdded'],
      reportApproverDetails: json['reportApproverDetails'],
      sendToWhatsApp: json['sendToWhatsApp'] ?? false,
      sendToEmail: json['sendToEmail'] ?? false,
      notifyToWhatsApp: json['notifyToWhatsApp'] ?? false,
      notifyToSms: json['notifyToSms'] ?? false,
      sendToWhatsAppClient: json['sendToWhatsAppClient'] ?? false,
      sendToEmailClinet: json['sendToEmailClinet'] ?? false,
      notifyToWhatsAppClient: json['notifyToWhatsAppClient'] ?? false,
      notifyToSmsClient: json['notifyToSmsClient'] ?? false,
      reportStatus: json['reportStatus'],
      rowNo: json['rowNo'] ?? 0,
      recCount: json['recCount'] ?? 0,
      token: json['token'],
    );
  }

  // Convert to the format expected by the existing UI
  Map<String, dynamic> toDisplayFormat() {
    return {
      'id': id.toString(),
      'b_BillNo': bBillNo,
      'patientName': bName ?? 'Unknown',
      'patientAge': bAge != null ? int.tryParse(bAge!) ?? 0 : 0,
      'patientSex': bSex ?? 'Unknown',
      'patientMobile': bMobileNo ?? 'Unknown',
      'patientAddress': bAddress ?? 'Unknown',
      'referredBy': bReferdBy ?? 'Unknown',
      'clientName': agentName ?? 'Unknown',
      'testType': testGroupName ?? 'Unknown',
      'date': bDate ?? DateTime.now().toString().split(' ')[0],
      'bsDate': bMiti ?? '',
      'status': getStatusString(),
      'printId': printId,
    };
  }

  // Convert status code to readable string
  String getStatusString() {
    // Debug the status code
    print(
        'Converting status code: $status to string, reportStatus: $reportStatus');

    // Status codes based on API documentation (corrected based on testing)
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'In Progress';
      case 2:
        return 'Completed';
      case 3:
        return 'Canceled';
      default:
        // Check reportStatus as fallback if available
        if (reportStatus != null && reportStatus!.isNotEmpty) {
          print('Using reportStatus: $reportStatus');
          return reportStatus!;
        }
        // Default status based on numeric code
        print('Using fallback status mapping for code: $status');
        if (status == 2) {
          return 'Completed';
        } else if (status == 0) {
          return 'Pending';
        } else if (status == 1) {
          return 'In Progress';
        } else if (status == 3) {
          return 'Canceled';
        }
        return 'Pending';
    }
  }
}
