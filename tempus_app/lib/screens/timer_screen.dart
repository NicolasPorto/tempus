import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tempus_app/controller/timer_controller.dart';
import 'package:tempus_app/services/supabase_service.dart';
import '../theme/app_theme.dart';

import '../widgets/timer_controls.dart';
import '../widgets/subject_manager_modal.dart';
import '../widgets/timer_components/subject_selector.dart';
import '../widgets/timer_components/empty_subject_card.dart';
import '../widgets/session_summary_overlay.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerController(
        supabaseService: Provider.of<SupabaseService>(context, listen: false),
      ),
      child: const _TimerScreenContent(),
    );
  }
}

class _TimerScreenContent extends StatefulWidget {
  const _TimerScreenContent();

  @override
  State<_TimerScreenContent> createState() => _TimerScreenContentState();
}

class _TimerScreenContentState extends State<_TimerScreenContent>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _focusSlideController;
  late Animation<Offset> _focusSlideAnimation;
  late Animation<double> _focusFadeAnimation;
  Animation<double>? _focusZoomAnimation;
  bool _wasFocusMode = false;
  TimerController? _timerController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.018).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _focusSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _focusSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _focusSlideController, curve: Curves.easeOutExpo),
    );
    _focusFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _focusSlideController, curve: Curves.easeOut),
    );
    _focusZoomAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _focusSlideController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = Provider.of<TimerController>(context, listen: false);
    if (_timerController != controller) {
      _timerController?.removeListener(_onControllerUpdate);
      _timerController = controller;
      _timerController!.addListener(_onControllerUpdate);
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final controller = _timerController!;

    if (controller.isRunning && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!controller.isRunning && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.animateTo(0.0,
          duration: const Duration(milliseconds: 400));
    }

    if (controller.isFocusMode && !_wasFocusMode) {
      _focusSlideController.forward(from: 0.0);
    }
    _wasFocusMode = controller.isFocusMode;
  }

  @override
  void dispose() {
    _timerController?.removeListener(_onControllerUpdate);
    _pulseController.dispose();
    _focusSlideController.dispose();
    super.dispose();
  }

  void _showSubjectManagerModal(BuildContext context) async {
    final controller = Provider.of<TimerController>(context, listen: false);
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const SubjectManagerModal(),
    );
    controller.loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TimerController>(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: controller.handleUserInteraction,
      onPanDown: (_) => controller.handleUserInteraction(),
      child: controller.isFocusMode
          ? _buildFocusView(context, controller)
          : _buildMainView(context, controller, topPadding),
    );
  }

  Widget _buildMainView(
      BuildContext context, TimerController controller, double topPadding) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TimerPageHeader(),
                const SizedBox(height: 20),
                SubjectSelector(
                  subjects: controller.subjects,
                  selectedSubject: controller.selectedSubject,
                  isLoading: controller.isLoading,
                  onManageTap: () => _showSubjectManagerModal(context),
                  onSubjectChanged: controller.selectSubject,
                ),

                // Daily progress chip
                if (!controller.isLoading && controller.dailyMinutes > 0) ...[
                  const SizedBox(height: 12),
                  _DailyProgressChip(
                    dailyMinutes: controller.dailyMinutes,
                    goalMinutes: controller.dailyGoalMinutes,
                    onSetGoal: () => _showGoalDialog(context, controller),
                  ),
                ] else if (!controller.isLoading &&
                    controller.dailyGoalMinutes == 0) ...[
                  const SizedBox(height: 12),
                  _SetGoalHint(
                    onTap: () => _showGoalDialog(context, controller),
                  ),
                ],

                const SizedBox(height: 32),

                ScaleTransition(
                  scale: _pulseAnimation,
                  child: TimerControls(
                    key: const ValueKey('timer_controls_main'),
                    selectedSubject: controller.selectedSubject,
                    onToggleTimer: controller.toggleTimer,
                    onResetTimer: controller.resetTimer,
                    onDurationChanged: (m) => controller.setDuration(m),
                    currentDuration: controller.currentDuration,
                    initialDuration: controller.initialDuration,
                    isRunning: controller.isRunning,
                    isPomodoroMode: controller.isPomodoroMode,
                    pomodoroPhase: controller.pomodoroPhase,
                    pomodoroRound: controller.pomodoroRound,
                    onTogglePomodoroMode: controller.togglePomodoroMode,
                  ),
                ),

                if (controller.subjects.isEmpty && !controller.isLoading) ...[
                  const SizedBox(height: 32),
                  EmptySubjectCard(
                    onCreateTap: () => _showSubjectManagerModal(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusView(BuildContext context, TimerController controller) {
    return Stack(
      children: [
        Container(color: Colors.black),
        FadeTransition(
          opacity: _focusFadeAnimation,
          child: SlideTransition(
            position: _focusSlideAnimation,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _focusZoomAnimation ?? const AlwaysStoppedAnimation(1.0),
                      child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: TimerControls(
                        key: const ValueKey('timer_controls_focus'),
                        selectedSubject: controller.selectedSubject,
                        onToggleTimer: controller.toggleTimer,
                        onResetTimer: controller.resetTimer,
                        onDurationChanged: (m) => controller.setDuration(m),
                        currentDuration: controller.currentDuration,
                        initialDuration: controller.initialDuration,
                        isRunning: controller.isRunning,
                        isPomodoroMode: controller.isPomodoroMode,
                        pomodoroPhase: controller.pomodoroPhase,
                        pomodoroRound: controller.pomodoroRound,
                        onTogglePomodoroMode: controller.togglePomodoroMode,
                      ),
                      ),
                    ),
                    if (controller.focusQuote.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      AnimatedOpacity(
                        opacity: controller.isRunning ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          '"${controller.focusQuote}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: TempusColors.textSub,
                            fontSize: 13,
                            fontFamily: 'Arimo',
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Session summary overlay
        if (controller.showingSessionSummary &&
            controller.summarySubject != null)
          SessionSummaryOverlay(
            subject: controller.summarySubject!,
            minutesStudied: controller.summaryMinutes,
            dailyMinutes: controller.dailyMinutes,
            dailyGoalMinutes: controller.dailyGoalMinutes,
            onDismiss: controller.dismissSessionSummary,
            onContinue: controller.continueAfterSummary,
          ),
      ],
    );
  }

  void _showGoalDialog(BuildContext context, TimerController controller) {
    int selectedGoal = controller.dailyGoalMinutes > 0
        ? controller.dailyGoalMinutes
        : 60;

    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: TempusColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: TempusColors.border),
          ),
          title: const Text(
            'Meta Diária',
            style: TextStyle(
              color: TempusColors.text,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quanto tempo quer estudar por dia?',
                style: TextStyle(
                  color: TempusColors.textSub,
                  fontFamily: 'Arimo',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                selectedGoal < 60
                    ? '$selectedGoal min'
                    : '${selectedGoal ~/ 60}h${selectedGoal % 60 > 0 ? ' ${selectedGoal % 60}min' : ''}',
                style: const TextStyle(
                  color: TempusColors.text,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
              ),
              Slider(
                value: selectedGoal.toDouble(),
                min: 15,
                max: 480,
                divisions: 31,
                activeColor: TempusColors.accent,
                inactiveColor: TempusColors.border,
                onChanged: (v) =>
                    setDialogState(() => selectedGoal = v.round()),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('15 min',
                      style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 11,
                          fontFamily: 'Arimo')),
                  Text('8h',
                      style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 11,
                          fontFamily: 'Arimo')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(
                      color: TempusColors.textSub, fontFamily: 'Arimo')),
            ),
            TextButton(
              onPressed: () {
                controller.setDailyGoal(selectedGoal);
                Navigator.pop(ctx);
              },
              child: const Text('Salvar',
                  style: TextStyle(
                      color: TempusColors.accent,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressChip extends StatelessWidget {
  final int dailyMinutes;
  final int goalMinutes;
  final VoidCallback onSetGoal;

  const _DailyProgressChip({
    required this.dailyMinutes,
    required this.goalMinutes,
    required this.onSetGoal,
  });

  String _fmt(int m) {
    if (m < 60) return '${m}min';
    final h = m ~/ 60;
    final min = m % 60;
    return min > 0 ? '${h}h ${min}min' : '${h}h';
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = goalMinutes > 0;
    final progress =
        hasGoal ? (dailyMinutes / goalMinutes).clamp(0.0, 1.0) : 0.0;
    final reached = progress >= 1.0;

    return GestureDetector(
      onTap: onSetGoal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: TempusColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: reached
                ? TempusColors.green.withValues(alpha: 0.4)
                : TempusColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              reached ? Icons.check_circle_rounded : Icons.today_rounded,
              color: reached ? TempusColors.green : TempusColors.textSub,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              hasGoal
                  ? 'Hoje: ${_fmt(dailyMinutes)} / ${_fmt(goalMinutes)}'
                  : 'Hoje: ${_fmt(dailyMinutes)}',
              style: TextStyle(
                color: reached ? TempusColors.green : TempusColors.textSub,
                fontSize: 12,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasGoal) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: TempusColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      reached ? TempusColors.green : TempusColors.accent,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetGoalHint extends StatelessWidget {
  final VoidCallback onTap;
  const _SetGoalHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TempusColors.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, color: TempusColors.textSub, size: 14),
            SizedBox(width: 6),
            Text(
              'Definir meta diária',
              style: TextStyle(
                color: TempusColors.textSub,
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
}

// ── Timer page header ─────────────────────────────────────────────

class _TimerPageHeader extends StatelessWidget {
  static const _weekdays = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo',
  ];
  static const _months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = _weekdays[now.weekday - 1];
    final date = '${now.day} ${_months[now.month - 1]}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => TempusColors.gradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: const Text(
                'Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$day · $date',
              style: const TextStyle(
                color: TempusColors.textSub,
                fontSize: 13,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
