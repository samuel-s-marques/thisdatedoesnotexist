import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/core/models/notification_model.dart';
import 'package:thisdatedoesnotexist/app/features/notification/store/notification_store.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatelessWidget {
  NotificationPage({super.key});

  final NotificationStore store = NotificationStore();

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
                  leading: notification.image != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(notification.image!),
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
