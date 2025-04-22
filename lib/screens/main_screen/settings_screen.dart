import 'package:flutter/material.dart';
import 'package:medimaster/constant/app_constant_colors.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/main_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the MainController to access the current module
    final MainController controller = Get.find<MainController>();

    return Obx(() {
      // Get current module colors
      final String currentModule = controller.currentModule.value;
      final Color moduleBackgroundColor = _getModuleBackgroundColor(
        currentModule,
      );
      final Color moduleAccentColor = _getModuleAccentColor(currentModule);

      return Container(
        color: moduleBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: moduleAccentColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileSection(moduleAccentColor),
                const SizedBox(height: 20),
                _buildGeneralSettings(moduleAccentColor),
                const SizedBox(height: 20),
                _buildNotificationSettings(moduleAccentColor),
                const SizedBox(height: 20),
                _buildSecuritySettings(moduleAccentColor),
                const SizedBox(height: 20),
                _buildAboutSection(moduleAccentColor),
                const SizedBox(height: 20),
                _buildLogoutButton(moduleAccentColor),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Helper methods to get module colors
  Color _getModuleAccentColor(String module) {
    switch (module) {
      case 'lab':
        return AppConstantColors.labAccent;
      case 'pharmacy':
        return AppConstantColors.pharmacyAccent;
      case 'opd':
        return AppConstantColors.opdAccent;
      case 'ipd':
        return AppConstantColors.ipdAccent;
      case 'accounts':
        return AppConstantColors.accountsAccent;
      case 'billing':
        return AppConstantColors.billingAccent;
      default:
        return AppConstantColors.defaultAccent;
    }
  }

  Color _getModuleBackgroundColor(String module) {
    switch (module) {
      case 'lab':
        return AppConstantColors.labBackground;
      case 'pharmacy':
        return AppConstantColors.pharmacyBackground;
      case 'opd':
        return AppConstantColors.opdBackground;
      case 'ipd':
        return AppConstantColors.ipdBackground;
      case 'accounts':
        return AppConstantColors.accountsBackground;
      case 'billing':
        return AppConstantColors.billingBackground;
      default:
        return AppConstantColors.background;
    }
  }

  Widget _buildProfileSection(Color accentColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('Administrator', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: 200, // Fixed width for the button
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(Color accentColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Light',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.access_time,
              title: 'Time Zone',
              subtitle: 'UTC+00:00',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.currency_exchange,
              title: 'Currency',
              subtitle: 'USD',
              accentColor: accentColor,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(Color accentColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications',
              value: true,
              accentColor: accentColor,
              onChanged: (value) {},
            ),
            _buildSwitchItem(
              title: 'Email Notifications',
              subtitle: 'Receive email notifications',
              value: true,
              accentColor: accentColor,
              onChanged: (value) {},
            ),
            _buildSwitchItem(
              title: 'SMS Notifications',
              subtitle: 'Receive SMS notifications',
              value: false,
              accentColor: accentColor,
              onChanged: (value) {},
            ),
            _buildSwitchItem(
              title: 'Appointment Reminders',
              subtitle: 'Get reminded about appointments',
              value: true,
              accentColor: accentColor,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings(Color accentColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.lock,
              title: 'Change Password',
              subtitle: 'Update your password',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint to login',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              subtitle: 'Add an extra layer of security',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.history,
              title: 'Login History',
              subtitle: 'View your login activity',
              accentColor: accentColor,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(Color accentColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.0.0',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.description,
              title: 'Terms of Service',
              subtitle: 'Read our terms and conditions',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'Learn about our privacy practices',
              accentColor: accentColor,
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help with the app',
              accentColor: accentColor,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: accentColor),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(Color accentColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _logoutAndClearData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logoutAndClearData() {
    // Get confirmation from user
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? This will clear all app data.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Close dialog
              Get.back();

              // Get the MainController and call its logout method
              final MainController controller = Get.find<MainController>();
              controller.logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
