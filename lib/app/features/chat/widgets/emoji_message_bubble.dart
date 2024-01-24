import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';

class EmojiMessageBubble extends StatelessWidget {
  const EmojiMessageBubble({
    super.key,
    required this.message,
    required this.createdAt,
    required this.from,
    required this.status,
    required this.fontSize,
  });

  final String message;
  final DateTime createdAt;
  final MessageFrom from;
  final MessageStatus status;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
          if (from != MessageFrom.system)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.Hm().format(createdAt.toLocal()),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    if (from == MessageFrom.user)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 5),
                          Icon(
                            status.toIconData(),
                            size: 14,
                          ),
                        ],
                      )
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }
}
