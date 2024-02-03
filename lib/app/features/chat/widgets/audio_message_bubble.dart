import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/models/message_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';
import 'package:voice_message_package/voice_message_package.dart';

class AudioMessageBubble extends StatefulWidget {
  const AudioMessageBubble({
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
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  late VoiceController controller;

  @override
  void initState() {
    super.initState();
    controller = VoiceController(
      audioSrc: widget.message.location!,
      maxDuration: widget.message.duration ?? const Duration(seconds: 10),
      isFile: widget.message.location!.contains('http') == false,
      onComplete: () {},
      onPause: () {},
      onPlaying: () {},
      onError: (error) {},
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.bubbleColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          VoiceMessageView(
            controller: controller,
            backgroundColor: widget.bubbleColor,
            cornerRadius: 10,
            innerPadding: 0,
            counterTextStyle: TextStyle(
              fontSize: 12,
              color: widget.textColor,
            ),
            activeSliderColor: widget.selectionColor,
            circlesColor: widget.selectionColor,
          ),
          if (widget.message.from != MessageFrom.system)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.Hm().format(widget.message.createdAt!.toLocal()),
                      style: TextStyle(
                        color: widget.textColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    if (widget.message.from == MessageFrom.user)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 5),
                          Icon(
                            widget.message.status!.toIconData(),
                            size: 14,
                            color: widget.textColor.withOpacity(0.5),
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
