import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/settings/widgets/settings_tile.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        children: [
          SettingsTile(
            title: 'FAQ',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Modular.to.pushNamed('faq'),
          ),
          SettingsTile(
            title: 'Terms of Service',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          SettingsTile(
            title: 'Privacy Policy',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          SettingsTile(
            title: 'Feedback',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          SettingsTile(
            title: 'About us',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          SettingsTile(
            title: 'License',
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
