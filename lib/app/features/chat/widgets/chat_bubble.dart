import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.type,
    required this.message,
  });

  final MessageType type;
  final String message;

  @override
  Widget build(BuildContext context) {
    final Map<MessageType, Map<String, dynamic>> details = {
      MessageType.system: {
        'alignment': MainAxisAlignment.center,
        'color': Colors.grey,
      },
      MessageType.sender: {
        'alignment': MainAxisAlignment.start,
        'color': Theme.of(context).primaryColor,
      },
      MessageType.user: {
        'alignment': MainAxisAlignment.end,
        'color': Theme.of(context).secondaryHeaderColor,
      },
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: details[type]!['alignment']!,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: details[type]!['color']!,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
