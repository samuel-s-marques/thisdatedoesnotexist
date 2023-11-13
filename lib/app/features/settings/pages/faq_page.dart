import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  FaqPage({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
                ListTile(
                  title: Text('aaaa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
