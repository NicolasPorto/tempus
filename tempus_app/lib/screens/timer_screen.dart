import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus_app/controller/timer_controller.dart';
import 'package:tempus_app/services/supabase_service.dart';
import '../theme/app_theme.dart';

import '../widgets/common/ui.dart';
import '../widgets/goal_sheet.dart';
import '../widgets/timer_controls.dart';
import '../widgets/subject_manager_modal.dart';
import '../widgets/timer_components/subject_selector.dart';
import '../widgets/timer_components/empty_subject_card.dart';
import '../widgets/session_summary_overlay.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) => const _TimerScreenContent();
}

class _TimerScreenContent extends StatefulWidget {
  const _TimerScreenContent();

  @override
  State<_TimerScreenContent> createState() => _TimerScreenContentState();
}

class _TimerScreenContentState extends State<_TimerScreenContent>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  late final AnimationController _focusIn;
  bool _wasFocusMode = false;
  TimerController? _timerController;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _focusIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

    // Respiração lenta do anel enquanto o foco está ativo (≈ 7 resp./min).
    if (controller.isRunning && !_breath.isAnimating) {
      _breath.repeat(reverse: true);
    } else if (!controller.isRunning && _breath.isAnimating) {
      _breath.stop();
      _breath.animateTo(0.0, duration: const Duration(milliseconds: 400));
    }

    if (controller.isFocusMode && !_wasFocusMode) {
      _focusIn.forward(from: 0.0);
    }
    _wasFocusMode = controller.isFocusMode;
  }

  @override
  void dispose() {
    _timerController?.removeListener(_onControllerUpdate);
    _breath.dispose();
    _focusIn.dispose();
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
    final isFocus =
        context.select<TimerController, bool>((c) => c.isFocusMode);
    final controller = context.read<TimerController>();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: controller.handleUserInteraction,
      onPanDown: (_) => controller.handleUserInteraction(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: isFocus
            ? _FocusView(
                key: const ValueKey('focus'),
                breath: _breath,
                enter: _focusIn,
              )
            : _MainView(
                key: const ValueKey('main'),
                onManageSubjects: () => _showSubjectManagerModal(context),
              ),
      ),
    );
  }
}

// ── Main view ─────────────────────────────────────────────────────

