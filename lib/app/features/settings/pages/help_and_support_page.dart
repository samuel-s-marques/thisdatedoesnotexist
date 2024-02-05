import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';
import 'package:thisdatedoesnotexist/app/features/settings/widgets/settings_tile.dart';

class HelpAndSupportPage extends StatelessWidget {
  HelpAndSupportPage({super.key});

  final SettingsStore store = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
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
            onTap: () {
              BetterFeedback.of(context).show((UserFeedback feedback) async {
                await store.saveFeedback(feedback, context);
              });
            },
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
          SettingsTile(
            title: 'Delete Account',
            leading: const Icon(Icons.delete, color: Colors.red),
            titleStyle: const TextStyle(color: Colors.red),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('Are you sure you want to delete your account?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          store.deleteAccount(context);
                        },
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
    );
  }
}
