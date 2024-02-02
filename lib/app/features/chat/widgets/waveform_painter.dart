import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  WaveformPainter({required this.amplitude});

  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    final double centerY = size.height / 2;
    final double waveHeight = amplitude * 0.5;

    canvas.drawLine(
      Offset(0, centerY - waveHeight),
      Offset(size.width, centerY - waveHeight),
      paint,
    );

    canvas.drawLine(
      Offset(0, centerY + waveHeight),
      Offset(size.width, centerY + waveHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
