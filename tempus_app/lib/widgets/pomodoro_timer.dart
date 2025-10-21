import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class PomodoroTimer extends StatefulWidget {
  final int minutes;
  final FutureOr<void> Function() onComplete;

  const PomodoroTimer({Key? key, this.minutes = 25, required this.onComplete}) : super(key: key);

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> with TickerProviderStateMixin {
  late AnimationController _anim;
  Timer? _timer;
  bool running = false;
  int remainingSeconds = 25 * 60;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.minutes * 60;
    _anim = AnimationController(vsync: this, duration: Duration(seconds: remainingSeconds));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  void _start() {
    if (running) return;
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
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    _anim.stop();
    setState(() => running = false);
  }

  void _reset() {
    _timer?.cancel();
    _anim.reset();
    setState(() {
      running = false;
      remainingSeconds = widget.minutes * 60;
    });
  }

  String _pad(int x) => x.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final displayMin = remainingSeconds ~/ 60;
    final displaySec = remainingSeconds % 60;
    final progress = _anim.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        // focus animation layer (subtle)
        SizedBox(
          width: 260,
          height: 260,
          child: CustomPaint(
            painter: _RadialPainter(progress: progress),
          ),
        ),
        GestureDetector(
          onTap: () => running ? _pause() : _start(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${_pad(displayMin)}:${_pad(displaySec)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(running ? 'Focusing' : 'Tap to start', style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Reset')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(onPressed: running ? _pause : _start, icon: Icon(running ? Icons.pause : Icons.play_arrow), label: Text(running ? 'Pause' : 'Start')),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double progress;
  _RadialPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2);
    final radius = min(size.width, size.height)/2 - 8;
    final bg = Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = 14;
    final fg = Paint()
      ..shader = SweepGradient(startAngle: -pi/2, endAngle: 3*pi/2, colors: [Color(0xFFBB86FC), Color(0xFF7C4DFF)]).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;
    canvas.drawCircle(center, radius, bg);
    final sweep = 2*pi*progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi/2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RadialPainter old) => old.progress != progress;
}
