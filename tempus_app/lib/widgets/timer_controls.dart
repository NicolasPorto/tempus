import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import 'timer_painter.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Widget _buildTimerCircle(String statusText) {
    return Center(
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          color: TempusColors.surface,
          borderRadius: BorderRadius.circular(44),
          border: Border.all(color: TempusColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _phaseColor.withOpacity(0.06),
              blurRadius: 40,
              spreadRadius: 0,
            ),
            const BoxShadow(
              color: Color(0x50000000),
              blurRadius: 40,
              offset: Offset(0, 16),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 268,
              height: 268,
              child: CustomPaint(
                painter: TimerPainter(
                  backgroundColor: TempusColors.border,
                  progressColor: _phaseColor,
                  progress: widget.currentDuration / widget.initialDuration,
                  glowEnabled: widget.isRunning,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: widget.onToggleTimer,
                  child: Text(
                    _formattedTime,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: TempusColors.text,
                      fontSize: 72,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _phaseColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _phaseColor.withOpacity(0.3)),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final bool canChange =
        !widget.isRunning && widget.currentDuration == widget.initialDuration;

    if (!canChange) return const SizedBox(height: 80);

    if (widget.isPomodoroMode) return _buildPomodoroPhaseSelector();

    final List<int> presets = [15, 20, 25, 30];
    final int currentMinutes = widget.initialDuration ~/ 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Duração do Foco',
            style: TextStyle(
              color: TempusColors.textSub,
              fontSize: 12,
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...presets.map((m) => _buildPresetButton(m, currentMinutes == m)),
              _buildPickerButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroPhaseSelector() {
    final phase = widget.pomodoroPhase;
    final round = widget.pomodoroRound;

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _phaseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _phaseColor.withOpacity(0.35)),
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
                    color: _phaseColor.withOpacity(0.6),
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
              final done = i < (round % 4);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: done ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: done
                      ? TempusColors.accent
                      : TempusColors.border,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroToggle() {
    if (widget.isRunning) return const SizedBox.shrink();
    final isPaused = widget.currentDuration < widget.initialDuration;
    if (isPaused) return const SizedBox.shrink();

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
              ? TempusColors.accent.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isPomodoroMode
                ? TempusColors.accent.withOpacity(0.4)
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

  Widget _buildPresetButton(int minutes, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onDurationChanged?.call(minutes);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 58,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected ? TempusColors.gradient : null,
          color: isSelected ? null : TempusColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : TempusColors.border,
          ),
        ),
        child: Text(
          '$minutes',
          style: TextStyle(
            color: isSelected ? Colors.white : TempusColors.textSub,
            fontSize: 14,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton() {
    return GestureDetector(
      onTap: () => _showCupertinoTimePicker(context),
      child: Container(
        width: 44,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TempusColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TempusColors.accent.withOpacity(0.4)),
        ),
        child: const Icon(
          Icons.more_time_rounded,
          color: TempusColors.accent,
          size: 18,
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
    final isSubjectSelected = widget.selectedSubject != null;
    final bool isPaused =
        widget.currentDuration < widget.initialDuration && !widget.isRunning;

    String statusText;
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

    final playIcon = widget.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded;
    final playLabel = widget.isRunning ? 'Pausar' : 'Iniciar Foco';
    final showReset = widget.isRunning || isPaused;

    return Column(
      children: [
        _buildTimerCircle(statusText),

        const SizedBox(height: 24),

        _buildTimeSelector(),

        const SizedBox(height: 16),

        _buildPomodoroToggle(),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onToggleTimer,
                  child: AnimatedOpacity(
                    opacity: isSubjectSelected ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: TempusColors.gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: TempusColors.accent.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(playIcon, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            playLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (showReset) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onResetTimer,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: TempusColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TempusColors.border),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'lib/assets/icons/icon_back.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          TempusColors.textSub,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class GradientPillThumb extends SliderComponentShape {
  final LinearGradient gradient;

  const GradientPillThumb({required this.gradient});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(36, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(center: center, width: 36, height: 24);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(0, 2), const Radius.circular(12)),
      Paint()
        ..color = gradient.colors.last.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(rr, Paint()..shader = gradient.createShader(rect));
  }
}

class RecessedTrackShape extends SliderTrackShape {
  final Color baseColor;
  final LinearGradient activeGradient;

  const RecessedTrackShape({required this.baseColor, required this.activeGradient});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final h = sliderTheme.trackHeight! * 1.5;
    return Rect.fromLTWH(
      offset.dx,
      offset.dy + (parentBox.size.height - h) / 2,
      parentBox.size.width,
      h,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    Offset? secondaryOffset,
  }) {
    if (sliderTheme.trackHeight == 0) return;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );
    final canvas = context.canvas;
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(6)),
      Paint()..color = baseColor,
    );
    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, const Radius.circular(6)),
      Paint()..shader = activeGradient.createShader(activeRect),
    );
  }
}
