import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../models/task.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import '../widgets/stats_components/weekly_activity_card.dart';
import '../widgets/stats_components/subjects_breakdown_card.dart';
import '../widgets/common/skeleton_widget.dart';
import 'session_history_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _screenshotCtrl = ScreenshotController();
  bool _isSharing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _sessionStats;
  Map<String, int> _timeSummary = {'real': 0, 'planned': 0};
  int? _sessionStreak;
  int _completedTasks = 0;
  int _totalTasks = 0;
  List<int> _weeklyActivity = List.filled(7, 0);
  Map<String, int> _subjectBreakdown = {};
  List<Subject> _subjects = [];
  int _dailyGoalMinutes = 0;
  int _dailyMinutes = 0;
  Map<String, int> _subjectGoals = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => _isLoading = true);
    final svc = context.read<SupabaseService>();

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final goals = <String, int>{};
      for (final key in prefs.getKeys()) {
        if (key.startsWith('subject_goal_')) {
          final id = key.replaceFirst('subject_goal_', '');
          goals[id] = prefs.getInt(key) ?? 0;
        }
      }
      setState(() {
        _dailyGoalMinutes = prefs.getInt('daily_goal_minutes') ?? 0;
        _subjectGoals = goals;
      });
    }

    try {
      final results = await Future.wait([
        svc.getSessionStats(),
        svc.getStreak(),
        svc.listTasks(),
        svc.getSessionTimeSummary(),
        svc.getWeeklyActivity(),
        svc.getSubjectBreakdown(),
        svc.listCategories(),
        svc.getDailyMinutes(),
      ]);

      if (mounted) {
        setState(() {
          _sessionStats = results[0] as Map<String, dynamic>;
          _sessionStreak = results[1] as int;
          final tasks = results[2] as List<TaskItem>;
          _totalTasks = tasks.length;
          _completedTasks = tasks.where((t) => t.done).length;
          _timeSummary = results[3] as Map<String, int>;
          _weeklyActivity = results[4] as List<int>;
          _subjectBreakdown = results[5] as Map<String, int>;
          _subjects = (results[6] as List)
              .map((c) => c.toSubject())
              .toList()
              .cast<Subject>();
          _dailyMinutes = results[7] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _shareStats() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final realMinutes = _timeSummary['real'] ?? 0;
      final streak = _sessionStreak ?? 0;
      final card = _StatsShareCard(
        totalMinutes: realMinutes,
        streak: streak,
        weeklyActivity: _weeklyActivity,
      );
      final bytes = await _screenshotCtrl.captureFromLongWidget(
        card,
        context: context,
        pixelRatio: 3.0,
        constraints: const BoxConstraints(maxWidth: 360),
      );
      final file = XFile.fromData(bytes,
          name: 'tempus_stats.png', mimeType: 'image/png');
      await Share.shareXFiles(
        [file],
        text: 'Minha semana de estudos no Tempus 📚',
      );
    } catch (e) {
      debugPrint('Share error: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  bool get _hasAnySessions =>
      (_timeSummary['real'] ?? 0) > 0 ||
      ((_sessionStats?['finishedSessions'] as num?)?.toInt() ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final int realMinutes = _timeSummary['real'] ?? 0;
    final int plannedMinutes = _timeSummary['planned'] ?? 0;
    final int finishedSessions =
        (_sessionStats?['finishedSessions'] as num?)?.toInt() ?? 0;
    final int avgMinutes =
        finishedSessions > 0 ? (realMinutes / finishedSessions).round() : 0;

    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: TempusColors.accent,
      backgroundColor: TempusColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.fromLTRB(20, topPadding + 8, 20, bottomPadding + 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              TempusColors.gradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: const Text(
                            'Estatísticas',
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
                        const SizedBox(height: 4),
                        const Text(
                          'Seu progresso de estudos',
                          style: TextStyle(
                            color: TempusColors.textSub,
                            fontSize: 13,
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share icon button
                  if (!_isLoading && _hasAnySessions) ...[
                    GestureDetector(
                      onTap: _shareStats,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _isSharing
                              ? TempusColors.accent.withValues(alpha: 0.2)
                              : TempusColors.accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: TempusColors.accent.withValues(alpha: 0.35)),
                        ),
                        child: Center(
                          child: _isSharing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: TempusColors.accent,
                                  ),
                                )
                              : const Icon(Icons.ios_share_rounded,
                                  color: TempusColors.accent, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Current date badge
                  _DateBadge(),
                ],
              ),
            ),

            // Empty state
            if (!_isLoading && !_hasAnySessions) ...[
              _EmptyStatsState(),
            ] else ...[
              // Loading skeleton
              if (_isLoading) ...[
                _SkeletonHeroCard(),
                const SizedBox(height: 12),
                _SkeletonChartCard(),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: SkeletonStatCard()),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonStatCard()),
                  ],
                ),
              ] else ...[
                // Hero card: total time + streak
                _StatsHeroCard(
                  totalMinutes: realMinutes,
                  plannedMinutes: plannedMinutes,
                  avgMinutes: avgMinutes,
                  streak: _sessionStreak ?? 0,
                ),

                // Daily goal (if set)
                if (_dailyGoalMinutes > 0) ...[
                  const SizedBox(height: 12),
                  _DailyGoalCard(
                    dailyMinutes: _dailyMinutes,
                    goalMinutes: _dailyGoalMinutes,
                  ),
                ],

                const SizedBox(height: 12),

                // Weekly activity
                WeeklyActivityCard(barHeights: _weeklyActivity),

                const SizedBox(height: 12),

                // Sessions + Tasks row
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          value: '$finishedSessions',
                          label: 'Sessões',
                          icon: Icons.check_circle_outline_rounded,
                          color: TempusColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          value: '$_completedTasks/$_totalTasks',
                          label: 'Tarefas',
                          icon: Icons.task_alt_rounded,
                          color: TempusColors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Subject breakdown
                if (_subjectBreakdown.isNotEmpty && _subjects.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SubjectsBreakdownCard(
                    minutesBySubjectId: _subjectBreakdown,
                    allSubjects: _subjects,
                    goalMinutesBySubjectId: _subjectGoals,
                    onSetGoal: (id, goal) async {
                      final prefs = await SharedPreferences.getInstance();
                      if (goal > 0) {
                        await prefs.setInt('subject_goal_$id', goal);
                      } else {
                        await prefs.remove('subject_goal_$id');
                      }
                      if (mounted) {
                        setState(() {
                          if (goal > 0) {
                            _subjectGoals = {..._subjectGoals, id: goal};
                          } else {
                            _subjectGoals = Map.from(_subjectGoals)
                              ..remove(id);
                          }
                        });
                      }
                    },
                  ),
                ],

                // History button
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SessionHistoryScreen(),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: TempusColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TempusColors.border),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded,
                            color: TempusColors.textSub, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Ver histórico completo',
                          style: TextStyle(
                            color: TempusColors.textSub,
                            fontSize: 13,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            color: TempusColors.textMuted, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ],

          ],
        ),
      ),
    );
  }
}

