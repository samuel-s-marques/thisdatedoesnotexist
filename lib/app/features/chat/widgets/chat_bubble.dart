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
        'bubbleColor': Colors.grey,
        'textColor': Colors.white,
      },
      MessageType.sender: {
        'alignment': MainAxisAlignment.start,
        'bubbleColor': Colors.white,
        'textColor': Colors.black,
      },
      MessageType.user: {
        'alignment': MainAxisAlignment.end,
        'bubbleColor': Colors.deepPurple,
        'textColor': Colors.white,
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
              color: details[type]!['bubbleColor']!,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              message,
              style: TextStyle(
                color: details[type]!['textColor']!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
