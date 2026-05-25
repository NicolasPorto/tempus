import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/subject.dart';
import 'timer_painter.dart';
import '../controller/timer_controller.dart';
import '../theme/app_theme.dart';

class TimerControls extends StatefulWidget {
  final Subject? selectedSubject;
  final VoidCallback onToggleTimer;
  final VoidCallback? onResetTimer;
  final Function(int)? onDurationChanged;
  final int currentDuration;
  final int initialDuration;
  final bool isRunning;
  final bool isPomodoroMode;
  final PomodoroPhase pomodoroPhase;
  final int pomodoroRound;
  final VoidCallback? onTogglePomodoroMode;

  const TimerControls({
    super.key,
    required this.selectedSubject,
    required this.onToggleTimer,
    this.onResetTimer,
    this.onDurationChanged,
    required this.currentDuration,
    required this.initialDuration,
    required this.isRunning,
    this.isPomodoroMode = false,
    this.pomodoroPhase = PomodoroPhase.work,
    this.pomodoroRound = 0,
    this.onTogglePomodoroMode,
  });

  @override
  State<TimerControls> createState() => _TimerControlsState();
}

class _TimerControlsState extends State<TimerControls> {
  bool _playPressed = false;

  String get _formattedTime {
    final m = (widget.currentDuration ~/ 60).toString().padLeft(2, '0');
    final s = (widget.currentDuration % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _phaseColor {
    if (!widget.isPomodoroMode) {
      return Color(widget.selectedSubject?.colorValue ?? 0xFFA855F7);
    }
    switch (widget.pomodoroPhase) {
      case PomodoroPhase.work:
        return Color(widget.selectedSubject?.colorValue ?? 0xFFA855F7);
      case PomodoroPhase.shortBreak:
        return TempusColors.green;
      case PomodoroPhase.longBreak:
        return TempusColors.accentBlue;
    }
  }

  Widget _buildTimerRing(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // RepaintBoundary isolates the CustomPaint layer so the rest of the
          // widget tree is not invalidated on every second tick.
          RepaintBoundary(
            child: CustomPaint(
              size: Size(size, size),
              painter: TimerPainter(
                backgroundColor: TempusColors.border,
                progressColor: _phaseColor,
                progress: widget.initialDuration > 0
                    ? widget.currentDuration / widget.initialDuration
                    : 1.0,
                glowEnabled: widget.isRunning,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formattedTime,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TempusColors.text,
                  fontSize: 58,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    final isSubjectSelected = widget.selectedSubject != null;
    final icon = widget.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return GestureDetector(
      onTapDown: (_) => setState(() => _playPressed = true),
      onTapUp: (_) {
        setState(() => _playPressed = false);
        if (isSubjectSelected) widget.onToggleTimer();
      },
      onTapCancel: () => setState(() => _playPressed = false),
      child: AnimatedScale(
        scale: _playPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: isSubjectSelected ? 1.0 : 0.35,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [TempusColors.accent, TempusColors.accentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: TempusColors.accent.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onResetTimer?.call();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: TempusColors.surface,
          border: Border.all(color: TempusColors.border),
        ),
        child: const Icon(
          Icons.replay_rounded,
          color: TempusColors.textSub,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statusText) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _phaseColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _phaseColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: _phaseColor,
          fontSize: 12,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPresets() {
    final bool canChange =
        !widget.isRunning && widget.currentDuration == widget.initialDuration;
    if (!canChange) return const SizedBox.shrink();
    if (widget.isPomodoroMode) return _buildPomodoroInfo();

    const List<int> presets = [15, 20, 25, 30, 45, 60];
    final int currentMinutes = widget.initialDuration ~/ 60;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          ...presets.map((m) {
            final isSelected = currentMinutes == m;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onDurationChanged?.call(m);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? TempusColors.gradient : null,
                    color: isSelected ? null : TempusColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : TempusColors.border,
                    ),
                  ),
                  child: Text(
                    '${m}min',
                    style: TextStyle(
                      color: isSelected ? Colors.white : TempusColors.textSub,
                      fontSize: 13,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: () => _showCupertinoTimePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: TempusColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TempusColors.accent.withValues(alpha: 0.4)),
              ),
              child: const Icon(
                Icons.more_time_rounded,
                color: TempusColors.accent,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroInfo() {
    final phase = widget.pomodoroPhase;
    String phaseLabel;
    String phaseDuration;
    switch (phase) {
      case PomodoroPhase.work:
        phaseLabel = 'Sessão de Foco';
        phaseDuration = '25 min';
        break;
      case PomodoroPhase.shortBreak:
        phaseLabel = 'Pausa Curta';
        phaseDuration = '5 min';
        break;
      case PomodoroPhase.longBreak:
        phaseLabel = 'Pausa Longa';
        phaseDuration = '15 min';
        break;
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _phaseColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _phaseColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phaseLabel,
                style: TextStyle(
                  color: _phaseColor,
                  fontSize: 13,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· $phaseDuration',
                style: TextStyle(
                  color: _phaseColor.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontFamily: 'Arimo',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final done = i < (widget.pomodoroRound % 4);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: done ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: done ? TempusColors.accent : TempusColors.border,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPomodoroToggle() {
    final isPaused = widget.currentDuration < widget.initialDuration;
    if (widget.isRunning || isPaused) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTogglePomodoroMode?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: widget.isPomodoroMode
              ? TempusColors.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isPomodoroMode
                ? TempusColors.accent.withValues(alpha: 0.4)
                : TempusColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat_rounded,
              size: 13,
              color: widget.isPomodoroMode
                  ? TempusColors.accent
                  : TempusColors.textSub,
            ),
            const SizedBox(width: 6),
            Text(
              'Modo Pomodoro',
              style: TextStyle(
                color: widget.isPomodoroMode
                    ? TempusColors.accent
                    : TempusColors.textSub,
                fontSize: 12,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCupertinoTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 280,
        color: TempusColors.surfaceHigh,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: TempusColors.textSub),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: TempusColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(seconds: widget.initialDuration),
                onTimerDurationChanged: (d) {
                  if (d.inMinutes > 0) widget.onDurationChanged?.call(d.inMinutes);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = (screenWidth * 0.72).clamp(200.0, 280.0);
    final isPaused =
        widget.currentDuration < widget.initialDuration && !widget.isRunning;
    final showReset = widget.isRunning || isPaused;

    String statusText;
    final isSubjectSelected = widget.selectedSubject != null;
    if (!isSubjectSelected) {
      statusText = 'Selecione uma matéria';
    } else if (widget.isPomodoroMode) {
      if (widget.isRunning) {
        switch (widget.pomodoroPhase) {
          case PomodoroPhase.work:
            statusText = 'Foco em andamento';
            break;
          case PomodoroPhase.shortBreak:
            statusText = 'Pausa Curta';
            break;
          case PomodoroPhase.longBreak:
            statusText = 'Pausa Longa';
            break;
        }
      } else if (isPaused) {
        statusText = 'Pausado';
      } else {
        switch (widget.pomodoroPhase) {
          case PomodoroPhase.work:
            statusText = 'Iniciar foco';
            break;
          case PomodoroPhase.shortBreak:
            statusText = 'Pausa curta';
            break;
          case PomodoroPhase.longBreak:
            statusText = 'Pausa longa';
            break;
        }
      }
    } else if (widget.isRunning) {
      statusText = 'Foco em andamento';
    } else if (isPaused) {
      statusText = 'Pausado';
    } else {
      statusText = 'Pressione para começar';
    }

    return Column(
      children: [
        _GyroTilt3D(child: _buildTimerRing(ringSize)),

        const SizedBox(height: 16),

        _buildStatusBadge(statusText),

        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showReset) ...[
              _buildResetButton(),
              const SizedBox(width: 24),
            ],
            _buildPlayButton(),
            if (showReset) const SizedBox(width: 66),
          ],
        ),

        const SizedBox(height: 32),

        _buildPresets(),

        const SizedBox(height: 16),

        _buildPomodoroToggle(),
      ],
    );
  }
}

// ── Gyroscope 3D tilt ─────────────────────────────────────────────
// Wraps any child with a Matrix4 perspective transform driven by the
// device accelerometer. AnimationController drives per-frame lerp so
// movement stays fluid regardless of sensor sampling rate.

class _GyroTilt3D extends StatefulWidget {
  final Widget child;
  const _GyroTilt3D({required this.child});

  @override
  State<_GyroTilt3D> createState() => _GyroTilt3DState();
}

class _GyroTilt3DState extends State<_GyroTilt3D>
    with SingleTickerProviderStateMixin {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  late final AnimationController _driver;

  double _targetX = 0.0, _targetY = 0.0;
  double _currentX = 0.0, _currentY = 0.0;

  // ~6° max tilt in radians; lerp factor per 60fps frame
  static const double _maxTilt = 0.105;
  static const double _lerp = 0.06;

  @override
  void initState() {
    super.initState();

    // AnimationController.repeat() drives a listener every vsync frame.
    _driver = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat()
      ..addListener(_onFrame);

    try {
      // accelerometerEvents: gravity-inclusive stream, always available in
      // sensors_plus 3.x. x/y components encode device tilt vs gravity.
      _accelSub = accelerometerEvents.listen((AccelerometerEvent e) {
        _targetY = (-e.x / 9.8 * _maxTilt).clamp(-_maxTilt, _maxTilt);
        _targetX = (e.y / 9.8 * _maxTilt * 0.6).clamp(-_maxTilt, _maxTilt);
      });
    } catch (_) {
      // Sensor unavailable (emulator) — widget renders without tilt.
    }
  }

  void _onFrame() {
    final nx = _currentX + (_targetX - _currentX) * _lerp;
    final ny = _currentY + (_targetY - _currentY) * _lerp;
    if ((nx - _currentX).abs() > 0.0003 || (ny - _currentY).abs() > 0.0003) {
      setState(() {
        _currentX = nx;
        _currentY = ny;
      });
    }
  }

  @override
  void dispose() {
    _driver.dispose();
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective depth
        ..rotateX(_currentX)
        ..rotateY(_currentY),
      child: widget.child,
    );
  }
}
