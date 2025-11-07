import 'package:flutter/material.dart';
import 'dart:math' as math;

class TimerPainter extends CustomPainter {
  final Color backgroundColor;
  final Color progressColor;
  final double animationValue;

  TimerPainter({
    required this.backgroundColor,
    required this.progressColor,
    this.animationValue = 1.0, required double progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2,
      backgroundPaint,
    );

    Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      startAngle + math.pi * 0.1,
      math.pi * 0.2,
      false,
      progressPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      startAngle + math.pi * 0.55,
      math.pi * 0.2,
      false,
      progressPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      startAngle + math.pi * 1.25,
      math.pi * 0.2,
      false,
      progressPaint,
    );

    // Se você quiser um progresso real (um único arco), descomente este e ajuste os anteriores:
    // final sweepAngle = 2 * math.pi * animationValue; // 360 graus * valor de animação
    // canvas.drawArc(
    //   Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
    //   startAngle,
    //   sweepAngle,
    //   false,
    //   progressPaint,
    // );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.animationValue != animationValue;
  }
}
