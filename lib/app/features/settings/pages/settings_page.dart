import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/settings/widgets/settings_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Column(
          children: [
            SettingsSection(
              title: 'Account Settings',
              content: [
                ListTile(
                  title: Text('Change Password'),
                  leading: Icon(Icons.lock_person),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: Text('Delete Account'),
                  leading: Icon(Icons.delete),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            SettingsSection(
              title: 'Notification',
              content: [
                ListTile(
                  title: Text('Push Notifications'),
                  leading: Icon(Icons.notifications),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: Text('E-mail Notifications'),
                  leading: Icon(Icons.email),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            SettingsSection(
              title: 'Security',
              content: [
                ListTile(
                  title: Text('Two-Factor Authentication'),
                  leading: Icon(Icons.lock),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: Text('Account Linked Services'),
                  leading: Icon(Icons.link),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            SettingsSection(
              title: 'App Preferences',
              content: [
                ListTile(
                  title: Text('Language'),
                  leading: Icon(Icons.language),
                  subtitle: Text('English'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: Text('Theme'),
                  leading: Icon(Icons.colorize),
                  subtitle: Text('Light'),
                  contentPadding: EdgeInsets.zero,
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: 'Help and Support',
              content: [
                ListTile(
                  title: Text('FAQs'),
                  leading: Icon(Icons.help),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: Text('Feedback'),
                  leading: Icon(Icons.feedback),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: Text('Contact Support'),
                  leading: Icon(Icons.contact_support),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            SettingsSection(
              title: 'Legal and Terms',
              content: [
                ListTile(
                  title: Text('Terms of Service and Privacy Policy'),
                  leading: Icon(Icons.policy),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
