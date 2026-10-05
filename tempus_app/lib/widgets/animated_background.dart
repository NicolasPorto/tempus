import 'dart:math';
import 'package:flutter/material.dart';
import '../controller/timer_controller.dart' show isFocusModeGlobalNotifier;
import '../theme/app_theme.dart';

/// Fundo "aurora" com orbes de luz que flutuam lentamente.
///
/// Os orbes são pintados com gradientes radiais (bordas naturalmente suaves),
/// o que dispensa o BackdropFilter de tela cheia usado antes — esse blur era
/// recalculado a cada frame e dominava o custo de GPU do app. A animação
/// também pausa no modo foco, quando o fundo fica coberto.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<_Orb> _orbs = [
    _Orb(color: Color(0x557C3AED), radius: 0.62, speed: 0.16, phase: 0.0, ox: 0.15, oy: 0.10),
    _Orb(color: Color(0x383B5BDB), radius: 0.50, speed: 0.27, phase: 2.1, ox: 0.85, oy: 0.55),
    _Orb(color: Color(0x30C026D3), radius: 0.42, speed: 0.41, phase: 4.3, ox: 0.30, oy: 0.95),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    isFocusModeGlobalNotifier.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (isFocusModeGlobalNotifier.value) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    isFocusModeGlobalNotifier.removeListener(_onFocusChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: TempusColors.bg)),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _OrbPainter(_controller, _orbs)),
          ),
        ),
        // Vinheta: escurece as bordas e mantém o conteúdo legível.
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x66000000), Color(0xCC05040A)],
                  stops: [0.0, 0.55, 1.0],
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
  final double radius; // fração da largura da tela
  final double speed;
  final double phase;
  final double ox, oy; // centro da órbita (fração da tela)

  const _Orb({
    required this.color,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.ox,
    required this.oy,
  });
}

class _OrbPainter extends CustomPainter {
  final Animation<double> progress;
  final List<_Orb> orbs;

  _OrbPainter(this.progress, this.orbs) : super(repaint: progress);

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value * 2 * pi;
    for (final orb in orbs) {
      final angle = t * orb.speed * 3 + orb.phase;
      final c = Offset(
        size.width * orb.ox + cos(angle) * size.width * 0.18,
        size.height * orb.oy + sin(angle * 0.8) * size.height * 0.08,
      );
      final r = size.width * orb.radius;
      _paint.shader = RadialGradient(
        colors: [orb.color, orb.color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => false;
}
