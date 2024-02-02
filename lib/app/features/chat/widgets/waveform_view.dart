import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/features/chat/widgets/waveform_painter.dart';

class WaveformView extends StatelessWidget {
  const WaveformView({super.key, required this.amplitudeValues});

  final List<double> amplitudeValues;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(amplitudeValues: amplitudeValues),
    );
  }
}
