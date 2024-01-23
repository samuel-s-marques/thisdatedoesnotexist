import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';
import 'package:url_launcher/url_launcher.dart';

class TextMessageBubble extends StatelessWidget {
  const TextMessageBubble({
    super.key,
    required this.bubbleColor,
    required this.selectionColor,
    required this.textColor,
    required this.linkColor,
    required this.message,
    required this.createdAt,
    required this.type,
    required this.status,
  });

  final Color bubbleColor;
  final Color selectionColor;
  final Color textColor;
  final Color linkColor;
  final String message;
  final DateTime createdAt;
  final MessageType type;
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Theme(
            data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: selectionColor,
                selectionColor: selectionColor,
                selectionHandleColor: selectionColor,
              ),
            ),
            child: SelectableLinkify(
              text: message,
              onOpen: (LinkableElement link) async {
                if (await canLaunchUrl(Uri.parse(link.url))) {
                  await launchUrl(Uri.parse(link.url));
                }
              },
              style: TextStyle(
                color: textColor,
              ),
              linkStyle: TextStyle(
                color: linkColor,
                decoration: TextDecoration.underline,
                decorationColor: linkColor,
              ),
            ),
          ),
          if (type != MessageType.system)
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
                      style: TextStyle(
                        color: textColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    if (type == MessageType.user)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 5),
                          Icon(
                            status.toIconData(),
                            size: 14,
                            color: textColor.withOpacity(0.5),
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
