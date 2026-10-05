import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'common/confetti_overlay.dart';
import 'common/ui.dart';

class SessionSummaryOverlay extends StatefulWidget {
  final Subject subject;
  final int minutesStudied;
  final int dailyMinutes;
  final int dailyGoalMinutes;
  final TaskItem? task;
  final Future<void> Function()? onCompleteTask;
  final VoidCallback onDismiss;
  final VoidCallback onContinue;

  const SessionSummaryOverlay({
    super.key,
    required this.subject,
    required this.minutesStudied,
    required this.dailyMinutes,
    required this.dailyGoalMinutes,
    this.task,
    this.onCompleteTask,
    required this.onDismiss,
    required this.onContinue,
  });

  @override
  State<SessionSummaryOverlay> createState() => _SessionSummaryOverlayState();
}

class _SessionSummaryOverlayState extends State<SessionSummaryOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;

  /// Guarda a tarefa localmente: após concluí-la o controller limpa a
  /// referência, mas o cartão continua visível com o estado "concluída".
  TaskItem? _task;
  bool _taskDone = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);

    _enterCtrl.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _checkCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(widget.subject.colorValue);
    final hasGoal = widget.dailyGoalMinutes > 0;
    final goalProgress = hasGoal
        ? (widget.dailyMinutes / widget.dailyGoalMinutes).clamp(0.0, 1.0)
        : 0.0;
    final goalReached = goalProgress >= 1.0;

    return ConfettiOverlay(
      active: goalReached,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          color: Colors.black.withValues(alpha: 0.92),
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _checkScale,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color.lerp(subjectColor, Colors.white, 0.2)!,
                                subjectColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: subjectColor.withValues(alpha: 0.5),
                                blurRadius: 36,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 46),
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'SESSÃO CONCLUÍDA',
                        style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.minutesStudied),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Text(
                          formatMinutes(v),
                          style: const TextStyle(
                            color: TempusColors.text,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                            height: 1.05,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                                color: subjectColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'de foco em ${widget.subject.name}',
                            style: const TextStyle(
                              color: TempusColors.textSub,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (_task != null) ...[
                        const SizedBox(height: 26),
                        _TaskCompletionCard(
                          title: _task!.title,
                          done: _taskDone,
                          color: subjectColor,
                          onTap: _taskDone
                              ? null
                              : () async {
                                  setState(() => _taskDone = true);
                                  await widget.onCompleteTask?.call();
                                },
                        ),
                      ],
                      if (hasGoal) ...[
                        SizedBox(height: _task != null ? 12 : 26),
                        _GoalCard(
                          daily: widget.dailyMinutes,
                          goal: widget.dailyGoalMinutes,
                          progress: goalProgress,
                          reached: goalReached,
                        ),
                      ],
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: 'Continuar estudando',
                        icon: Icons.play_arrow_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onContinue();
                        },
                      ),
                      const SizedBox(height: 10),
                      SecondaryButton(
                        label: 'Encerrar por hoje',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onDismiss();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskCompletionCard extends StatelessWidget {
  final String title;
  final bool done;
  final Color color;
  final VoidCallback? onTap;

  const _TaskCompletionCard({
    required this.title,
    required this.done,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TempusCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderColor: done
          ? TempusColors.green.withValues(alpha: 0.4)
          : TempusColors.border,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: done ? TempusColors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: done ? TempusColors.green : TempusColors.textMuted,
                width: 1.6,
              ),
            ),
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done ? 'Tarefa concluída' : 'Terminou a tarefa?',
                  style: TextStyle(
                    color: done ? TempusColors.green : TempusColors.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TempusColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: TempusColors.textSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final int daily;
  final int goal;
  final double progress;
  final bool reached;

  const _GoalCard({
    required this.daily,
    required this.goal,
    required this.progress,
    required this.reached,
  });

  @override
  Widget build(BuildContext context) {
    final color = reached ? TempusColors.green : TempusColors.accent;
    return TempusCard(
      padding: const EdgeInsets.all(16),
      borderColor: reached ? TempusColors.green.withValues(alpha: 0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(reached ? Icons.emoji_events_rounded : Icons.flag_rounded,
                  color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reached ? 'Meta do dia atingida!' : 'Meta do dia',
                  style: TextStyle(
                    color: reached ? TempusColors.green : TempusColors.textSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${formatMinutes(daily)} / ${formatMinutes(goal)}',
                style: const TextStyle(
                  color: TempusColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                backgroundColor: TempusColors.surfaceHigher,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
