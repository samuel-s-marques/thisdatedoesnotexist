import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_type_enum.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.type,
    required this.message,
    this.createdAt,
    this.bubbleColor,
    this.textColor,
  });

  final MessageType type;
  final String message;
  final DateTime? createdAt;
  final Color? bubbleColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final Map<MessageType, Map<String, dynamic>> details = {
      MessageType.system: {
        'alignment': MainAxisAlignment.center,
        'bubbleColor': bubbleColor ?? Colors.grey,
        'textColor': textColor ?? Colors.white,
        'selectionColor': Theme.of(context).primaryColorLight,
      },
      MessageType.sender: {
        'alignment': MainAxisAlignment.start,
        'bubbleColor': bubbleColor ?? Colors.white,
        'textColor': textColor ?? Colors.black,
        'selectionColor': Theme.of(context).primaryColorLight,
      },
      MessageType.user: {
        'alignment': MainAxisAlignment.end,
        'bubbleColor': bubbleColor ?? Colors.deepPurple,
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
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.report_outlined),
                    title: const Text('Report'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement report
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
                      child: SelectableText(
                        message,
                        style: TextStyle(
                          color: details[type]!['textColor']!,
                        ),
                      ),
                    ),
                    if (type != MessageType.system)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            DateFormat.Hm().format(createdAt!),
                            style: TextStyle(
                              color: details[type]!['textColor']!.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
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
