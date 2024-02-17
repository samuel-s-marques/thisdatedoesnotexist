import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thisdatedoesnotexist/app/core/env/env.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

abstract class ReportService {
  Future<void> report({
    required BuildContext context,
    required String characterUid
  });
}

class ReportServiceImpl implements ReportService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = Env.server;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<void> report({
    required BuildContext context,
    required String characterUid,
  }) {
    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Inappropriate content'),
              leading: const Icon(Icons.no_adult_content_outlined),
              onTap: () async => sendReport(
                context: context,
                characterUid: characterUid,
                type: 'inappropriate content',
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Bug'),
              leading: const Icon(Icons.bug_report_outlined),
              onTap: () async => sendReport(
                context: context,
                characterUid: characterUid,
                type: 'bug',
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Other'),
              leading: const Icon(Icons.report_outlined),
              onTap: () {
                Navigator.pop(context);
                final TextEditingController _controller = TextEditingController();

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Report'),
                      actions: [
                        TextButton(
                          onPressed: () async => sendReport(
                            context: context,
                            type: 'other',
                            characterUid: characterUid,
                            description: _controller.text.trim(),
                          ),
                          child: const Text('Send Report'),
                        ),
                      ],
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Please describe the issue:'),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _controller,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Description',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendReport({
    required BuildContext context,
    required String characterUid,
    required String type,
    String? description,
  }) async {
    try {
      final String? userUid = await storage.read(key: 'uid');

      final Return response = await _repository.post('$_server/api/reports', {
        'user_uid': userUid,
        'character_uid': characterUid,
        'type': type,
      });

      if (response.statusCode == 201) {
        context.showSnackBarSuccess(message: 'Report sent successfully');
      } else {
        context.showSnackBarError(message: response.data['error']['details'] ?? 'Something went wrong, please try again later');
      }

      Navigator.pop(context);
    } catch (e) {
      context.showSnackBarError(message: 'Something went wrong, please try again later');
    }
  }
}
