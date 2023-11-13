import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class AccountInformationPage extends StatelessWidget {
  AccountInformationPage({super.key});

  final SettingsStore settingsStore = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Column(
          children: [
            
          ],
        ),
      ),
    );
  }
}