// ── Date badge ─────────────────────────────────────────────────

class _DateBadge extends StatelessWidget {
  static const _months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = '${now.day} ${_months[now.month - 1]}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TempusColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TempusColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: TempusColors.textSub, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: TempusColors.textSub,
              fontSize: 12,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero card ──────────────────────────────────────────────────

class _StatsHeroCard extends StatelessWidget {
  final int totalMinutes;
  final int plannedMinutes;
  final int avgMinutes;
  final int streak;

  const _StatsHeroCard({
    required this.totalMinutes,
    required this.plannedMinutes,
    required this.avgMinutes,
    required this.streak,
  });

  static String _fmt(int m) {
    if (m == 0) return '0 min';
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final min = m % 60;
    return min > 0 ? '${h}h ${min}min' : '${h}h';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF130F1E), Color(0xFF0B0B18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TempusColors.accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: TempusColors.accent.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Total Estudado',
                style: TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 13,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (streak > 0) _StreakChip(streak: streak),
            ],
          ),
          const SizedBox(height: 10),
          // Animated total time counter
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: totalMinutes),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ShaderMask(
              shaderCallback: (bounds) => TempusColors.gradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Text(
                _fmt(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: TempusColors.border),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStat(label: 'Planejado', value: _fmt(plannedMinutes)),
              Container(
                width: 1, height: 32, color: TempusColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _HeroStat(label: 'Média/Sessão', value: _fmt(avgMinutes)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatefulWidget {
  final int streak;
  const _StreakChip({required this.streak});

  @override
  State<_StreakChip> createState() => _StreakChipState();
}

class _StreakChipState extends State<_StreakChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;
  late Animation<double> _glow;

  static const _amber = Color(0xFFF59E0B);

  String get _milestoneLabel {
    final s = widget.streak;
    if (s >= 365) return '1 ano!';
    if (s >= 100) return '100 dias!';
    if (s >= 30) return '1 mês!';
    if (s >= 14) return '2 semanas!';
    if (s >= 7) return '1 semana!';
    return '';
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.12, end: 0.30).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    if (widget.streak >= 7) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milestone = _milestoneLabel;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Transform.scale(
        scale: widget.streak >= 7 ? _scale.value : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _amber.withValues(alpha: widget.streak >= 7 ? _glow.value : 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _amber.withValues(alpha: 0.3)),
            boxShadow: widget.streak >= 7
                ? [BoxShadow(color: _amber.withValues(alpha: _glow.value * 0.6), blurRadius: 12)]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(
                milestone.isNotEmpty
                    ? '${ widget.streak} dias · $milestone'
                    : '${widget.streak} ${widget.streak == 1 ? 'dia' : 'dias'}',
                style: const TextStyle(
                  color: _amber,
                  fontSize: 12,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: TempusColors.textSub,
              fontSize: 11,
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              key: ValueKey(value),
              value,
              style: TextStyle(
                color: value == '...' ? TempusColors.textSub : TempusColors.text,
                fontSize: 18,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini stat card ─────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TempusColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Center(child: Icon(icon, color: color, size: 17)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  key: ValueKey(value),
                  value,
                  style: const TextStyle(
                    color: TempusColors.text,
                    fontSize: 22,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 11,
                  fontFamily: 'Arimo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Daily goal card ────────────────────────────────────────────

class _DailyGoalCard extends StatelessWidget {
  final int dailyMinutes;
  final int goalMinutes;

  const _DailyGoalCard({required this.dailyMinutes, required this.goalMinutes});

  String _fmt(int m) {
    if (m == 0) return '0 min';
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final min = m % 60;
    return min > 0 ? '${h}h ${min}min' : '${h}h';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        goalMinutes > 0 ? (dailyMinutes / goalMinutes).clamp(0.0, 1.0) : 0.0;
    final reached = progress >= 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reached
              ? TempusColors.green.withValues(alpha: 0.4)
              : TempusColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                reached ? Icons.check_circle_rounded : Icons.flag_rounded,
                color: reached ? TempusColors.green : TempusColors.textSub,
                size: 14,
              ),
              const SizedBox(width: 7),
              Text(
                reached ? 'Meta do dia atingida!' : 'Meta do dia',
                style: TextStyle(
                  color: reached ? TempusColors.green : TempusColors.textSub,
                  fontSize: 12,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_fmt(dailyMinutes)} / ${_fmt(goalMinutes)}',
                style: const TextStyle(
                  color: TempusColors.text,
                  fontSize: 12,
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
              value: progress,
              backgroundColor: TempusColors.border,
              valueColor: AlwaysStoppedAnimation(
                reached ? TempusColors.green : TempusColors.accent,
              ),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeletons ──────────────────────────────────────────────────

class _SkeletonHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 100, height: 12, borderRadius: BorderRadius.circular(6)),
              SkeletonBox(width: 72, height: 24, borderRadius: BorderRadius.circular(12)),
            ],
          ),
          const SizedBox(height: 14),
          SkeletonBox(width: 160, height: 40, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 20),
          Container(height: 1, color: TempusColors.border),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 60, height: 10, borderRadius: BorderRadius.circular(5)),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 80, height: 18, borderRadius: BorderRadius.circular(8)),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 80, height: 10, borderRadius: BorderRadius.circular(5)),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 60, height: 18, borderRadius: BorderRadius.circular(8)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 40, height: 40, borderRadius: BorderRadius.circular(12)),
              const SizedBox(width: 12),
              SkeletonBox(width: 120, height: 12, borderRadius: BorderRadius.circular(6)),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              7,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SkeletonBox(
                    height: 8.0 + (i % 3 + 1) * 14.0,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Share card (rendered off-screen for screenshot) ────────────

class _StatsShareCard extends StatelessWidget {
  final int totalMinutes;
  final int streak;
  final List<int> weeklyActivity;

  const _StatsShareCard({
    required this.totalMinutes,
    required this.streak,
    required this.weeklyActivity,
  });

  static String _fmt(int m) {
    if (m == 0) return '0 min';
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final min = m % 60;
    return min > 0 ? '${h}h ${min}min' : '${h}h';
  }

  @override
  Widget build(BuildContext context) {
    final maxBar = weeklyActivity.isEmpty
        ? 1
        : weeklyActivity.reduce((a, b) => a > b ? a : b);
    const days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Container(
      width: 360,
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Color(0xFF06040A),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding
          ShaderMask(
            shaderCallback: (bounds) =>
                TempusColors.gradient.createShader(bounds),
            child: const Text(
              'Tempus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Minha semana de estudos',
            style: TextStyle(
              color: TempusColors.textSub,
              fontSize: 13,
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 28),

          // Total time
          Text(
            _fmt(totalMinutes),
            style: const TextStyle(
              color: TempusColors.text,
              fontSize: 44,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'tempo total estudado',
            style: TextStyle(
              color: TempusColors.textSub,
              fontSize: 13,
              fontFamily: 'Arimo',
            ),
          ),

          if (streak > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '$streak dias seguidos',
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 13,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Weekly bars
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final val = weeklyActivity.length > i ? weeklyActivity[i] : 0;
              final ratio = maxBar > 0 ? val / maxBar : 0.0;
              final isToday = i == DateTime.now().weekday - 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 6 + ratio * 60,
                        decoration: BoxDecoration(
                          gradient: isToday
                              ? TempusColors.gradient
                              : null,
                          color: isToday
                              ? null
                              : TempusColors.accent.withValues(alpha: 0.25),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i],
                        style: TextStyle(
                          color: isToday
                              ? TempusColors.accent
                              : TempusColors.textMuted,
                          fontSize: 10,
                          fontFamily: 'Arimo',
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),
          const Divider(color: TempusColors.border, height: 1),
          const SizedBox(height: 16),

          // Footer
          const Row(
            children: [
              Icon(Icons.timer_rounded, color: TempusColors.textMuted, size: 12),
              SizedBox(width: 6),
              Text(
                'tempus.app · Foque. Evolua.',
                style: TextStyle(
                  color: TempusColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Arimo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────

class _EmptyStatsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TempusColors.accent.withValues(alpha: 0.12),
                  TempusColors.accentBlue.withValues(alpha: 0.07),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: TempusColors.accent.withValues(alpha: 0.25)),
            ),
            child: const Center(
              child: Icon(Icons.bar_chart_rounded,
                  color: TempusColors.accent, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ainda sem dados',
            style: TextStyle(
              color: TempusColors.text,
              fontSize: 20,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inicie sua primeira sessão de estudo\npara ver seu progresso aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TempusColors.textSub,
              fontSize: 13,
              fontFamily: 'Arimo',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
