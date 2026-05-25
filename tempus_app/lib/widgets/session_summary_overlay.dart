import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import 'common/confetti_overlay.dart';

class SessionSummaryOverlay extends StatefulWidget {
  final Subject subject;
  final int minutesStudied;
  final int dailyMinutes;
  final int dailyGoalMinutes;
  final VoidCallback onDismiss;
  final VoidCallback onContinue;

  const SessionSummaryOverlay({
    super.key,
    required this.subject,
    required this.minutesStudied,
    required this.dailyMinutes,
    required this.dailyGoalMinutes,
    required this.onDismiss,
    required this.onContinue,
  });

  @override
  State<SessionSummaryOverlay> createState() => _SessionSummaryOverlayState();
}

class _SessionSummaryOverlayState extends State<SessionSummaryOverlay>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOutBack),
    );

    _enterCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  String _fmt(int minutes) {
    if (minutes == 0) return '0 min';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
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
        color: Colors.black.withValues(alpha: 0.88),
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated checkmark
                  ScaleTransition(
                    scale: _checkScale,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: TempusColors.gradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TempusColors.accent.withValues(alpha: 0.45),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Sessão Concluída!',
                    style: TextStyle(
                      color: TempusColors.text,
                      fontSize: 28,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: subjectColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.subject.name}  ·  ${_fmt(widget.minutesStudied)}',
                        style: const TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 15,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Daily goal card
                  if (hasGoal) ...[
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: TempusColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: goalReached
                              ? TempusColors.green.withValues(alpha: 0.4)
                              : TempusColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goalReached ? '🎉 Meta do dia atingida!' : 'Meta do dia',
                                style: TextStyle(
                                  color: goalReached
                                      ? TempusColors.green
                                      : TempusColors.textSub,
                                  fontSize: 13,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${_fmt(widget.dailyMinutes)} / ${_fmt(widget.dailyGoalMinutes)}',
                                style: const TextStyle(
                                  color: TempusColors.text,
                                  fontSize: 13,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: goalProgress,
                              backgroundColor: TempusColors.border,
                              valueColor: AlwaysStoppedAnimation(
                                goalReached
                                    ? TempusColors.green
                                    : TempusColors.accent,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Continue button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onContinue();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: TempusColors.gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: TempusColors.accent.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Continuar Estudando',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dismiss button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onDismiss();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: TempusColors.border),
                      ),
                      child: const Text(
                        'Encerrar por hoje',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 15,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
