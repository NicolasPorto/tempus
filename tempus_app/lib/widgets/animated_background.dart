import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<_Orb> _orbs = [
    _Orb(color: Color(0x2D7C3AED), radius: 150, speed: 0.16, phase: 0.0),
    _Orb(color: Color(0x1F4338CA), radius: 110, speed: 0.27, phase: 2.1),
    _Orb(color: Color(0x171E40AF), radius: 90, speed: 0.41, phase: 4.3),
    _Orb(color: Color(0x126D28D9), radius: 70, speed: 0.58, phase: 1.05),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: _OrbPainter(_controller.value, _orbs),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Orb {
  final Color color;
  final double radius;
  final double speed;
  final double phase;

  const _Orb({
    required this.color,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}

class _OrbPainter extends CustomPainter {
  final double progress;
  final List<_Orb> orbs;

  _OrbPainter(this.progress, this.orbs);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48);

    for (final orb in orbs) {
      final double angle = (progress * 2 * pi * orb.speed) + orb.phase;
      final double x = (size.width / 2) + cos(angle) * (size.width * 0.38);
      final double y = (size.height / 2) + sin(angle) * (size.height * 0.38);

      paint.color = orb.color;
      canvas.drawCircle(Offset(x, y), orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => progress != old.progress;
}
