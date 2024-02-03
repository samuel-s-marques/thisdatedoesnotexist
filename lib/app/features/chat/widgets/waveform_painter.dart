import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  WaveformPainter({required this.amplitudeValues});

  final List<double> amplitudeValues;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double centerY = size.height / 2;

    for (int i = 0; i < amplitudeValues.length; i++) {
      final double amplitude = amplitudeValues[i];

      final double x = size.width - i.toDouble() * 4;
      final double y = centerY - amplitude * 0.5;

      canvas.drawLine(
        Offset(x, centerY - y),
        Offset(x, centerY + y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
