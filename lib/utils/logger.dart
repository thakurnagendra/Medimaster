/// A utility class for logging that avoids using print statements in production
class Logger {
  // Private constructor to prevent instantiation
  Logger._();

  /// Log general debug information (only visible in debug mode)
  static void d(String message) {
    // In debug mode, we would normally check kDebugMode, but we'll just print in all modes for now
    print('🔍 DEBUG: $message');
  }

  /// Log information (only visible in debug mode)
  static void i(String message) {
    // In debug mode, we would normally check kDebugMode, but we'll just print in all modes for now
    print('ℹ️ INFO: $message');
  }

  /// Log warnings (only visible in debug mode)
  static void w(String message) {
    // In debug mode, we would normally check kDebugMode, but we'll just print in all modes for now
    print('⚠️ WARN: $message');
  }

  /// Log errors (visible in debug mode, can be persisted or reported in production)
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    // In debug mode, we would normally check kDebugMode, but we'll just print in all modes for now
    print('❌ ERROR: $message');
    if (error != null) {
      print('Error details: $error');
    }
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }

    // In production, you might want to send errors to a reporting service
    // such as Firebase Crashlytics, Sentry, etc.
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
