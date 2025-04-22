class ApiConfig {
  // Use UAT environment
  static const String baseUrl = 'https://uat.medimastererp.com/api/mobileapp';
  // For production use:
  // static const String baseUrl = 'https://medimastererp.com/api/mobileapp';

  // Auth endpoints
  static const String login = '/Auth/login';
  static const String refreshToken = '/Auth/refreshToken';

  // Investigation endpoints
  static const String getInvestigationList =
      '/Investigation/GetInvestigationList';

  // Reference data endpoints
  static const String getReferenceData = '/Reference/GetReferenceData';

  // Billing Summary endpoints
  static const String getBillingSummary = '/Lab/GetBillSummary';
  static const String billingTime = '/Lab/GetWeeklyDailyBillingData';
  static const String billingStatistics = '/Lab/GetMitiBillingSummary';

  // Patient endpoints
  static const String creditList = '/Patient/CreditList';
  static const String getClientWiseBillings = '/Lab/GetClientWiseBillings';

  // Add other endpoints here as needed
  // Example:
  // static const String updateProfile = '/User/update';
}
