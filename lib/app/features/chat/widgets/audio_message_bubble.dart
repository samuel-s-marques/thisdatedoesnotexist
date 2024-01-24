import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_from_enum.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/message_status_enum.dart';

class AudioMessageBubble extends StatefulWidget {
  const AudioMessageBubble({
    super.key,
    required this.bubbleColor,
    required this.selectionColor,
    required this.textColor,
    required this.linkColor,
    required this.message,
    required this.createdAt,
    required this.from,
    required this.status,
  });

  final Color bubbleColor;
  final Color selectionColor;
  final Color textColor;
  final Color linkColor;
  final String message;
  final DateTime createdAt;
  final MessageFrom from;
  final MessageStatus status;

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  late PlayerController controller;
  
  @override
  void initState() {
    super.initState();
    controller = PlayerController()..preparePlayer(path: widget.message);
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
          Theme(
            data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: widget.selectionColor,
                selectionColor: widget.selectionColor,
                selectionHandleColor: widget.selectionColor,
              ),
            ),
            child: AudioFileWaveforms(
              size: Size(
                MediaQuery.of(context).size.width * 0.7,
                100,
              ),
              playerController: PlayerController(),
              waveformType: WaveformType.fitWidth,
            ),
          ),
          if (widget.from != MessageFrom.system)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.Hm().format(widget.createdAt.toLocal()),
                      style: TextStyle(
                        color: widget.textColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    if (widget.from == MessageFrom.user)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 5),
                          Icon(
                            widget.status.toIconData(),
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
