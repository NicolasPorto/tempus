import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../controller/timer_controller.dart';
import '../libraries/globals.dart';
import '../widgets/common/skeleton_widget.dart';
import '../widgets/common/ui.dart';
import '../widgets/goal_sheet.dart';
import '../widgets/subject_manager_modal.dart';

// ── Níveis e conquistas ───────────────────────────────────────────

class _Level {
  final String name;
  final int hours; // horas necessárias
  const _Level(this.name, this.hours);
}

const _levels = [
  _Level('Iniciante', 0),
  _Level('Aprendiz', 2),
  _Level('Dedicado', 5),
  _Level('Focado', 10),
  _Level('Estudioso', 20),
  _Level('Persistente', 35),
  _Level('Disciplinado', 50),
  _Level('Expert', 80),
  _Level('Mestre', 120),
  _Level('Lenda', 200),
];

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double progress; // 0..1
  const _Achievement(
      this.title, this.description, this.icon, this.color, this.progress);
  bool get unlocked => progress >= 1;
}

List<_Achievement> _achievements(int minutes, int sessions, int streak) {
  double p(num v, num goal) => (v / goal).clamp(0.0, 1.0).toDouble();
  return [
    _Achievement('1º passo', 'Primeira sessão',
        Icons.flag_rounded, TempusColors.green, p(sessions, 1)),
    _Achievement('Embalado', '3 dias seguidos',
        Icons.local_fire_department_rounded, TempusColors.amber, p(streak, 3)),
    _Achievement('Imparável', '7 dias seguidos',
        Icons.whatshot_rounded, const Color(0xFFFB7185), p(streak, 7)),
    _Achievement('10 horas', '10h de foco',
        Icons.timer_rounded, TempusColors.accentBlue, p(minutes, 600)),
    _Achievement('Maratonista', '50 sessões',
        Icons.directions_run_rounded, TempusColors.accent, p(sessions, 50)),
    _Achievement('Centenário', '100h de foco',
        Icons.workspace_premium_rounded, const Color(0xFFFACC15),
        p(minutes, 6000)),
  ];
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  int _totalMinutes = 0;
  int _totalSessions = 0;
  int _streak = 0;

  bool _notifEnabled = false;
  int _notifHour = 20;
  int _notifMinute = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    tempusGlobals.dataVersion.addListener(_refreshSilently);
  }

  @override
  void dispose() {
    tempusGlobals.dataVersion.removeListener(_refreshSilently);
    super.dispose();
  }

  void _refreshSilently() => _loadData(silent: true);

  Future<void> _loadData({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _isLoading = true);
    final svc = context.read<SupabaseService>();
    try {
      final notifSettings = await NotificationService().getSettings();
      _notifEnabled = notifSettings['enabled'] as bool;
      _notifHour = notifSettings['hour'] as int;
      _notifMinute = notifSettings['minute'] as int;

      final results = await Future.wait([
        svc.getSessionTimeSummary(),
        svc.getStreak(),
        svc.getSessionStats(),
      ]);

      if (mounted) {
        setState(() {
          _totalMinutes = (results[0] as Map<String, int>)['real'] ?? 0;
          _streak = results[1] as int;
          final stats = results[2] as Map<String, dynamic>;
          _totalSessions =
              (stats['finishedSessions'] as num?)?.toInt() ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _fmtTime(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  Future<void> _showNotifDialog() async {
    bool enabled = _notifEnabled;
    int hour = _notifHour;
    int minute = _notifMinute;
    HapticFeedback.selectionClick();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SheetScaffold(
          title: 'Lembrete diário',
          subtitle: 'Um empurrãozinho no horário em que você costuma estudar.',
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ativar lembrete',
                      style: TextStyle(
                        color: TempusColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (v) => setSheet(() => enabled = v),
                    activeThumbColor: Colors.white,
                    activeTrackColor: TempusColors.accent,
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                child: !enabled
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Pressable(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime:
                                  TimeOfDay(hour: hour, minute: minute),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: TempusColors.accent,
                                    surface: TempusColors.surface,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setSheet(() {
                                hour = picked.hour;
                                minute = picked.minute;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: TempusColors.accent.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(TempusRadius.md),
                              border: Border.all(
                                  color: TempusColors.accent
                                      .withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    color: TempusColors.accentSoft, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  _fmtTime(hour, minute),
                                  style: const TextStyle(
                                    color: TempusColors.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    letterSpacing: 1,
                                    fontFeatures: [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Salvar',
                onTap: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      if (enabled) {
        await NotificationService().requestPermission();
        await NotificationService()
            .scheduleDailyReminder(hour: hour, minute: minute);
      } else {
        await NotificationService().cancelDailyReminder();
      }
      setState(() {
        _notifEnabled = enabled;
        _notifHour = hour;
        _notifMinute = minute;
      });
    }
  }

  String _soundStyleLabel(String style) {
    switch (style) {
      case 'single':
        return 'Único';
      case 'vibration_only':
        return 'Só vibração';
      default:
        return 'Triplo';
    }
  }

  void _showSoundDialog(TimerController timer) {
    String selected = timer.soundStyle;
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SheetScaffold(
          title: 'Som do timer',
          subtitle: 'Escolha o alerta ao fim de cada sessão.',
          child: Column(
            children: [
              ...{
                'triple': ('Triplo', 'Três toques + vibração', Icons.queue_music_rounded),
                'single': ('Único', 'Um toque discreto', Icons.music_note_rounded),
                'vibration_only': ('Só vibração', 'Silencioso', Icons.vibration_rounded),
              }.entries.map((e) {
                final isSelected = selected == e.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Pressable(
                    onTap: () => setSheet(() => selected = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TempusColors.accent.withValues(alpha: 0.12)
                            : TempusColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(TempusRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? TempusColors.accent.withValues(alpha: 0.5)
                              : TempusColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconTile(
                            icon: e.value.$3,
                            color: isSelected
                                ? TempusColors.accent
                                : TempusColors.textSub,
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.value.$1,
                                  style: const TextStyle(
                                    color: TempusColors.text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  e.value.$2,
                                  style: const TextStyle(
                                    color: TempusColors.textSub,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: isSelected ? 1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: const Icon(Icons.check_circle_rounded,
                                color: TempusColors.accent, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Salvar',
                onTap: () {
                  timer.setSoundStyle(selected);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.read<SupabaseService>();
    final timer = context.watch<TimerController>();
    final media = MediaQuery.of(context);

    final fullName = svc.displayName;
    final firstName = fullName.split(' ').first;
    final avatarUrl = svc.avatarUrl;
    final email = svc.email;

    final hours = _totalMinutes / 60;
    var levelIndex = 0;
    for (var i = 0; i < _levels.length; i++) {
      if (hours >= _levels[i].hours) levelIndex = i;
    }
    final level = _levels[levelIndex];
    final next =
        levelIndex + 1 < _levels.length ? _levels[levelIndex + 1] : null;
    final levelProgress = next == null
        ? 1.0
        : ((hours - level.hours) / (next.hours - level.hours)).clamp(0.0, 1.0);
    final achievements =
        _achievements(_totalMinutes, _totalSessions, _streak);
    final unlocked = achievements.where((a) => a.unlocked).length;

    return RefreshIndicator(
      onRefresh: () => _loadData(silent: true),
      color: TempusColors.accent,
      backgroundColor: TempusColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            20, media.padding.top + 4, 20, media.padding.bottom + 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              eyebrow: 'Sua conta',
              title: 'Perfil',
            ),

            // ── Cartão de perfil + nível ─────────────────────────
            TempusCard(
              gradient: TempusColors.heroCard,
              borderColor: TempusColors.accent.withValues(alpha: 0.25),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: TempusColors.gradientDiag,
                        ),
                        child: ClipOval(
                          child: avatarUrl != null
                              ? Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _AvatarFallback(initial: firstName),
                                )
                              : _AvatarFallback(initial: firstName),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: TempusColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: TempusColors.textSub,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: TempusColors.gradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Nível ${levelIndex + 1} · ${level.name}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: _isLoading ? 0 : levelProgress),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => Stack(
                        children: [
                          Container(
                              height: 7, color: TempusColors.surfaceHigher),
                          FractionallySizedBox(
                            widthFactor: v,
                            child: Container(
                              height: 7,
                              decoration: const BoxDecoration(
                                  gradient: TempusColors.gradient),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${hours.toStringAsFixed(hours < 10 ? 1 : 0)}h de foco',
                        style: const TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        next == null
                            ? 'Nível máximo!'
                            : 'Próximo: ${next.name} (${next.hours}h)',
                        style: const TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Números ──────────────────────────────────────────
            if (_isLoading)
              Row(
                children: [
                  Expanded(child: _SkeletonProfileStat()),
                  const SizedBox(width: 10),
                  Expanded(child: _SkeletonProfileStat()),
                  const SizedBox(width: 10),
                  Expanded(child: _SkeletonProfileStat()),
                ],
              )
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ProfileStatCard(
                        value: formatMinutes(_totalMinutes, compact: true),
                        label: 'Estudado',
                        icon: Icons.timer_rounded,
                        color: TempusColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProfileStatCard(
                        value: '$_totalSessions',
                        label: 'Sessões',
                        icon: Icons.check_circle_rounded,
                        color: TempusColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProfileStatCard(
                        value: _streak > 0 ? '$_streak dias' : '—',
                        label: 'Sequência',
                        icon: Icons.local_fire_department_rounded,
                        color: TempusColors.amber,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // ── Conquistas ───────────────────────────────────────
            SectionLabel(
              'Conquistas',
              trailing: Text(
                '$unlocked/${achievements.length}',
                style: const TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.98,
              padding: EdgeInsets.zero,
              children: [
                for (final a in achievements)
                  _AchievementBadge(achievement: a, loading: _isLoading),
              ],
            ),

            const SizedBox(height: 28),

            // ── Configurações ────────────────────────────────────
            const SectionLabel('Configurações'),
            Container(
              decoration: BoxDecoration(
                color: TempusColors.surface,
                borderRadius: BorderRadius.circular(TempusRadius.lg),
                border: Border.all(color: TempusColors.border),
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.flag_rounded,
                    iconColor: TempusColors.accent,
                    title: 'Meta diária',
                    value: timer.dailyGoalMinutes > 0
                        ? formatMinutes(timer.dailyGoalMinutes)
                        : 'Não definida',
                    onTap: () => showDailyGoalSheet(context, timer),
                    showDivider: true,
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_rounded,
                    iconColor: TempusColors.amber,
                    title: 'Lembrete diário',
                    value: _notifEnabled
                        ? _fmtTime(_notifHour, _notifMinute)
                        : 'Desativado',
                    onTap: _showNotifDialog,
                    showDivider: true,
                  ),
                  _SettingsRow(
                    icon: Icons.music_note_rounded,
                    iconColor: TempusColors.green,
                    title: 'Som do timer',
                    value: _soundStyleLabel(timer.soundStyle),
                    onTap: () => _showSoundDialog(timer),
                    showDivider: true,
                  ),
                  _SettingsRow(
                    icon: Icons.av_timer_rounded,
                    iconColor: const Color(0xFFFB7185),
                    title: 'Alertas a cada 5 min',
                    subtitle: 'Toque sutil durante o foco',
                    trailing: Switch(
                      value: timer.intervalAlerts,
                      onChanged: timer.setIntervalAlerts,
                      activeThumbColor: Colors.white,
                      activeTrackColor: TempusColors.accent,
                    ),
                    onTap: () =>
                        timer.setIntervalAlerts(!timer.intervalAlerts),
                    showDivider: true,
                  ),
                  _SettingsRow(
                    icon: Icons.menu_book_rounded,
                    iconColor: TempusColors.accentBlue,
                    title: 'Gerenciar matérias',
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await showDialog(
                        context: context,
                        builder: (_) => const SubjectManagerModal(),
                      );
                      timer.loadSubjects();
                      tempusGlobals.markDataChanged();
                    },
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SecondaryButton(
              label: 'Sair da conta',
              icon: Icons.logout_rounded,
              color: TempusColors.red,
              onTap: () async {
                HapticFeedback.mediumImpact();
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await svc.signOut();
                } catch (e) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Erro ao sair da conta.')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Tempus · foque, evolua.',
                style: TextStyle(
                  color: TempusColors.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────

class _AvatarFallback extends StatelessWidget {
  final String initial;
  const _AvatarFallback({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TempusColors.surfaceHigh,
      child: Center(
        child: Text(
          initial.isNotEmpty ? initial[0].toUpperCase() : '?',
          style: const TextStyle(
            color: TempusColors.accentSoft,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;
  final bool loading;
  const _AchievementBadge({required this.achievement, required this.loading});

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final on = a.unlocked && !loading;
    return Tooltip(
      message: a.description,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
        decoration: BoxDecoration(
          color: on
              ? a.color.withValues(alpha: 0.10)
              : TempusColors.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(TempusRadius.lg - 2),
          border: Border.all(
            color: on ? a.color.withValues(alpha: 0.35) : TempusColors.border,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: loading ? 0 : a.progress,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                      backgroundColor: TempusColors.surfaceHigher,
                      valueColor: AlwaysStoppedAnimation(
                          on ? a.color : a.color.withValues(alpha: 0.55)),
                    ),
                  ),
                  Icon(
                    on ? a.icon : Icons.lock_rounded,
                    size: on ? 22 : 16,
                    color: on ? a.color : TempusColors.textMuted,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              a.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: on ? TempusColors.text : TempusColors.textSub,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              on ? a.description : '${(a.progress * 100).round()}%',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: TempusColors.textSub,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: TempusColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(TempusRadius.lg - 2),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTile(icon: icon, color: color, size: 34),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: TempusColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: TempusColors.textSub,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SkeletonProfileStat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(TempusRadius.lg - 2),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        children: [
          SkeletonBox(
              width: 34, height: 34, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 10),
          SkeletonBox(
              width: 48, height: 14, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 6),
          SkeletonBox(
              width: 36, height: 10, borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TempusRadius.lg),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: trailing != null ? 8 : 14),
            child: Row(
              children: [
                IconTile(icon: icon, color: iconColor, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: TempusColors.text,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: TempusColors.textSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else ...[
                  if (value != null) ...[
                    Text(
                      value!,
                      style: const TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  const Icon(Icons.chevron_right_rounded,
                      color: TempusColors.textMuted, size: 20),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 64),
            color: TempusColors.border,
          ),
      ],
    );
  }
}
