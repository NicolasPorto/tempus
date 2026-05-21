import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/subject.dart';
import 'timer_painter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../controller/timer_controller.dart';

extension GradientColor on Color {
  static const LinearGradient purpleBlueGradient = LinearGradient(
    colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  LinearGradient get gradient => purpleBlueGradient;
}

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

class _TimerControlsState extends State<TimerControls>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  String get _formattedTime {
    final minutes = (widget.currentDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (widget.currentDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimerControls oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 120),
      vsync: this,
    )..repeat();
  }

  Widget _buildTimeSelector() {
    final bool canChange =
        !widget.isRunning && widget.currentDuration == widget.initialDuration;

    if (!canChange) return const SizedBox(height: 100);

    if (widget.isPomodoroMode) {
      return _buildPomodoroPhaseSelector();
    }

    final List<int> presets = [15, 20, 25, 30];
    int currentMinutes = widget.initialDuration ~/ 60;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            "Duração do Foco",
            style: TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 14,
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...presets.map(
                (min) => _buildPresetButton(min, currentMinutes == min),
              ),
              _buildPickerButton(currentMinutes),
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
    Color phaseColor;

    switch (phase) {
      case PomodoroPhase.work:
        phaseLabel = 'Sessão de Foco';
        phaseDuration = '25 min';
        phaseColor = const Color(0xFFAC46FF);
        break;
      case PomodoroPhase.shortBreak:
        phaseLabel = 'Pausa Curta';
        phaseDuration = '5 min';
        phaseColor = const Color(0xFF00C850);
        break;
      case PomodoroPhase.longBreak:
        phaseLabel = 'Pausa Longa';
        phaseDuration = '15 min';
        phaseColor = const Color(0xFF2B7FFF);
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: phaseColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      phaseLabel,
                      style: TextStyle(
                        color: phaseColor,
                        fontSize: 13,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· $phaseDuration',
                      style: TextStyle(
                        color: phaseColor.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Round progress dots (4 pomodoros = 1 long break cycle)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final completed = i < (round % 4);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? const Color(0xFFAC46FF)
                      : const Color(0xFF2C2C34),
                  border: Border.all(
                    color: completed
                        ? const Color(0xFFAC46FF)
                        : const Color(0xFF444444),
                    width: 1,
                  ),
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

    final bool isPaused =
        widget.currentDuration < widget.initialDuration && !widget.isRunning;
    if (isPaused) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTogglePomodoroMode?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isPomodoroMode
              ? const Color(0xFFAC46FF).withOpacity(0.15)
              : const Color(0xFF171717),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isPomodoroMode
                ? const Color(0xFFAC46FF).withOpacity(0.5)
                : const Color(0x19FFFEFE),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat,
              size: 14,
              color: widget.isPomodoroMode
                  ? const Color(0xFFAC46FF)
                  : const Color(0xFFA0A0A0),
            ),
            const SizedBox(width: 6),
            Text(
              'Modo Pomodoro',
              style: TextStyle(
                color: widget.isPomodoroMode
                    ? const Color(0xFFAC46FF)
                    : const Color(0xFFA0A0A0),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.fromARGB(83, 172, 70, 255)
              : const Color(0xFF171717),
          gradient: isSelected ? GradientColor.purpleBlueGradient : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0x19FFFEFE),
            width: 1,
          ),
        ),
        child: Text(
          "$minutes",
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFA0A0A0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton(int currentMinutes) {
    return GestureDetector(
      onTap: () => _showCupertinoTimePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x33AC46FF), width: 1),
        ),
        child: const Icon(Icons.more_time, color: Color(0xFFAC46FF), size: 20),
      ),
    );
  }

  void _showCupertinoTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: const Color(0xFF171717),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Color(0xFFA0A0A0)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Confirmar",
                      style: TextStyle(
                        color: Color(0xFFAC46FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(seconds: widget.initialDuration),
                onTimerDurationChanged: (Duration newDuration) {
                  if (newDuration.inMinutes > 0) {
                    widget.onDurationChanged?.call(newDuration.inMinutes);
                  }
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
            statusText = 'Iniciar sessão de foco';
            break;
          case PomodoroPhase.shortBreak:
            statusText = 'Iniciar pausa curta';
            break;
          case PomodoroPhase.longBreak:
            statusText = 'Iniciar pausa longa';
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

    final playPauseButtonOpacity = isSubjectSelected ? 1.0 : 0.5;
    final playPauseIcon = widget.isRunning ? Icons.pause : Icons.play_arrow;
    final playPauseText = widget.isRunning ? 'Pausar Foco' : 'Iniciar Foco';
    final bool showResetButton = widget.isRunning || isPaused;

    // Use phase color for the progress arc in Pomodoro mode
    Color progressColor;
    if (widget.isPomodoroMode) {
      switch (widget.pomodoroPhase) {
        case PomodoroPhase.work:
          progressColor = Color(widget.selectedSubject?.colorValue ?? 0xFF9042FF);
          break;
        case PomodoroPhase.shortBreak:
          progressColor = const Color(0xFF00C850);
          break;
        case PomodoroPhase.longBreak:
          progressColor = const Color(0xFF2B7FFF);
          break;
      }
    } else {
      progressColor = Color(widget.selectedSubject?.colorValue ?? 0xFF9042FF);
    }

    return Column(
      children: [
        Center(
          child: Container(
            width: 346,
            height: 346,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.00, 0.00),
                end: Alignment(1.00, 1.00),
                colors: [Color(0xCC171717), Color(0xCC0A0A0A)],
              ),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2, color: Color(0x19FFFEFE)),
                borderRadius: BorderRadius.circular(48),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 50,
                  offset: Offset(0, 25),
                  spreadRadius: -12,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: RotationTransition(
                    turns: _rotationController,
                    child: CustomPaint(
                      painter: TimerPainter(
                        backgroundColor: const Color(0xFF2C2C34),
                        progressColor: progressColor,
                        progress:
                            widget.currentDuration / widget.initialDuration,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.onToggleTimer();
                      },
                      child: Text(
                        _formattedTime,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                          letterSpacing: -2.40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          statusText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 16,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        _buildTimeSelector(),

        const SizedBox(height: 8),

        _buildPomodoroToggle(),

        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 230,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onToggleTimer,
                    child: Opacity(
                      opacity: playPauseButtonOpacity,
                      child: Container(
                        height: 56,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(0.00, 0.50),
                            end: Alignment(1.00, 0.50),
                            colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(playPauseIcon, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              playPauseText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (showResetButton) ...[
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: widget.onResetTimer,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: ShapeDecoration(
                        color: const Color(0x7F171717),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 2,
                            color: Color(0x19FFFEFE),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 15,
                            offset: Offset(0, 10),
                            spreadRadius: -3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: SvgPicture.asset(
                              'lib/assets/icons/icon_back.svg',
                              width: 28,
                              height: 28,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showManualInput(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0x19FFFEFE)),
        ),
        title: const Text(
          "Definir minutos",
          style: TextStyle(color: Colors.white, fontFamily: 'Arimo'),
        ),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Ex: 45",
            hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFAC46FF)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2B7FFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Color(0xFFA0A0A0)),
            ),
          ),
          TextButton(
            onPressed: () {
              final int? value = int.tryParse(textController.text);
              if (value != null && value > 0 && value <= 500) {
                widget.onDurationChanged?.call(value);
                Navigator.pop(context);
              }
            },
            child: const Text(
              "OK",
              style: TextStyle(
                color: Color(0xFFAC46FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientPillThumb extends SliderComponentShape {
  final LinearGradient gradient;

  const GradientPillThumb({required this.gradient});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(36.0, 24.0);
  }

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
    final Canvas canvas = context.canvas;

    const double width = 36.0;
    const double height = 24.0;
    final Rect rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    final Color shadowColor = gradient.colors.last.withOpacity(0.5);
    final Paint shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final RRect rRectShadow = RRect.fromRectAndRadius(
      rect.translate(0, 2),
      const Radius.circular(12.0),
    );
    canvas.drawRRect(rRectShadow, shadowPaint);

    final RRect rRectGradient = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(12.0),
    );
    canvas.drawRRect(
      rRectGradient,
      Paint()..shader = gradient.createShader(rect),
    );
  }
}

class RecessedTrackShape extends SliderTrackShape {
  final Color baseColor;
  final LinearGradient activeGradient;

  const RecessedTrackShape({
    required this.baseColor,
    required this.activeGradient,
  });

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight! * 1.5;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
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

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Canvas canvas = context.canvas;

    final RRect fullTrack = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        trackRect.left,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
      ),
      const Radius.circular(6.0),
    );

    canvas.drawRRect(fullTrack, Paint()..color = baseColor);

    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final Paint activePaint = Paint()
      ..shader = activeGradient.createShader(activeRect);

    final RRect activeTrack = RRect.fromRectAndRadius(
      activeRect,
      const Radius.circular(6.0),
    );
    canvas.drawRRect(activeTrack, activePaint);
  }
}
