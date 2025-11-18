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
  final Random _random = Random();
  late List<_Orb> _orbs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..repeat();

    _orbs = List.generate(6, (i) {
      final colorOptions = [
        Colors.deepPurple.withOpacity(0.15),
        Colors.indigo.withOpacity(0.12),
        Colors.blueGrey.withOpacity(0.08),
        Colors.black.withOpacity(0.1),
      ];
      return _Orb(
        color: colorOptions[_random.nextInt(colorOptions.length)],
        radius: 50 + _random.nextDouble() * 80,
        speed: 0.2 + _random.nextDouble() * 0.5,
        phase: _random.nextDouble() * 2 * pi,
      );
    });
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
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF06040A), Color(0xFF0E0820), Color(0xFF1A1030)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) =>
                CustomPaint(painter: _OrbPainter(_controller.value, _orbs)),
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

  _Orb({
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
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    for (final orb in orbs) {
      final double angle = (progress * 2 * pi * orb.speed) + orb.phase;
      final double x = (size.width / 2) + cos(angle) * (size.width * 0.35);
      final double y = (size.height / 2) + sin(angle) * (size.height * 0.35);

      paint.color = orb.color;
      canvas.drawCircle(Offset(x, y), orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
