import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';
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
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Column(
          children: [
            SettingsTile(
              title: 'Account',
              leading: const Icon(Icons.person),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Modular.to.pushNamed('account'),
            ),
            SettingsTile(
              title: 'Discovery Preferences',
              leading: const Icon(Icons.explore),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            SettingsTile(
              title: 'Security',
              leading: const Icon(Icons.security),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            SettingsTile(
              title: 'Notifications',
              leading: const Icon(Icons.notifications),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            SettingsTile(
              title: 'App Preferences',
              leading: const Icon(Icons.colorize),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            SettingsTile(
              title: 'Data',
              leading: const Icon(Icons.analytics),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            SettingsTile(
              title: 'Support',
              leading: const Icon(Icons.contact_support),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            SettingsTile(
              title: 'Log Out',
              leading: const Icon(Icons.logout, color: Colors.red),
              titleStyle: const TextStyle(color: Colors.red),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Modular.to.pop(),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => store.logOut(context),
                          child: const Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
