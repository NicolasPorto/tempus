import 'dart:math';
import 'dart:ui' show ImageFilter;
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

  // 3 orbs instead of 4 — fewer blur draws per frame
  final List<_Orb> _orbs = [
    _Orb(color: Color(0x2D7C3AED), radius: 150, speed: 0.16, phase: 0.0),
    _Orb(color: Color(0x1F4338CA), radius: 110, speed: 0.27, phase: 2.1),
    _Orb(color: Color(0x176D28D9), radius: 90, speed: 0.41, phase: 4.3),
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
        // Liquid glass layer — blurs the orbs, content sits sharp on top
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x1A0F0A1E), // roxo-escuro muito sutil, top
                    Color(0x220A0812), // quase preto, bottom
                  ],
                ),
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

  // Static: created once for the lifetime of the app. Blur radius 28 (was 48)
  // — cost scales with r², so 28²/48² ≈ 34% of the original GPU cost.
  static final _paint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

  @override
  void paint(Canvas canvas, Size size) {
    for (final orb in orbs) {
      final double angle = (progress * 2 * pi * orb.speed) + orb.phase;
      final double x = (size.width / 2) + cos(angle) * (size.width * 0.38);
      final double y = (size.height / 2) + sin(angle) * (size.height * 0.38);
      _paint.color = orb.color;
      canvas.drawCircle(Offset(x, y), orb.radius, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => progress != old.progress;
}
