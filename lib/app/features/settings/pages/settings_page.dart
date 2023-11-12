import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';
import 'package:thisdatedoesnotexist/app/features/settings/widgets/settings_section.dart';
import 'package:thisdatedoesnotexist/app/features/settings/widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsStore store = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Column(
          children: [
            const SettingsSection(
              title: 'Account Settings',
              content: [
                SettingsTile(
                  title: 'Account Information',
                  leading: Icon(Icons.info),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SettingsTile(
                  title: 'Change Password',
                  leading: Icon(Icons.lock_person),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SettingsTile(
                  title: 'Delete Account',
                  leading: Icon(Icons.delete),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SettingsTile(
                  title: 'Log Out',
                  leading: Icon(Icons.logout),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SettingsSection(
              title: 'Notification',
              content: [
                SettingsTile(
                  title: 'Push Notifications',
                  leading: Icon(Icons.notifications),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SettingsTile(
                  title: 'E-mail Notifications',
                  leading: Icon(Icons.email),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SettingsSection(
              title: 'Security',
              content: [
                SettingsTile(
                  title: 'Two-Factor Authentication',
                  leading: Icon(Icons.lock),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SettingsTile(
                  title: 'Account Linked Services',
                  leading: Icon(Icons.link),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            SettingsSection(
              title: 'App Preferences',
              content: [
                const SettingsTile(
                  title: 'Language',
                  leading: Icon(Icons.language),
                  subtitle: 'English',
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SettingsTile(
                  title: 'Theme',
                  leading: const Icon(Icons.colorize),
                  subtitle: 'Light',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SettingsSection(
              title: 'Help and Support',
              content: [
                SettingsTile(
                  title: 'FAQs',
                  leading: Icon(Icons.help),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SettingsTile(
                  title: 'Feedback',
                  leading: Icon(Icons.feedback),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SettingsTile(
                  title: 'Contact Support',
                  leading: Icon(Icons.contact_support),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SettingsSection(
              title: 'Legal and Terms',
              content: [
                SettingsTile(
                  title: 'Terms of Service and Privacy Policy',
                  leading: Icon(Icons.policy),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
