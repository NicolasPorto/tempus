import 'package:flutter/material.dart';
import 'dart:math' as math;

class TimerPainter extends CustomPainter {
  final Color backgroundColor;
  final Color progressColor;
  final double progress;
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
    final radius = (size.width / 2) - 6;

    // Track ring — subtle purple tint so o track "respira" junto com o tema
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF1E1428)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0,
    );

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      final arcRect = Rect.fromCircle(center: center, radius: radius);

      if (glowEnabled) {
        // Outer diffuse glow — mais amplo e intenso
        canvas.drawArc(
          arcRect,
          -math.pi / 2,
          sweepAngle,
          false,
          Paint()
            ..color = progressColor.withValues(alpha:0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 38.0
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
        );

        // Mid glow
        canvas.drawArc(
          arcRect,
          -math.pi / 2,
          sweepAngle,
          false,
          Paint()
            ..color = progressColor.withValues(alpha:0.42)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 16.0
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );

        // Inner sharp glow — define o brilho "neon"
        canvas.drawArc(
          arcRect,
          -math.pi / 2,
          sweepAngle,
          false,
          Paint()
            ..color = progressColor.withValues(alpha:0.60)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8.0
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }

      // Gradient arc — arco principal mais espesso
      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFF60A5FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        arcRect,
        -math.pi / 2,
        sweepAngle,
        false,
        gradientPaint,
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
