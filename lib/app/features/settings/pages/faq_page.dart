import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class FaqPage extends StatelessWidget {
  FaqPage({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final SettingsStore store = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: formKey,
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Observer(
              builder: (_) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: store.faq.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      store.faq.keys.elementAt(index),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 15),
                        child: Text(
                          store.faq.values.elementAt(index),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
