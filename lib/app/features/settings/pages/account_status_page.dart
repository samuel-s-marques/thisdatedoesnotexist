import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class AccountStatusPage extends StatelessWidget {
  AccountStatusPage({super.key});

  final SettingsStore store = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: store.getAccountStatus(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
              final String status = data['status'] as String;
              final String? statusReason = data['status_reason'];
              final DateTime? statusUntil = data['status_until'] != null ? DateTime.parse(data['status_until'] as String) : null;
              final List<dynamic>? messages = data['messages'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Status: $status'),
                  const SizedBox(height: 10),
                  if (statusReason != null) Text('Reason: $statusReason'),
                  if (statusUntil != null) Text('Until: ${store.dateFormat.format(statusUntil)}'),
                  if (status != 'normal' && messages != null && messages.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<dynamic, dynamic> message = messages[index];

                        return ListTile(
                          title: Text(message['message']),
                          subtitle: Text(
                            store.dateFormat.format(
                              DateTime.parse(
                                message['created_at'],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
