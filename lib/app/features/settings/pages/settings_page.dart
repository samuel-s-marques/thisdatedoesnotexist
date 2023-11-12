import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/profile/widgets/section_widget.dart';

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
      body: ListView(
        children: [
          SectionWidget(
            title: 'Account Settings',
            content: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text('Change Password'),
                  leading: Icon(Icons.lock_person),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  title: Text('Delete Account'),
                  leading: Icon(Icons.delete),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          SectionWidget(
            title: 'Notification',
            content: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text('Push Notifications'),
                  leading: Icon(Icons.notifications),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  title: Text('E-mail Notifications'),
                  leading: Icon(Icons.email),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          SectionWidget(
            title: 'Security',
            content: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text('Two-Factor Authentication'),
                  leading: Icon(Icons.lock),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  title: Text('Account Linked Services'),
                  leading: Icon(Icons.link),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          SectionWidget(
            title: 'App Preferences',
            content: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text('Language'),
                  leading: Icon(Icons.language),
                  subtitle: Text('English'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  title: Text('Theme'),
                  leading: Icon(Icons.colorize),
                  subtitle: Text('Light'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          SectionWidget(
            title: 'Help and Support',
            content: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text('FAQs'),
                  leading: Icon(Icons.help),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  title: Text('Feedback'),
                  leading: Icon(Icons.feedback),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  title: Text('Contact Support'),
                  leading: Icon(Icons.contact_support),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          SectionWidget(
            title: 'Legal and Terms',
            content: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text('Terms of Service and Privacy Policy'),
                  leading: Icon(Icons.policy),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
