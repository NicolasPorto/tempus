import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Mostrador do timer: marcações de minuto, trilha, arco de progresso em
/// gradiente na cor da matéria e um "cometa" luminoso na ponta do arco.
class TimerPainter extends CustomPainter {
  final Color backgroundColor;
  final Color progressColor;
  final double progress; // 1.0 = cheio, 0.0 = terminou
  final bool glowEnabled;

  const TimerPainter({
    required this.backgroundColor,
    required this.progressColor,
    required this.progress,
    this.glowEnabled = true,
  });

  static const double _stroke = 10.0;
  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - 14;
    final p = progress.clamp(0.0, 1.0);

    // Marcações (60), maiores a cada 5. As do trecho já decorrido apagam.
    final tickOuter = radius - _stroke - 8;
    final elapsedFrac = 1 - p;
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 60; i++) {
      final major = i % 5 == 0;
      final frac = i / 60;
      final passed = frac < elapsedFrac;
      final a = _start + frac * 2 * math.pi;
      final len = major ? 9.0 : 4.5;
      tickPaint
        ..strokeWidth = major ? 2.0 : 1.4
        ..color = passed
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: major ? 0.32 : 0.14);
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + dir * tickOuter,
        center + dir * (tickOuter - len),
        tickPaint,
      );
    }

    // Trilha
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Color.lerp(backgroundColor, progressColor, 0.10)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );

    if (p <= 0) return;

    // O arco é desenhado "para trás" a partir do topo, de modo que ele
    // encolhe no sentido horário conforme o tempo passa.
    final sweep = 2 * math.pi * p;
    final arcStart = _start + 2 * math.pi * (1 - p);
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final light = Color.lerp(progressColor, Colors.white, 0.45)!;

    if (glowEnabled) {
      canvas.drawArc(
        arcRect,
        arcStart,
        sweep,
        false,
        Paint()
          ..color = progressColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    final shader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [light, progressColor, progressColor.withValues(alpha: 0.6)],
      stops: const [0.0, 0.4, 1.0],
      transform: GradientRotation(arcStart),
    ).createShader(arcRect);

    // Sweep gradient "dobra" em 2π: para arcos quase completos, o fim claro
    // encontra o início escuro. Limitamos a ~99.5% para evitar a costura.
    canvas.drawArc(
      arcRect,
      arcStart,
      math.min(sweep, 2 * math.pi * 0.995),
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );

    // Cabeça luminosa na ponta móvel do arco — funciona como um ponteiro.
    final headAngle = arcStart;
    final head = center +
        Offset(math.cos(headAngle), math.sin(headAngle)) * radius;
    if (glowEnabled) {
      canvas.drawCircle(
        head,
        14,
        Paint()
          ..color = light.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    canvas.drawCircle(head, 7.5, Paint()..color = Colors.white);
    canvas.drawCircle(head, 3.5, Paint()..color = progressColor);
  }

  @override
  bool shouldRepaint(covariant TimerPainter old) {
    return old.progress != progress ||
        old.progressColor != progressColor ||
        old.backgroundColor != backgroundColor ||
        old.glowEnabled != glowEnabled;
  }
}