class _MainView extends StatelessWidget {
  final VoidCallback onManageSubjects;
  const _MainView({super.key, required this.onManageSubjects});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TimerController>();
    final media = MediaQuery.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, media.padding.top + 4, 20, media.padding.bottom + 110),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GreetingHeader(streak: controller.streak),
                SubjectSelector(
                  subjects: controller.subjects,
                  selectedSubject: controller.selectedSubject,
                  isLoading: controller.isLoading,
                  onManageTap: onManageSubjects,
                  onSubjectChanged: controller.selectSubject,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: controller.focusTask == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _FocusTaskChip(controller: controller),
                        ),
                ),
                const SizedBox(height: 26),
                const TimerControls(key: ValueKey('timer_controls_main')),
                const SizedBox(height: 30),
                if (controller.subjects.isEmpty && !controller.isLoading)
                  EmptySubjectCard(onCreateTap: onManageSubjects)
                else
                  _TodayCard(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final int streak;
  const _GreetingHeader({required this.streak});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 5
        ? 'Boa madrugada'
        : hour < 12
            ? 'Bom dia'
            : hour < 18
                ? 'Boa tarde'
                : 'Boa noite';
    final name =
        context.read<SupabaseService>().displayName.split(' ').first;
    final date =
        '${kWeekdays[now.weekday - 1]}, ${now.day} ${kMonthsShort[now.month - 1]}';

    return PageHeader(
      eyebrow: date,
      title: '$greeting, $name',
      subtitle: const Text('Pronto para uma sessão de foco?'),
      trailing: streak > 0 ? _StreakBadge(streak: streak) : null,
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$streak ${streak == 1 ? 'dia seguido' : 'dias seguidos'}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: TempusColors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: TempusColors.amber.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department_rounded,
                color: TempusColors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: const TextStyle(
                color: TempusColors.amber,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusTaskChip extends StatelessWidget {
  final TimerController controller;
  const _FocusTaskChip({required this.controller});

  @override
  Widget build(BuildContext context) {
    final task = controller.focusTask!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: TempusColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(TempusRadius.md),
        border: Border.all(color: TempusColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.task_alt_rounded,
              size: 16, color: TempusColors.accentSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(
                  text: 'Tarefa  ',
                  style: TextStyle(
                      color: TempusColors.textSub,
                      fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: task.title,
                  style: const TextStyle(
                      color: TempusColors.text, fontWeight: FontWeight.w700),
                ),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Desvincular tarefa',
            onPressed: controller.clearFocusTask,
            icon: const Icon(Icons.close_rounded,
                size: 18, color: TempusColors.textSub),
          ),
        ],
      ),
    );
  }
}

/// Resumo do dia: minutos estudados vs. meta, com anel de progresso.
class _TodayCard extends StatelessWidget {
  final TimerController controller;
  const _TodayCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final minutes = controller.dailyMinutes;
    final goal = controller.dailyGoalMinutes;
    final hasGoal = goal > 0;
    final progress = hasGoal ? (minutes / goal).clamp(0.0, 1.0) : 0.0;
    final reached = hasGoal && progress >= 1.0;
    final accent = reached ? TempusColors.green : TempusColors.accent;

    String headline;
    String detail;
    if (!hasGoal) {
      headline = minutes > 0
          ? '${formatMinutes(minutes)} hoje'
          : 'Defina uma meta diária';
      detail = 'Metas ajudam a manter a constância.';
    } else if (reached) {
      headline = 'Meta do dia atingida!';
      detail = '${formatMinutes(minutes)} de ${formatMinutes(goal)} · mandou bem';
    } else {
      headline = '${formatMinutes(minutes)} de ${formatMinutes(goal)}';
      detail = 'Faltam ${formatMinutes(goal - minutes)} para a meta';
    }

    return TempusCard(
      onTap: () => showDailyGoalSheet(context, controller),
      padding: const EdgeInsets.all(16),
      borderColor:
          reached ? TempusColors.green.withValues(alpha: 0.35) : null,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: hasGoal ? progress : 0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: TempusColors.surfaceHigher,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                ),
                Icon(
                  reached
                      ? Icons.check_rounded
                      : hasGoal
                          ? Icons.flag_rounded
                          : Icons.add_rounded,
                  color: accent,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HOJE',
                  style: TextStyle(
                    color: TempusColors.textSub,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  headline,
                  style: TextStyle(
                    color: reached ? TempusColors.green : TempusColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: TempusColors.textSub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: TempusColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

// ── Focus view ────────────────────────────────────────────────────

class _FocusView extends StatelessWidget {
  final Animation<double> breath;
  final Animation<double> enter;

  const _FocusView({super.key, required this.breath, required this.enter});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TimerController>();
    final color = phaseColorOf(controller);
    final subject = controller.selectedSubject;
    final task = controller.focusTask;
    final media = MediaQuery.of(context);

    final fade = CurvedAnimation(parent: enter, curve: Curves.easeOut);
    final zoom = Tween<double>(begin: 0.86, end: 1.0)
        .animate(CurvedAnimation(parent: enter, curve: Curves.easeOutBack));
    final breathScale = Tween<double>(begin: 1.0, end: 1.02)
        .animate(CurvedAnimation(parent: breath, curve: Curves.easeInOut));

    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black)),
        // Brilho ambiente na cor da matéria/fase.
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.25),
                radius: 0.9,
                colors: [
                  color.withValues(alpha: controller.isRunning ? 0.16 : 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        FadeTransition(
          opacity: fade,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  if (subject != null)
                    _FocusSubjectPill(name: subject.name, color: color),
                  if (task != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      task.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TempusColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const Spacer(),
                  ScaleTransition(
                    scale: zoom,
                    child: ScaleTransition(
                      scale: breathScale,
                      child: const TimerControls(
                        key: ValueKey('timer_controls_focus'),
                        focusLayout: true,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: controller.isRunning &&
                            controller.focusQuote.isNotEmpty
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      '“${controller.focusQuote}”',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedOpacity(
                    opacity: controller.isRunning ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.dark_mode_outlined,
                            size: 14, color: TempusColors.textMuted),
                        SizedBox(width: 6),
                        Text(
                          'A tela escurece sozinha para poupar bateria',
                          style: TextStyle(
                            color: TempusColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: media.padding.bottom > 0 ? 8 : 20),
                ],
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
            task: controller.summaryTask,
            onCompleteTask: controller.completeSummaryTask,
            onDismiss: controller.dismissSessionSummary,
            onContinue: controller.continueAfterSummary,
          ),
      ],
    );
  }
}

class _FocusSubjectPill extends StatelessWidget {
  final String name;
  final Color color;
  const _FocusSubjectPill({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: TempusColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
