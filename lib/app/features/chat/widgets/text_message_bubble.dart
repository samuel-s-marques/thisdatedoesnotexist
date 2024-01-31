import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/models/message_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';
import 'package:url_launcher/url_launcher.dart';

class TextMessageBubble extends StatelessWidget {
  const TextMessageBubble({
    super.key,
    required this.bubbleColor,
    required this.selectionColor,
    required this.textColor,
    required this.linkColor,
    required this.message,
  });

  final Color bubbleColor;
  final Color selectionColor;
  final Color textColor;
  final Color linkColor;
  final Message message;

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
              text: message.content,
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
                      style: TextStyle(
                        color: textColor.withOpacity(0.5),
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
