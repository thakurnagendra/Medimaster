import 'package:flutter/material.dart';

class AppConstantColors {
  // Private constructor to prevent instantiation
  AppConstantColors._();

  // App Theme Colors
  static const Color primaryColor = Color(0xFF022A50);
  static const Color secondaryColor = Color(0xFF1AB394);
  static const Color background = Color(0xFFE8EBF6);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color grey = Colors.grey;
  static const Color greyLight = Color(0xFFECEFF1);
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Module Colors - Background
  static const Color labBackground = Color(0xFFE8F5E9);
  static const Color pharmacyBackground = Color(0xFFF1F8E9);
  static const Color opdBackground = Color(0xFFFFF8E1);
  static const Color ipdBackground = Color(0xFFFCE4EC);
  static const Color accountsBackground = Color(0xFFE8EAF6);
  static const Color billingBackground = Color(0xFFE3F2FD);

  // Module Colors - Accent
  static const Color labAccent = Color(0xFF2E7D32); // Colors.green.shade700
  static const Color pharmacyAccent = Color(
    0xFF689F38,
  ); // Colors.lightGreen.shade700
  static const Color opdAccent = Color(0xFFFFA000); // Colors.amber.shade700
  static const Color ipdAccent = Color(0xFFC62828); // Colors.red.shade700
  static const Color accountsAccent = Color(
    0xFF303F9F,
  ); // Colors.indigo.shade700
  static const Color billingAccent = Color(0xFF1976D2); // Colors.blue.shade700
  static const Color defaultAccent = Color(
    0xFF455A64,
  ); // Colors.blueGrey.shade700

  // Text Colors
  static const Color textPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Status Colors
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusInactive = Color(0xFFFF5722);
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusCompleted = Color(0xFF2196F3);
}
