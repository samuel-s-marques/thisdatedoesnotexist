import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';
import 'package:thisdatedoesnotexist/app/features/settings/widgets/settings_tile.dart';

class SecurityPage extends StatelessWidget {
  SecurityPage({super.key});

  final SettingsStore store = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        children: [
          SettingsTile(
            title: 'Change Password',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          SettingsTile(
            title: 'Change Email',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          SettingsTile(
            title: 'Blocked Characters',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          SettingsTile(
            title: 'Reported Characters',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Modular.to.pushNamed('reported-characters')
          ),
        ],
      ),
    );
  }
}
