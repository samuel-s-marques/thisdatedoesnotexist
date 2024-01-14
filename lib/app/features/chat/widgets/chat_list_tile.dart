import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.id,
    required this.name,
    this.message,
    this.draft,
    required this.time,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String? message;
  final String? draft;
  final DateTime time;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: (message != null || draft != null)
          ? Text.rich(
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
                          )
                        ),
                      ],
                    )
                  else
                    TextSpan(text: message)
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          : null,
      trailing: Text(timeago.format(time, locale: 'en_short')),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      ),
      onTap: () => Modular.to.pushNamed('/chat/$id'),
    );
  }
}
