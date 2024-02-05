import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/settings/store/settings_store.dart';

class AccountStatusPage extends StatelessWidget {
  AccountStatusPage({super.key});

  final SettingsStore store = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Status'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
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
                  if (statusReason != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reason: $statusReason'),
                        const SizedBox(height: 10),
                      ],
                    ),
                  if (statusUntil != null)
                    Column(
                      children: [
                        Text('Until: ${store.dateFormat.format(statusUntil)}'),
                        const SizedBox(height: 10),
                      ],
                    ),
                  const Text('List of reported messages:'),
                  if (status != 'normal' && messages != null && messages.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<dynamic, dynamic> message = messages[index];

                        return ListTile(
                          title: Text(message['content']),
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
