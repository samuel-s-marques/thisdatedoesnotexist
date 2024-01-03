import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:thisdatedoesnotexist/app/core/models/notification_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/notification/store/notification_store.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationStore store = Modular.get();

  @override
  void initState() {
    super.initState();

    store.setNotificationState(value: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder(
        future: store.getNotifications(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final List<dynamic> data = snapshot.data['data'];

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final NotificationModel notification = NotificationModel.fromMap(data[index]);

                return ListTile(
                  title: Text(notification.title!),
                  subtitle: notification.subtitle != null ? Text(notification.subtitle!) : null,
                  trailing: Text(timeago.format(notification.updatedAt!, locale: 'en_short')),
                  onTap: () {
                    if (notification.type == 'suspended' || notification.type == 'banned') {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog.fullscreen(
                            child: FutureBuilder(
                              future: store.getReportedMessages(),
                              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  final Map<dynamic, dynamic> data = snapshot.data;
                                  final String status = data['status'];
                                  final String statusReason = data['status_reason'];
                                  final DateTime? statusUntil = data['status_until'] != null ? DateTime.parse(data['status_until']) : null;
                                  final List<dynamic> reportedMessages = data['messages'];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            CloseButton(),
                                          ],
                                        ),
                                        Text(
                                          'We regret to inform you that your account has been ${status == 'suspended' ? 'temporarily suspended' : 'banned'} due to a violation of our community guidelines. Our commitment to maintaining a safe and positive environment for all users requires us to take action against any infractions.',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Reason:'),
                                        Text(statusReason.capitalize()),
                                        const SizedBox(height: 10),
                                        const Text('List of reported messages:'),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: reportedMessages.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final Map<dynamic, dynamic> message = reportedMessages[index];

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
                                        if (statusUntil != null)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              const Text('Your account will be unsuspended on:'),
                                              Text(store.dateFormat.format(statusUntil)),
                                            ],
                                          ),
                                      ],
                                    ),
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                  leading: notification.image != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider('${store.server}/uploads/${notification.image!}'),
                            )
                          ],
                        )
                      : null,
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
