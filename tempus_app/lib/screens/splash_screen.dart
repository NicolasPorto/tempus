import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _arcCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _arcProgress;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _pulseScale;
  late final Animation<double> _glowAlpha;

  @override
  void initState() {
    super.initState();

    _arcCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _arcProgress = Tween<double>(begin: 0.0, end: 0.75).animate(
      CurvedAnimation(parent: _arcCtrl, curve: Curves.easeOutCubic),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _glowAlpha = Tween<double>(begin: 0.28, end: 0.65).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _arcCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _pulseCtrl.repeat(reverse: true);
      }
    });

    // Arc starts immediately; title appears slightly before arc finishes
    _arcCtrl.forward();
    Future.delayed(const Duration(milliseconds: 360), () {
      if (mounted) _textCtrl.forward();
    });
  }

  @override
  void dispose() {
    _arcCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06040A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated arc circle ───────────────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([_arcCtrl, _pulseCtrl]),
              builder: (context, _) {
                return Transform.scale(
                  scale: _pulseScale.value,
                  child: SizedBox(
                    width: 116,
                    height: 116,
                    child: CustomPaint(
                      painter: _ArcPainter(
                        progress: _arcProgress.value,
                        glowAlpha: _glowAlpha.value,
                      ),
                      child: Center(
                        child: Opacity(
                          // Icon fades in during the second half of arc draw
                          opacity: (_arcProgress.value * 2 - 0.6)
                              .clamp(0.0, 1.0),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: TempusColors.accent,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // ── App name ──────────────────────────────────────────
            SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _titleOpacity,
                child: ShaderMask(
                  shaderCallback: (bounds) => TempusColors.gradient
                      .createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Text(
                    'TEMPUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 9,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Tagline ───────────────────────────────────────────
            FadeTransition(
              opacity: _taglineOpacity,
              child: const Text(
                'Foco. Consistência. Resultado.',
                style: TextStyle(
                  color: Color(0xFF4B4B5C),
                  fontSize: 11,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Arc painter ───────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress; // 0.0 → 0.75
  final double glowAlpha;

  const _ArcPainter({required this.progress, required this.glowAlpha});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = -pi / 2; // 12 o'clock
    final sweepAngle = 2 * pi * progress;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF1C1028)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    if (progress <= 0) return;

    // Glow pass — wider, blurred, same arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = TempusColors.accent.withValues(alpha: glowAlpha * 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Main arc — gradient from accent → accentBlue
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + 2 * pi * 0.75,
          colors: const [TempusColors.accent, TempusColors.accentBlue],
          tileMode: TileMode.clamp,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Glowing dot at the arc tip
    final tipX = center.dx + radius * cos(startAngle + sweepAngle);
    final tipY = center.dy + radius * sin(startAngle + sweepAngle);
    final tip = Offset(tipX, tipY);

    // Outer glow of tip
    canvas.drawCircle(
      tip,
      7,
      Paint()
        ..color = TempusColors.accentBlue.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Solid tip dot
    canvas.drawCircle(
      tip,
      4,
      Paint()
        ..color = TempusColors.accentBlue
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      progress != old.progress || glowAlpha != old.glowAlpha;
}
