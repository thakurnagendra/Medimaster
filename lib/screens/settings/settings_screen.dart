import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/main_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();

    return Container(
      color: const Color(0xFFF5F5F5), // Neutral background for settings
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 20),
              _buildAccountSection(mainController),
              const SizedBox(height: 20),
              _buildPreferencesSection(),
              const SizedBox(height: 20),
              _buildSecuritySection(),
              const SizedBox(height: 20),
              _buildNotificationsSection(),
              const SizedBox(height: 20),
              _buildSupportSection(),
              const SizedBox(height: 20),
              _buildAboutSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(MainController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Obx(() {
              final activeAccount =
                  controller.accounts.isNotEmpty &&
                          controller.activeAccountIndex.value <
                              controller.accounts.length
                      ? controller.accounts[controller.activeAccountIndex.value]
                      : {'name': 'User', 'email': 'user@example.com'};

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    activeAccount['name'].toString()[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  activeAccount['name'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(activeAccount['email'].toString()),
                trailing: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.blue.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit Profile'),
                ),
              );
            }),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () => controller.logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Preferences',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSettingItem(
              'Theme',
              'Light',
              Icons.brightness_6,
              onTap: () {},
            ),
            _buildSettingItem(
              'Language',
              'English',
              Icons.language,
              onTap: () {},
            ),
            _buildSettingItem(
              'Currency',
              'INR (₹)',
              Icons.currency_rupee,
              onTap: () {},
            ),
            _buildSettingItem(
              'Date Format',
              'DD/MM/YYYY',
              Icons.date_range,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Security',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSettingItem(
              'Change Password',
              'Last changed 30 days ago',
              Icons.password,
              onTap: () {},
            ),
            _buildSettingToggleItem(
              'Two-Factor Authentication',
              'Disabled',
              Icons.phonelink_lock,
              isEnabled: false,
              onChanged: (value) {},
            ),
            _buildSettingToggleItem(
              'Biometric Login',
              'Enabled',
              Icons.fingerprint,
              isEnabled: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSettingToggleItem(
              'Push Notifications',
              'Enabled',
              Icons.notifications_active,
              isEnabled: true,
              onChanged: (value) {},
            ),
            _buildSettingToggleItem(
              'Email Notifications',
              'Enabled',
              Icons.email,
              isEnabled: true,
              onChanged: (value) {},
            ),
            _buildSettingToggleItem(
              'SMS Notifications',
              'Disabled',
              Icons.sms,
              isEnabled: false,
              onChanged: (value) {},
            ),
            _buildSettingItem(
              'Notification Preferences',
              'Customize what you receive',
              Icons.tune,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Support',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSettingItem(
              'Help Center',
              'FAQs and user guides',
              Icons.help_center,
              onTap: () {},
            ),
            _buildSettingItem(
              'Contact Support',
              'Get help with issues',
              Icons.contact_support,
              onTap: () {},
            ),
            _buildSettingItem(
              'Report a Bug',
              'Help us improve',
              Icons.bug_report,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSettingItem(
              'App Version',
              'v1.0.0',
              Icons.numbers,
              onTap: () {},
            ),
            _buildSettingItem(
              'Terms of Service',
              'Read our terms',
              Icons.description,
              onTap: () {},
            ),
            _buildSettingItem(
              'Privacy Policy',
              'How we handle your data',
              Icons.privacy_tip,
              onTap: () {},
            ),
            _buildSettingItem(
              'Licenses',
              'Open-source libraries',
              Icons.file_present,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon, {
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSettingToggleItem(
    String title,
    String status,
    IconData icon, {
    required bool isEnabled,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title),
      subtitle: Text(status),
      trailing: Switch(
        value: isEnabled,
        onChanged: onChanged,
        activeColor: Colors.blue.shade700,
      ),
    );
  }
}
