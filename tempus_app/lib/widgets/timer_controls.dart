import 'dart:async';
import 'package:flutter/material.dart';
import '../models/subject.dart';
import 'timer_painter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TimerControls extends StatefulWidget {
  final Subject? selectedSubject;

  const TimerControls({super.key, required this.selectedSubject});

  @override
  State<TimerControls> createState() => _TimerControlsState();
}

class _TimerControlsState extends State<TimerControls> {
  static const int _initialDuration = 25 * 60; // 25 minutos em segundos
  int _currentDuration = _initialDuration;
  Timer? _timer;
  bool _isRunning = false;

  // Formata a duração em minutos:segundos (ex: 25:00)
  String get _formattedTime {
    final minutes = (_currentDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_currentDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // --- Funções de Controle do Timer ---

  void _startTimer() {
    if (widget.selectedSubject == null || _isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentDuration <= 0) {
        _stopTimer();
        // Você pode adicionar lógica de notificação ou de troca para o 'break' aqui
      } else {
        setState(() {
          _currentDuration--;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentDuration = _initialDuration; // Reseta para 25:00
    });
  }

  // A função de pausa apenas para o timer sem resetar a duração
  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  // Função chamada pelo botão principal
  void _toggleTimer() {
    if (widget.selectedSubject == null) return;

    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  // Limpa o timer quando o widget é descartado
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Se a matéria mudar, paramos e resetamos o timer
  @override
  void didUpdateWidget(covariant TimerControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSubject != widget.selectedSubject) {
      _stopTimer();
    }
  }

  // --- UI do Timer ---

  @override
  Widget build(BuildContext context) {
    // Verifica se há uma matéria selecionada para habilitar os botões
    final isSubjectSelected = widget.selectedSubject != null;

    // Texto de Status
    String statusText;
    if (!isSubjectSelected) {
      statusText = 'Selecione uma matéria';
    } else if (_isRunning) {
      statusText = 'Foco em andamento';
    } else if (_currentDuration < _initialDuration) {
      statusText = 'Pausado';
    } else {
      statusText = 'Pressione para começar';
    }

    // Cor do botão Iniciar/Pausar
    final playPauseButtonOpacity = isSubjectSelected ? 1.0 : 0.5;

    // Ícone e texto do botão Iniciar/Pausar
    final playPauseIcon = _isRunning ? Icons.pause : Icons.play_arrow;
    final playPauseText = _isRunning ? 'Pausar Foco' : 'Iniciar Foco';
    final bool showResetButton =
        _isRunning || (_currentDuration < _initialDuration);

    return Column(
      children: [
        // 1. DISPLAY DO TIMER E TEXTO DE STATUS
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
                  child: CustomPaint(
                    painter: TimerPainter(
                      backgroundColor: const Color(0xFF2C2C34),
                      progressColor: Color(
                        widget.selectedSubject?.colorValue ?? 0xFF9042FF,
                      ),
                      progress: _currentDuration / _initialDuration,
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
          child: Container(
            width: 230,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleTimer,
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
                    onTap: _stopTimer,
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
