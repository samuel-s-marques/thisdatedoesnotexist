import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/audio_message_bubble.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/emoji_message_bubble.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/text_message_bubble.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.from,
    required this.type,
    required this.message,
    required this.createdAt,
    this.status,
    this.bubbleColor,
    this.textColor,
    this.linkColor,
  });

  final MessageFrom from;
  final MessageType type;
  final String message;
  final DateTime createdAt;
  final MessageStatus? status;
  final Color? bubbleColor;
  final Color? textColor;
  final Color? linkColor;

  @override
  Widget build(BuildContext context) {
    final Map<MessageFrom, Map<String, dynamic>> details = {
      MessageFrom.system: {
        'alignment': MainAxisAlignment.center,
        'bubbleColor': bubbleColor ?? Colors.grey,
        'textColor': textColor ?? Colors.white,
        'linkColor': linkColor ?? Colors.blue,
        'selectionColor': Theme.of(context).primaryColorLight,
      },
      MessageFrom.sender: {
        'alignment': MainAxisAlignment.start,
        'bubbleColor': bubbleColor ?? Colors.white,
        'linkColor': linkColor ?? Colors.blue,
        'textColor': textColor ?? Colors.black,
        'selectionColor': Theme.of(context).primaryColorLight,
      },
      MessageFrom.user: {
        'alignment': MainAxisAlignment.end,
        'bubbleColor': bubbleColor ?? Colors.deepPurple,
        'linkColor': linkColor ?? const Color(0xFF28E2FB),
        'textColor': textColor ?? Colors.white,
        'selectionColor': Colors.deepPurple[200],
      },
    };

    return IgnorePointer(
      ignoring: from == MessageFrom.system,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Offset offset = renderBox.localToGlobal(Offset.zero);
            final Size size = renderBox.size;

            final double y = offset.dy;
            final double x = offset.dx;

            final double width = size.width;
            final double height = size.height;

            double left = width / 2;
            double right = width / 2;

            if (from == MessageFrom.sender) {
              right = x;
            } else {
              left = x;
            }

            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(left, y + height, right, 0),
              items: [
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.copy_outlined),
                    title: const Text('Copy'),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message));
                      Navigator.pop(context);
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ],
            );
          },
          child: Row(
            mainAxisAlignment: details[from]!['alignment']!,
            children: [
              Builder(builder: (BuildContext context) {
                final Color bubbleColor = details[from]!['bubbleColor']!;
                final Color selectionColor = details[from]!['selectionColor']!;
                final Color textColor = details[from]!['textColor']!;
                final Color linkColor = details[from]!['linkColor']!;

                if (message.isLessEmojisThan(5)) {
                  final EmojiParser parser = EmojiParser();

                  final int emojis = parser.count(message);
                  const double minFontSize = 30;
                  const double maxFontSize = 70;
                  double fontSize = maxFontSize / emojis;
                  fontSize = fontSize.clamp(minFontSize, maxFontSize);

                  return EmojiMessageBubble(
                    message: message,
                    createdAt: createdAt,
                    from: from,
                    status: status!,
                    fontSize: fontSize,
                  );
                }

                if (type == MessageType.audio) {
                  return AudioMessageBubble(
                    bubbleColor: bubbleColor,
                    selectionColor: selectionColor,
                    textColor: textColor,
                    linkColor: linkColor,
                    message: message,
                    createdAt: createdAt,
                    from: from,
                    status: status!,
                  );
                }

                return TextMessageBubble(
                  bubbleColor: bubbleColor,
                  selectionColor: selectionColor,
                  textColor: textColor,
                  linkColor: linkColor,
                  message: message,
                  createdAt: createdAt,
                  from: from,
                  status: status!,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
