import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/timer_controls.dart';
import '../widgets/subject_manager_modal.dart';
import '../models/subject.dart';
import '../services/storage_service.dart';

final ValueNotifier<bool> isFocusModeNotifier = ValueNotifier(false);

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Center(child: _TimerScreenContent()),
    );
  }
}

class _TimerScreenContent extends StatefulWidget {
  const _TimerScreenContent();

  @override
  State<_TimerScreenContent> createState() => _TimerScreenContentState();
}

class _TimerScreenContentState extends State<_TimerScreenContent> {
  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  bool _isLoading = true;
  bool _isFocusMode = false;
  static const int _initialDuration = 25 * 60;
  int _currentDuration = _initialDuration;
  Timer? _timer;
  bool _isRunning = false;
  void _startTimer() {
    if (_selectedSubject == null || _isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _enterFocusMode();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentDuration <= 0) {
        _stopTimer();
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
      _currentDuration = _initialDuration;
    });

    if (_isFocusMode) {
      _exitFocusMode();
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _toggleTimer() {
    if (_selectedSubject == null) return;

    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _resetTimer() {
    _stopTimer();
    _exitFocusMode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  void _enterFocusMode() {
    setState(() => _isFocusMode = true);
    isFocusModeNotifier.value = true;
  }

  void _exitFocusMode() {
    setState(() => _isFocusMode = false);
    isFocusModeNotifier.value = false;
  }

  void _loadSubjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final subjects = StorageService.instance.subjects;

      setState(() {
        _subjects = subjects;
        if (_selectedSubject == null || !subjects.contains(_selectedSubject)) {
          _selectedSubject = subjects.isNotEmpty ? subjects.first : null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSubjectManagerModal() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const SubjectManagerModal();
      },
    );

    _loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Conteúdo principal que será animado
        SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500), // Duração da animação
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Combina FadeTransition e ScaleTransition
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation.drive(
                    Tween<double>(begin: 0.8, end: 1.0).chain(
                      CurveTween(curve: Curves.easeOutCubic),
                    ), // Curva de aceleração
                  ),
                  child: child,
                ),
              );
            },
            switchInCurve: Curves.easeOutCubic, // Curva para o widget que entra
            switchOutCurve: Curves.easeInCubic, // Curva para o widget que sai
            child:
                _isFocusMode // Usa o _isFocusMode para alternar as views
                ? _buildFocusView()
                : _buildMainView(),
          ),
        ),
      ],
    );
  }

  Widget _buildMainView() {
    return Center(
      key: const ValueKey('main_view'),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 378),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 162,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Center(
                      child: Container(
                        width: 250,
                        height: 50,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(0.00, 0.50),
                            end: Alignment(1.00, 0.50),
                            colors: [
                              Color(0x19AC46FF),
                              Color(0x192B7FFF),
                              Color(0x19F6329A),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0x19FFFEFE),
                            ),
                            borderRadius: BorderRadius.circular(33554400),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 25,
                              top: 21,
                              child: Opacity(
                                opacity: 0.57,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF05DF72),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        33554400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 45,
                              top: 13,
                              child: SizedBox(
                                width: 300,
                                height: 24,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Text(
                                        'Sistema Pomodoro Ativo',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFFA0A0A0),
                                          fontSize: 16,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 66,
                    child: SizedBox(
                      height: 36,
                      child: Center(
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'Estudo Focado',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 114,
                    child: SizedBox(
                      height: 48,
                      child: Center(
                        child: const Text(
                          'Organize seus estudos com o método Pomodoro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 16,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 32,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: SvgPicture.asset(
                                      'lib/assets/icons/icon_star.svg',
                                      width: 16,
                                      height: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Selecione a matéria',
                                    style: TextStyle(
                                      color: Color(0xFFD4D4D4),
                                      fontSize: 16,
                                      fontFamily: 'Arimo',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 110.59,
                                height: 32,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: SvgPicture.asset(
                                            'lib/assets/icons/icon_plus.svg',
                                            width: 16,
                                            height: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap:
                                              _showSubjectManagerModal, // Chama a função que recarrega após o modal
                                          child: const Text(
                                            'Gerenciar',
                                            style: TextStyle(
                                              color: Color(0xFFD4D4D4),
                                              fontSize: 16,
                                              fontFamily: 'Arimo',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: 36,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: ShapeDecoration(
                                  color: _subjects.isEmpty
                                      ? const Color(0x40171717)
                                      : const Color(0x7F171717),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: _subjects.isEmpty
                                          ? const Color(0x19FFFEFE).withOpacity(
                                              0.5,
                                            ) // Borda mais fraca
                                          : const Color(0x19FFFEFE),
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Subject>(
                                    value: _selectedSubject,
                                    icon: Opacity(
                                      opacity: _subjects.isEmpty ? 0.2 : 0.50,
                                      child: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFFD4D4D4),
                                      ),
                                    ),
                                    dropdownColor: const Color.fromARGB(
                                      202,
                                      23,
                                      23,
                                      23,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    isExpanded: true,

                                    onChanged: _subjects.isEmpty
                                        ? null
                                        : (Subject? newValue) {
                                            setState(() {
                                              _selectedSubject = newValue;
                                            });
                                          },

                                    hint: const Text(
                                      'Escolha uma matéria...',
                                      style: TextStyle(
                                        color: Color(0xFF717182),
                                        fontSize: 14,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
                                      ),
                                    ),

                                    items: _subjects.map((Subject subject) {
                                      final isSelected =
                                          subject == _selectedSubject;

                                      final textStyle = TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFFD4D4D4),
                                        fontSize: 14,
                                        fontFamily: 'Arimo',
                                        fontWeight: isSelected
                                            ? FontWeight
                                                  .w600 // Negrito para o selecionado
                                            : FontWeight.w400,
                                        height: 1.43,
                                      );

                                      return DropdownMenuItem<Subject>(
                                        value: subject,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  subject.colorValue,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Text(
                                              subject.name,
                                              style: textStyle,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                    selectedItemBuilder: (BuildContext context) {
                                      return _subjects.map<Widget>((
                                        Subject item,
                                      ) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (_selectedSubject != null)
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        _selectedSubject!
                                                            .colorValue,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  Text(
                                                    _selectedSubject!.name,
                                                    style: const TextStyle(
                                                      color: Color(0xFFF4F4F4),
                                                      fontSize: 14,
                                                      fontFamily: 'Arimo',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.43,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TimerControls(
                    key: const ValueKey('timer_controls'),
                    selectedSubject: _selectedSubject,
                    onToggleTimer: _toggleTimer, // LIGADO
                    onResetTimer: _resetTimer, // LIGADO
                    currentDuration: _currentDuration, // LIGADO
                    initialDuration: _initialDuration, // LIGADO
                    isRunning: _isRunning, // LIGADO
                  ),
                  const SizedBox(height: 40),

                  if (_subjects.isEmpty && !_isLoading)
                    Container(
                      width: double.infinity,
                      height: 170,
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(0.00, 0.00),
                          end: Alignment(1.00, 1.00),
                          colors: [Color(0x7F171717), Color(0x7F0A0A0A)],
                        ),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0x19FFFEFE),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 0,
                            right: 0,
                            top: 25,
                            child: Center(
                              child: Icon(
                                Icons.book,
                                color: Color(0xFFD4D4D4),
                                size: 32,
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 0,
                            right: 0,
                            top: 69,
                            child: Center(
                              child: Text(
                                'Adicione uma matéria para começar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFD4D4D4),
                                  fontSize: 16,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                ),
                              ),
                            ),
                          ),
                          // Botão Criar Matéria
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 109,
                            child: Center(
                              child: GestureDetector(
                                onTap: _showSubjectManagerModal,
                                child: Container(
                                  width: 138.69,
                                  height: 36,
                                  decoration: ShapeDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment(0.00, 0.50),
                                      end: Alignment(1.00, 0.50),
                                      colors: [
                                        Color(0xFFAC46FF),
                                        Color(0xFF2B7FFF),
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Criar Matéria',
                                        style: TextStyle(
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
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusView() {
    // 362 (altura total do conteúdo no _buildMainView)
    // Subtraímos a altura do _buildMainView para alinhar o TimerControls.
    // Usamos o SizedBox.shrink() no topo, mas precisamos manter o alinhamento
    // vertical do TimerControls, o que é desafiador em Column.
    // A melhor abordagem é calcular a altura exata.

    // No _buildFocusView, o único elemento acima do TimerControls é um SizedBox.
    // Altura calculada para manter a posição: 362px (do main)
    const double requiredTopSpacing = 200.0;

    return Center(
      key: const ValueKey('focus'),
      child: Column(
        children: [
          // Ajustado para 362px para alinhar o TimerControls verticalmente
          // na mesma posição do _buildMainView, compensando o espaço removido.
          const SizedBox(height: requiredTopSpacing), 
          TimerControls(
            key: const ValueKey('timer_controls'),
            selectedSubject: _selectedSubject,
            onToggleTimer: _toggleTimer,
            onResetTimer: _resetTimer,
            currentDuration: _currentDuration,
            initialDuration: _initialDuration,
            isRunning: _isRunning,
          ),
        ],
      ),
    );
  }
}
