import 'dart:convert';

/// Utility class for JWT token operations
class JwtUtil {
  /// Decode a JWT token and return the payload as a Map
  static Map<String, dynamic> decodeToken(String token) {
    try {
      // Split the token by dots
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid JWT token format');
        return {};
      }

      // Decode the payload (middle part)
      String normalizedPayload = parts[1];

      // Add padding if needed
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }

      // Base64 decode and convert to JSON
      final payloadBytes = base64Url.decode(normalizedPayload);
      final payloadString = utf8.decode(payloadBytes);
      final payloadJson = jsonDecode(payloadString) as Map<String, dynamic>;

      return payloadJson;
    } catch (e) {
      print('Error decoding token: $e');
      return {};
    }
  }

  /// Extract the school name from a token payload
  static String getSchoolName(String token) {
    final payload = decodeToken(token);
    return payload['Schools_Name'] ?? 'Unknown School';
  }

  /// Extract the school ID from a token payload
  static String getSchoolId(String token) {
    final payload = decodeToken(token);
    return payload['SchoolsId']?.toString() ?? '';
  }

  /// Extract the school type from a token payload
  static String? getSchoolType(String token) {
    final payload = decodeToken(token);
    return payload['SchoolType']?.toString() ??
        payload['school_type']?.toString() ??
        'lab'; // Default to 'lab' if type not found
  }

  /// Generate a short name from a school name (using initials)
  static String generateShortName(String schoolName) {
    if (schoolName.isEmpty) return 'SCH';

    // Extract initials from school name
    final words = schoolName.split(' ');
    final initials =
        words
            .take(3)
            .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
            .join();

    // Ensure it's not empty and max 3 chars
    return initials.isEmpty
        ? 'SCH'
        : initials.substring(0, initials.length > 3 ? 3 : initials.length);
  }
}
