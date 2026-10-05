import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'timer_painter.dart';
import 'common/ui.dart';
import '../controller/timer_controller.dart';
import '../theme/app_theme.dart';

Color phaseColorOf(TimerController c) {
  final subjectColor = Color(c.selectedSubject?.colorValue ?? 0xFFA855F7);
  if (!c.isPomodoroMode) return subjectColor;
  switch (c.pomodoroPhase) {
    case PomodoroPhase.work:
      return subjectColor;
    case PomodoroPhase.shortBreak:
      return TempusColors.green;
    case PomodoroPhase.longBreak:
      return TempusColors.accentBlue;
  }
}

/// Anel do timer + controles. Usado tanto na tela principal quanto no modo foco.
class TimerControls extends StatelessWidget {
  final bool focusLayout;

  const TimerControls({super.key, this.focusLayout = false});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TimerController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize =
        (screenWidth * (focusLayout ? 0.84 : 0.76)).clamp(230.0, 330.0);
    final active = c.isRunning || c.isPaused;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GyroTilt3D(
          enabled: !focusLayout,
          child: _TimerRing(controller: c, size: ringSize),
        ),
        const SizedBox(height: 28),
        _ControlsRow(controller: c),
        if (!active && !focusLayout) ...[
          const SizedBox(height: 28),
          _ModeSwitch(controller: c),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: c.isPomodoroMode
                ? _PomodoroInfo(key: const ValueKey('pomo'), controller: c)
                : _Presets(key: const ValueKey('presets'), controller: c),
          ),
        ],
      ],
    );
  }
}

// ── Ring ──────────────────────────────────────────────────────────

class _TimerRing extends StatelessWidget {
  final TimerController controller;
  final double size;

  const _TimerRing({required this.controller, required this.size});

