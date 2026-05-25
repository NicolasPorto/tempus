import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _sessions = [];
  Map<String, Subject> _subjectMap = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final svc = context.read<SupabaseService>();
    try {
      final results = await Future.wait([
        svc.getSessionHistory(limit: 100),
        svc.listCategories(),
      ]);
      final sessions = results[0] as List<Map<String, dynamic>>;
      final categories = results[1] as List<dynamic>;
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _subjectMap = {
            for (final c in categories) c.id as String: c.toSubject() as Subject
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar histórico.';
          _isLoading = false;
        });
      }
    }
  }

  String _fmt(int minutes) {
    if (minutes == 0) return '0 min';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${dt.day} ${months[dt.month - 1]}${dt.year != now.year ? ' ${dt.year}' : ''}';
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Group sessions by date (YYYY-MM-DD)
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final s in _sessions) {
      final dt = DateTime.tryParse(s['start_dt'] ?? '') ?? DateTime.now();
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20, topPadding > 0 ? 8 : 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: TempusColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TempusColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: TempusColors.textSub, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            TempusColors.gradient.createShader(b),
                        child: const Text(
                          'Histórico',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const Text(
                        'Todas as sessões de estudo',
                        style: TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 12,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: TempusColors.accent))
                  : _error != null
                      ? _ErrorState(
                          message: _error!, onRetry: _load)
                      : _sessions.isEmpty
                          ? const _EmptyState()
                          : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final grouped = _grouped;
    final dateKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _load,
      color: TempusColors.accent,
      backgroundColor: TempusColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: dateKeys.length,
        itemBuilder: (_, i) {
          final key = dateKeys[i];
          final day = grouped[key]!;
          final dt = DateTime.parse(key);
          final totalMinutes =
              day.fold<int>(0, (s, e) => s + ((e['studying_minutes'] as num?)?.toInt() ?? 0));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      _dateLabel(dt),
                      style: const TextStyle(
                        color: TempusColors.text,
                        fontSize: 13,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: TempusColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _fmt(totalMinutes),
                        style: const TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 11,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...day.map((session) => _SessionRow(
                    session: session,
                    subject: _subjectMap[session['category_id'] as String?],
                    fmt: _fmt,
                    timeLabel: _timeLabel,
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final Map<String, dynamic> session;
  final Subject? subject;
  final String Function(int) fmt;
  final String Function(DateTime) timeLabel;

  const _SessionRow({
    required this.session,
    required this.subject,
    required this.fmt,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (session['studying_minutes'] as num?)?.toInt() ?? 0;
    final startDt = DateTime.tryParse(session['start_dt'] ?? '');
    final subjectColor =
        subject != null ? Color(subject!.colorValue) : TempusColors.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TempusColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: subjectColor.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Icon(Icons.timer_rounded, color: subjectColor, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject?.name ?? 'Matéria removida',
                  style: const TextStyle(
                    color: TempusColors.text,
                    fontSize: 13,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (startDt != null)
                  Text(
                    timeLabel(startDt),
                    style: const TextStyle(
                      color: TempusColors.textSub,
                      fontSize: 11,
                      fontFamily: 'Arimo',
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: TempusColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              fmt(minutes),
              style: const TextStyle(
                color: TempusColors.textSub,
                fontSize: 12,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded,
              color: TempusColors.textMuted, size: 48),
          SizedBox(height: 16),
          Text(
            'Nenhuma sessão ainda',
            style: TextStyle(
              color: TempusColors.textSub,
              fontSize: 15,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Complete uma sessão de foco\npara ver o histórico aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TempusColors.textMuted,
              fontSize: 12,
              fontFamily: 'Arimo',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: TempusColors.textMuted, size: 40),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  color: TempusColors.textSub, fontFamily: 'Arimo')),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: TempusColors.gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
