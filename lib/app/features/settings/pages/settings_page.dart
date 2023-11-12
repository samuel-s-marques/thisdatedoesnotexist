import 'package:flutter/material.dart';

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
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {},
          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 5),
          itemCount: 0,
        ),
      ),
    );
  }
}
