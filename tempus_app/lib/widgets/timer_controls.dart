import 'dart:async';
import 'package:flutter/material.dart';
import '../models/subject.dart';
import 'timer_painter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TimerControls extends StatefulWidget {
  final Subject? selectedSubject;
  final VoidCallback onToggleTimer; // Novo: Lidar com clique no botão
  final VoidCallback? onResetTimer; // Novo: Lidar com clique no botão Reset
  final int currentDuration; // Novo: Tempo restante atual
  final int initialDuration; // Novo: Duração total (25 min)
  final bool isRunning; // Novo: Estado de execução

  const TimerControls({
    super.key,
    required this.selectedSubject,
    required this.onToggleTimer, // Deve ser required
    this.onResetTimer,
    required this.currentDuration, // Deve ser required
    required this.initialDuration, // Deve ser required
    required this.isRunning, // Deve ser required
  });

  @override
  State<TimerControls> createState() => _TimerControlsState();
}

class _TimerControlsState extends State<TimerControls>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  // Lógica de formatação de tempo (usa as props do widget)
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

  @override
  Widget build(BuildContext context) {
    final isSubjectSelected = widget.selectedSubject != null;
    final bool isPaused =
        widget.currentDuration < widget.initialDuration && !widget.isRunning;

    String statusText;
    if (!isSubjectSelected) {
      statusText = 'Selecione uma matéria';
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
                        progressColor: Color(
                          widget.selectedSubject?.colorValue ?? 0xFF9042FF,
                        ),
                        progress:
                            widget.currentDuration / widget.initialDuration,
                      ),
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
                        color: Colors.white,
                        fontSize: 80,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                        letterSpacing: -2.40,
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
        const SizedBox(height: 40),

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
                              'lib/assets/icons/icon_repeat.svg',
                              width: 20,
                              height: 20,
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
}
