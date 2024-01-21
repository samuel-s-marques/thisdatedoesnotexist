import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.type,
    required this.message,
    required this.createdAt,
    this.status,
    this.bubbleColor,
    this.textColor,
    this.linkColor,
  });

  final MessageType type;
  final String message;
  final DateTime createdAt;
  final MessageStatus? status;
  final Color? bubbleColor;
  final Color? textColor;
  final Color? linkColor;

  @override
  Widget build(BuildContext context) {
    final Map<MessageType, Map<String, dynamic>> details = {
      MessageType.system: {
        'alignment': MainAxisAlignment.center,
        'bubbleColor': bubbleColor ?? Colors.grey,
        'textColor': textColor ?? Colors.white,
        'linkColor': linkColor ?? Colors.blue,
        'selectionColor': Theme.of(context).primaryColorLight,
      },
      MessageType.sender: {
        'alignment': MainAxisAlignment.start,
        'bubbleColor': bubbleColor ?? Colors.white,
        'linkColor': linkColor ?? Colors.blue,
        'textColor': textColor ?? Colors.black,
        'selectionColor': Theme.of(context).primaryColorLight,
      },
      MessageType.user: {
        'alignment': MainAxisAlignment.end,
        'bubbleColor': bubbleColor ?? Colors.deepPurple,
        'linkColor': linkColor ?? const Color(0xFFC3F73A),
        'textColor': textColor ?? Colors.white,
        'selectionColor': Colors.deepPurple[200],
      },
    };

    return IgnorePointer(
      ignoring: type == MessageType.system,
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

            if (type == MessageType.sender) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Theme(
                      data: ThemeData(
                        textSelectionTheme: TextSelectionThemeData(
                          cursorColor: details[type]!['selectionColor']!,
                          selectionColor: details[type]!['selectionColor']!,
                          selectionHandleColor: details[type]!['selectionColor']!,
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
                          color: details[type]!['textColor']!,
                        ),
                        linkStyle: TextStyle(
                          color: details[type]!['linkColor']!,
                          decoration: TextDecoration.underline,
                          decorationColor: details[type]!['linkColor']!,
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
                                  color: details[type]!['textColor']!.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                              if (type == MessageType.user)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 5),
                                    Icon(
                                      status!.toIconData(),
                                      size: 14,
                                      color: details[type]!['textColor']!.withOpacity(0.5),
                                    ),
                                  ],
                                )
                            ],
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
