import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Add any settings specific state and methods here
  final RxString userName = 'Dr. Jane Smith'.obs;
  final RxString userRole = 'Administrator'.obs;
  final RxMap<String, bool> notificationPreferences =
      <String, bool>{'email': true, 'push': true, 'sms': false}.obs;
  final RxMap<String, dynamic> securitySettings =
      <String, dynamic>{'twoFactorAuth': false, 'biometricLogin': true}.obs;
  final RxString currentLanguage = 'en'.obs;
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  void updateProfile({String? name, String? role}) {
    if (name != null) userName.value = name;
    if (role != null) userRole.value = role;
  }

  void updateNotificationPreferences(Map<String, bool> preferences) {
    notificationPreferences.addAll(preferences);
  }

  void updateSecuritySettings(Map<String, dynamic> settings) {
    securitySettings.addAll(settings);
  }

  void changeLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));
  }

  void updateTheme(String themeName) {
    switch (themeName) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
    Get.changeThemeMode(themeMode.value);
  }
}
