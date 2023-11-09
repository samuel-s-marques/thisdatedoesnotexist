import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final String name;
  final String message;
  final DateTime time;
  final String avatarUrl;

  const ChatListTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(message),
      trailing: Text(time.toString()),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      ),
    );
  }
}
