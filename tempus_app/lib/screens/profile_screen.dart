import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/skeleton_widget.dart';
import '../widgets/subject_manager_modal.dart';

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
  int _dailyGoalMinutes = 0;

  bool _notifEnabled = false;
  int _notifHour = 20;
  int _notifMinute = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final svc = context.read<SupabaseService>();
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyGoalMinutes = prefs.getInt('daily_goal_minutes') ?? 0;

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

  String _fmt(int minutes) {
    if (minutes == 0) return '0min';
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  String _fmtTime(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  Future<void> _showNotifDialog() async {
    bool enabled = _notifEnabled;
    int hour = _notifHour;
    int minute = _notifMinute;
    HapticFeedback.selectionClick();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: TempusColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: TempusColors.border),
          ),
          title: const Text(
            'Lembrete Diário',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ativar lembrete',
                    style: TextStyle(
                      color: TempusColors.text,
                      fontFamily: 'Arimo',
                      fontSize: 14,
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (v) => setDialog(() => enabled = v),
                    activeThumbColor: TempusColors.accent,
                  ),
                ],
              ),
              if (enabled) ...[
                const SizedBox(height: 12),
                const Divider(color: TempusColors.border, height: 1),
                const SizedBox(height: 12),
                const Text(
                  'Horário do lembrete',
                  style: TextStyle(
                    color: TempusColors.textSub,
                    fontFamily: 'Arimo',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay(hour: hour, minute: minute),
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
                      setDialog(() {
                        hour = picked.hour;
                        minute = picked.minute;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: TempusColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: TempusColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: TempusColors.accent, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _fmtTime(hour, minute),
                          style: const TextStyle(
                            color: TempusColors.text,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar',
                  style: TextStyle(
                      color: TempusColors.textSub, fontFamily: 'Arimo')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
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

    if (saved == true && mounted) {
      if (enabled) {
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

  void _showGoalDialog() {
    int selected = _dailyGoalMinutes > 0 ? _dailyGoalMinutes : 60;
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
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
                selected < 60
                    ? '$selected min'
                    : '${selected ~/ 60}h${selected % 60 > 0 ? ' ${selected % 60}min' : ''}',
                style: const TextStyle(
                  color: TempusColors.text,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
              ),
              Slider(
                value: selected.toDouble(),
                min: 15,
                max: 480,
                divisions: 31,
                activeColor: TempusColors.accent,
                inactiveColor: TempusColors.border,
                onChanged: (v) => setDialog(() => selected = v.round()),
              ),
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
                SharedPreferences.getInstance().then(
                  (prefs) => prefs.setInt('daily_goal_minutes', selected),
                );
                setState(() => _dailyGoalMinutes = selected);
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

  @override
  Widget build(BuildContext context) {
    final svc = context.read<SupabaseService>();
    final user = svc.currentUser;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final fullName =
        (user?.userMetadata?['full_name'] as String?) ?? 'Estudante';
    final firstName = fullName.split(' ').first;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    final email = user?.email ?? '';

    return RefreshIndicator(
      onRefresh: _loadData,
      color: TempusColors.accent,
      backgroundColor: TempusColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.fromLTRB(20, topPadding + 8, 20, bottomPadding + 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: _PageHeader(
                title: 'Perfil',
                subtitle: 'Sua conta e configurações',
              ),
            ),

            // ── Profile card ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF130F1E), Color(0xFF0B0B18)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: TempusColors.accent.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: TempusColors.accent.withValues(alpha: 0.10),
                    blurRadius: 32,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with gradient border
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(2),
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
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName,
                          style: const TextStyle(
                            color: TempusColors.text,
                            fontSize: 22,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: TempusColors.textSub,
                            fontSize: 12,
                            fontFamily: 'Arimo',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Stats row ─────────────────────────────────────
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
                        value: _fmt(_totalMinutes),
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
                        icon: Icons.check_circle_outline_rounded,
                        color: TempusColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProfileStatCard(
                        value: _streak > 0 ? '$_streak 🔥' : '—',
                        label: 'Sequência',
                        icon: Icons.local_fire_department_rounded,
                        color: TempusColors.amber,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // ── Settings label ────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'CONFIGURAÇÕES',
                style: TextStyle(
                  color: TempusColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // ── Settings rows ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: TempusColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TempusColors.border),
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.flag_rounded,
                    iconColor: TempusColors.accent,
                    title: 'Meta diária',
                    value: _dailyGoalMinutes > 0
                        ? _fmt(_dailyGoalMinutes)
                        : 'Não definida',
                    onTap: _showGoalDialog,
                    showDivider: true,
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Lembrete diário',
                    value: _notifEnabled
                        ? _fmtTime(_notifHour, _notifMinute)
                        : 'Desativado',
                    onTap: _showNotifDialog,
                    showDivider: true,
                  ),
                  _SettingsRow(
                    icon: Icons.menu_book_rounded,
                    iconColor: TempusColors.accentBlue,
                    title: 'Gerenciar matérias',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      showDialog(
                        context: context,
                        builder: (_) => const SubjectManagerModal(),
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Sign out ──────────────────────────────────────
            GestureDetector(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await context.read<SupabaseService>().signOut();
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Erro ao sair da conta.')),
                    );
                  }
                }
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: TempusColors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: TempusColors.red.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: TempusColors.red, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Sair da Conta',
                      style: TextStyle(
                        color: TempusColors.red,
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared page header (reused across screens) ────────────────────

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => TempusColors.gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            title,
            style: const TextStyle(
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
        Text(
          subtitle,
          style: const TextStyle(
            color: TempusColors.textSub,
            fontSize: 13,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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
      color: TempusColors.surface,
      child: Center(
        child: Text(
          initial.isNotEmpty ? initial[0].toUpperCase() : '?',
          style: const TextStyle(
            color: TempusColors.accent,
            fontSize: 26,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w700,
          ),
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
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, color: color, size: 16)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: TempusColors.text,
              fontSize: 15,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: TempusColors.textSub,
              fontSize: 10,
              fontFamily: 'Arimo',
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TempusColors.border),
      ),
      child: Column(
        children: [
          SkeletonBox(
              width: 34,
              height: 34,
              borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 10),
          SkeletonBox(
              width: 48,
              height: 14,
              borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 6),
          SkeletonBox(
              width: 36,
              height: 10,
              borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: Icon(icon, color: iconColor, size: 16)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: TempusColors.text,
                      fontSize: 14,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (value != null) ...[
                  Text(
                    value!,
                    style: const TextStyle(
                      color: TempusColors.textSub,
                      fontSize: 13,
                      fontFamily: 'Arimo',
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                const Icon(Icons.chevron_right_rounded,
                    color: TempusColors.textMuted, size: 16),
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
