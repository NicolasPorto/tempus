import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../libraries/globals.dart';
import '../libraries/screen_dimmer.dart';
import 'package:vibration/vibration.dart';

class PomodoroTimer extends StatefulWidget {
  final int minutes;
  final FutureOr<void> Function() onComplete;

  const PomodoroTimer({Key? key, this.minutes = 25, required this.onComplete})
    : super(key: key);

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with TickerProviderStateMixin {
  late AnimationController _anim;
  Timer? _timer;
  bool running = false;
  int remainingSeconds = 25 * 60;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.minutes * 60;
    _anim = AnimationController(
      vsync: this,
      duration: Duration(seconds: remainingSeconds),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  void _start(BuildContext context) {
    if (running) return;

    final globals = Provider.of<TempusGlobals>(context, listen: false);
    setState(() => running = true);
    _anim.duration = Duration(seconds: remainingSeconds);
    _anim.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (remainingSeconds <= 1) {
          _timer?.cancel();
          running = false;
          remainingSeconds = widget.minutes * 60;
          _anim.reset();
          widget.onComplete();
        } else {
          remainingSeconds -= 1;

          final int elapsedSeconds = (widget.minutes * 60) - remainingSeconds;

          if (elapsedSeconds > 0 && elapsedSeconds % 600 == 0) {
            Vibration.vibrate(duration: 2000);
          }

          if (elapsedSeconds > 0 && elapsedSeconds % 60 == 0) {
            Vibration.vibrate;
          }


        }
      });
    });

    globals.onFocus = true;
    screenDimmer.startBlackout();
  }

  void _pause(BuildContext context) {
    final globals = Provider.of<TempusGlobals>(context, listen: false);
    _timer?.cancel();
    _anim.stop();
    setState(() => running = false);
    
    globals.onFocus = false;
    screenDimmer.stopBlackout();
  }

  void _reset(BuildContext context) {
    final globals = Provider.of<TempusGlobals>(context, listen: false);
    _timer?.cancel();
    _anim.reset();
    setState(() {
      running = false;
      remainingSeconds = widget.minutes * 60;
    });

    globals.onFocus = false;
    screenDimmer.stopBlackout();
  }

  String _pad(int x) => x.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final displayMin = remainingSeconds ~/ 60;
    final displaySec = remainingSeconds % 60;
    final progress = _anim.value;

    return GestureDetector(
        onTap: () => running ? () => _pause(context) : () => _start(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(painter: _RadialPainter(progress: progress)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_pad(displayMin)}:${_pad(displaySec)}',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.deepPurpleAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      running ? 'Em foco...' : 'Pressione para iniciar',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  text: 'Recomeçar',
                  icon: Icons.refresh,
                  onPressed: () => _reset(context),
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  text: running ? 'Pausar' : 'Iniciar',
                  icon: running ? Icons.pause : Icons.play_arrow,
                  onPressed: running ? () => _pause(context) : () => _start(context),
                  primary: true,
                  ),
                ],
              )
            ],
          ),
        );

  }
}

// Botão
class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  const _ActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = primary
        ? Colors.deepPurpleAccent.withOpacity(0.8)
        : Colors.transparent;
    final borderColor = primary ? Colors.deepPurpleAccent : Colors.white38;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: bgColor,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

// Pintor radial
class _RadialPainter extends CustomPainter {
  final double progress;
  final double rotation;

  _RadialPainter({required this.progress, this.rotation = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 14;

    final bg = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2 + rotation,
        endAngle: 3 * pi / 2 + rotation,
        colors: [Color(0xFF7C4DFF), Color(0xFFBB86FC), Color(0xFF7C4DFF)],
        stops: [0, 0.7, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialPainter old) =>
      old.progress != progress || old.rotation != rotation;
}
