import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/models/message_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';

class EmojiMessageBubble extends StatelessWidget {
  const EmojiMessageBubble({
    super.key,
    required this.message,
    required this.fontSize,
  });

  final Message message;
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
            message.content,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
          if (message.from != MessageFrom.system)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.Hm().format(message.createdAt!.toLocal()),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    if (message.from == MessageFrom.user)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 5),
                          Icon(
                            message.status!.toIconData(),
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