  String get _time {
    final total = controller.currentDuration;
    final h = total ~/ 3600;
    final m = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String get _label {
    final c = controller;
    if (c.isPomodoroMode) {
      switch (c.pomodoroPhase) {
        case PomodoroPhase.work:
          return 'FOCO · ${c.pomodoroRound % 4 + 1}/4';
        case PomodoroPhase.shortBreak:
          return 'PAUSA CURTA';
        case PomodoroPhase.longBreak:
          return 'PAUSA LONGA';
      }
    }
    if (c.isPaused) return 'PAUSADO';
    if (c.isRunning) return 'EM FOCO';
    return 'PRONTO';
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final color = phaseColorOf(c);
    final progress =
        c.initialDuration > 0 ? c.currentDuration / c.initialDuration : 1.0;
    final hasHours = c.currentDuration >= 3600;

    String footer;
    if (c.isRunning) {
      footer = 'termina às ${formatClock(c.projectedEnd)}';
    } else if (c.isPaused) {
      footer = 'toque ▶ para retomar';
    } else if (c.selectedSubject == null) {
      footer = 'escolha uma matéria';
    } else {
      footer = 'até ${formatClock(c.projectedEnd)}';
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo ambiente na cor da fase.
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: c.isRunning ? 0.22 : 0.10),
                  blurRadius: size * 0.35,
                  spreadRadius: size * 0.02,
                ),
              ],
            ),
          ),
          RepaintBoundary(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CustomPaint(
                size: Size(size, size),
                painter: TimerPainter(
                  backgroundColor: TempusColors.surfaceHigh,
                  progressColor: color,
                  progress: value,
                  glowEnabled: c.isRunning,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Color.lerp(color, Colors.white, 0.35),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
                child: Text(_label),
              ),
              const SizedBox(height: 6),
              Text(
                _time,
                style: TextStyle(
                  color: TempusColors.text,
                  fontSize: size * (hasHours ? 0.17 : 0.215),
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                  letterSpacing: -2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                footer,
                style: const TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Controls row ──────────────────────────────────────────────────

class _ControlsRow extends StatelessWidget {
  final TimerController controller;
  const _ControlsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final active = c.isRunning || c.isPaused;
    final color = phaseColorOf(c);

    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SideSlot(
            visible: active,
            child: _RoundIconButton(
              icon: Icons.stop_rounded,
              tooltip: 'Encerrar sessão',
              onTap: () {
                HapticFeedback.lightImpact();
                c.resetTimer();
              },
            ),
          ),
          const SizedBox(width: 26),
          _PlayButton(
            isRunning: c.isRunning,
            enabled: c.selectedSubject != null,
            color: color,
            onTap: c.toggleTimer,
          ),
          const SizedBox(width: 26),
          _SideSlot(
            visible: active && !c.isPomodoroMode,
            child: _RoundIconButton(
              label: '+5',
              tooltip: 'Adicionar 5 minutos',
              onTap: () => c.extendSession(5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideSlot extends StatelessWidget {
  final bool visible;
  final Widget child;
  const _SideSlot({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: AnimatedScale(
        scale: visible ? 1 : 0.6,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(ignoring: !visible, child: child),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({
    this.icon,
    this.label,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.9,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TempusColors.surfaceHigh.withValues(alpha: 0.9),
            border: Border.all(color: TempusColors.border),
          ),
          alignment: Alignment.center,
          child: label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    color: TempusColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Icon(icon, color: TempusColors.text, size: 22),
        ),
      ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  final bool isRunning;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _PlayButton({
    required this.isRunning,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return Semantics(
      button: true,
      label: widget.isRunning ? 'Pausar' : 'Iniciar',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (widget.enabled) widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: widget.enabled ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  // Duas paradas: com três, o Impeller desenha uma costura
                  // diagonal visível no círculo.
                  colors: [
                    Color.lerp(c, Colors.white, 0.12)!,
                    Color.lerp(c, TempusColors.accentBlue, 0.45)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.withValues(alpha: 0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  widget.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  key: ValueKey(widget.isRunning),
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mode switch (Livre | Pomodoro) ────────────────────────────────

class _ModeSwitch extends StatelessWidget {
  final TimerController controller;
  const _ModeSwitch({required this.controller});

  @override
  Widget build(BuildContext context) {
    final pomodoro = controller.isPomodoroMode;
    return Container(
      width: 236,
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: TempusColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TempusColors.border),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment:
                pomodoro ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: TempusColors.surfaceHigher,
                  borderRadius: BorderRadius.circular(17),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
              ),
            ),
          ),
          // Positioned.fill: sem ele a Row fica com a altura do texto,
          // alinhada no topo, e os rótulos saem do centro da cápsula.
          Positioned.fill(
            child: Row(
              children: [
                _seg('Livre', Icons.timer_outlined, !pomodoro,
                    () => controller.setPomodoroMode(false)),
                _seg('Pomodoro', Icons.repeat_rounded, pomodoro,
                    () => controller.setPomodoroMode(true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seg(String label, IconData icon, bool selected, VoidCallback onTap) {
    final color = selected ? TempusColors.text : TempusColors.textSub;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Presets ───────────────────────────────────────────────────────

class _Presets extends StatelessWidget {
  final TimerController controller;
  const _Presets({super.key, required this.controller});

  static const List<int> presets = [15, 25, 45, 60, 90];

  @override
  Widget build(BuildContext context) {
    final current = controller.initialDuration ~/ 60;
    final isCustom = !presets.contains(current);

    // Larguras iguais: os presets sempre cabem na tela, sem rolagem lateral.
    return Row(
      children: [
        for (final m in presets)
          Expanded(
            child: _Chip(
              label: m < 60
                  ? '$m'
                  : '${m ~/ 60}h${m % 60 > 0 ? '${m % 60}' : ''}',
              unit: m < 60 ? 'min' : null,
              selected: current == m,
              onTap: () {
                HapticFeedback.selectionClick();
                controller.setDuration(m);
              },
            ),
          ),
        Expanded(
          child: Tooltip(
            message: isCustom
                ? 'Personalizado: ${formatMinutes(current)}'
                : 'Duração personalizada',
            child: _Chip(
              icon: Icons.tune_rounded,
              selected: isCustom,
              onTap: () => _showCustomPicker(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showCustomPicker(BuildContext context) {
    HapticFeedback.selectionClick();
    var picked = Duration(seconds: controller.initialDuration);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetScaffold(
        title: 'Duração personalizada',
        subtitle: 'Escolha quanto tempo quer focar.',
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    pickerTextStyle: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: TempusColors.text,
                      fontSize: 22,
                    ),
                  ),
                ),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: picked,
                  onTimerDurationChanged: (d) => picked = d,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Definir duração',
              onTap: () {
                // Aplica só ao confirmar (antes cada giro do seletor
                // gravava nas preferências).
                if (picked.inMinutes > 0) {
                  controller.setDuration(picked.inMinutes);
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String? label;
  final String? unit;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    this.label,
    this.unit,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? TempusColors.bg : TempusColors.text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : TempusColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.white : TempusColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon,
                    size: 18,
                    color: selected ? TempusColors.bg : TempusColors.textSub),
              if (label != null)
                Text(
                  label!,
                  maxLines: 1,
                  style: TextStyle(
                    color: fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              if (unit != null)
                Text(
                  unit!,
                  style: TextStyle(
                    color: selected
                        ? TempusColors.bg.withValues(alpha: 0.55)
                        : TempusColors.textSub,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pomodoro info ─────────────────────────────────────────────────

class _PomodoroInfo extends StatelessWidget {
  final TimerController controller;
  const _PomodoroInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final done = controller.pomodoroRound % 4;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            final filled = i < done;
            final current = i == done;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: current ? 26 : 10,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: filled
                    ? TempusColors.accent
                    : current
                        ? TempusColors.accent.withValues(alpha: 0.35)
                        : TempusColors.border,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        const Text(
          '25 min foco · 5 min pausa · pausa longa a cada 4',
          style: TextStyle(
            color: TempusColors.textSub,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Gyroscope 3D tilt ─────────────────────────────────────────────
// Inclinação sutil guiada pelo acelerômetro. O ticker só roda enquanto há
// movimento a interpolar (antes rodava a 60fps indefinidamente, inclusive
// com a aba fora de vista).

class _GyroTilt3D extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const _GyroTilt3D({required this.child, this.enabled = true});

  @override
  State<_GyroTilt3D> createState() => _GyroTilt3DState();
}

class _GyroTilt3DState extends State<_GyroTilt3D>
    with SingleTickerProviderStateMixin {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  late final AnimationController _driver;

  double _targetX = 0.0, _targetY = 0.0;
  final ValueNotifier<Offset> _tilt = ValueNotifier(Offset.zero);

  static const double _maxTilt = 0.09;
  static const double _lerp = 0.08;

  @override
  void initState() {
    super.initState();
    _driver = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_onFrame);
    if (widget.enabled) _subscribe();
  }

  void _subscribe() {
    try {
      // ignore: deprecated_member_use
      _accelSub = accelerometerEvents.listen(
        (e) {
          _targetY = (-e.x / 9.8 * _maxTilt).clamp(-_maxTilt, _maxTilt);
          _targetX = (e.y / 9.8 * _maxTilt * 0.6).clamp(-_maxTilt, _maxTilt);
          final cur = _tilt.value;
          if (((cur.dx - _targetX).abs() > 0.0005 ||
                  (cur.dy - _targetY).abs() > 0.0005) &&
              !_driver.isAnimating) {
            _driver.repeat();
          }
        },
        onError: (_) {},
        cancelOnError: true,
      );
    } catch (_) {
      // Sensor indisponível (emulador) — sem inclinação.
    }
  }

  void _onFrame() {
    final cur = _tilt.value;
    final nx = cur.dx + (_targetX - cur.dx) * _lerp;
    final ny = cur.dy + (_targetY - cur.dy) * _lerp;
    if ((nx - cur.dx).abs() < 0.0002 && (ny - cur.dy).abs() < 0.0002) {
      _driver.stop();
      return;
    }
    _tilt.value = Offset(nx, ny);
  }

  @override
  void dispose() {
    _driver.dispose();
    _accelSub?.cancel();
    _tilt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: _tilt,
      child: widget.child,
      builder: (context, t, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(t.dx)
          ..rotateY(t.dy),
        child: child,
      ),
    );
  }
}
