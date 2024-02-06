import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';

class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.id,
    required this.name,
    this.message,
    this.draft,
    required this.time,
    this.isTyping = false,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String? message;
  final String? draft;
  final bool isTyping;
  final DateTime time;
  final String avatarUrl;

  String formatDateTime(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(const Duration(days: 1));

    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      // Today
      return DateFormat('HH:mm').format(dateTime.toLocal());
    } else if (dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Other days
      return DateFormat('dd/MM/yyyy').format(dateTime.toLocal());
    }
  }

  Widget? getSubtitle() {
    if (isTyping) {
      return const Text(
        'Typing...',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );
    }

    if (message != null || draft != null) {
      return Text.rich(
        TextSpan(
          children: [
            if (draft != null && draft!.isNotEmpty)
              TextSpan(
                text: 'Draft: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                children: [
                  TextSpan(
                    text: draft,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              )
            else
              TextSpan(text: message)
          ],
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: getSubtitle(),
      trailing: Text(formatDateTime(time)),
      leading: ClipOval(
        child: SizedBox.fromSize(
          size: const Size.fromRadius(24),
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const Icon(Icons.error),
            alignment: Alignment.topCenter,
          ),
        ),
      ),
      onTap: () => Modular.to.pushNamed('/chat/$id'),
    );
  }
}
