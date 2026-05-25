import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool active;

  const ConfettiOverlay({super.key, required this.child, required this.active});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;
  final Random _rng = Random();

  static const _colors = [
    Color(0xFFA855F7),
    Color(0xFF60A5FA),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFF472B6),
    Color(0xFFFF6B6B),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _particles = _generateParticles();
    if (widget.active) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _particles = _generateParticles();
      _ctrl.forward(from: 0.0);
    }
  }

  List<_Particle> _generateParticles() => List.generate(60, (_) {
        final angle = _rng.nextDouble() * pi - pi / 2; // -90° to +90° upward
        final speed = 0.2 + _rng.nextDouble() * 0.55;
        return _Particle(
          x: 0.3 + _rng.nextDouble() * 0.4, // spawn in center band
          color: _colors[_rng.nextInt(_colors.length)],
          vx: cos(angle) * speed * (_rng.nextBool() ? 1 : -1),
          vy: -sin(angle).abs() * speed - 0.1,
          size: 4.0 + _rng.nextDouble() * 6.0,
          rotation: _rng.nextDouble() * 2 * pi,
          rotSpeed: (_rng.nextDouble() - 0.5) * 8,
          isRect: _rng.nextBool(),
        );
      });

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.active)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(_ctrl.value, _particles),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  final double x;
  final Color color;
  final double vx;
  final double vy;
  final double size;
  final double rotation;
  final double rotSpeed;
  final bool isRect;

  const _Particle({
    required this.x,
    required this.color,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotSpeed,
    required this.isRect,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;

  _ConfettiPainter(this.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const gravity = 0.45;

    for (final p in particles) {
      final elapsed = t;
      final px = p.x * size.width + p.vx * size.width * elapsed;
      final py = size.height * 0.4 +
          (p.vy * size.height * elapsed) +
          (0.5 * gravity * size.height * elapsed * elapsed);
      final fade = (1.0 - elapsed).clamp(0.0, 1.0);
      if (fade <= 0) continue;

      paint.color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + p.rotSpeed * elapsed);

      if (p.isRect) {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.5),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => t != old.t;
}
