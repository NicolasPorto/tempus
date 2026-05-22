import 'package:flutter/material.dart';
import 'dart:math' as math;

class TimerPainter extends CustomPainter {
  final Color backgroundColor;
  final Color progressColor;
  final double progress; // 0.0 → 1.0, represents remaining time
  final bool glowEnabled;

  const TimerPainter({
    required this.backgroundColor,
    required this.progressColor,
    required this.progress,
    this.glowEnabled = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0,
    );

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      final arcRect = Rect.fromCircle(center: center, radius: radius);

      // Glow layer
      if (glowEnabled) {
        canvas.drawArc(
          arcRect,
          -math.pi / 2,
          sweepAngle,
          false,
          Paint()
            ..color = progressColor.withOpacity(0.28)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 16.0
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }

      // Main arc
      canvas.drawArc(
        arcRect,
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TimerPainter old) {
    return old.progress != progress ||
        old.progressColor != progressColor ||
        old.backgroundColor != backgroundColor ||
        old.glowEnabled != glowEnabled;
  }
}
