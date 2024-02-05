import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class AccountInformationPage extends StatelessWidget {
  AccountInformationPage({super.key});

  final SettingsStore store = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Wrap(
          runSpacing: 10,
          children: [
            TextField(
              enabled: false,
              controller: TextEditingController(
                text: store.getUser()?.displayName ?? '',
              ),
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              enabled: false,
              controller: TextEditingController(
                text: store.getUser()?.email ?? '',
              ),
              decoration: const InputDecoration(
                labelText: 'E-mail',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
