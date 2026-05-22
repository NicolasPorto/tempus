import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/stats_components/time_stat_card.dart';
import '../widgets/stats_components/summary_stat_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _sessionStats;
  int? _sessionStreak;
  int _completedTasks = 0;
  int _totalTasks = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => _isLoading = true);
    final svc = context.read<SupabaseService>();
    try {
      final results = await Future.wait([
        svc.getSessionStats(),
        svc.getStreak(),
        svc.listTasks(),
      ]);

      if (mounted) {
        setState(() {
          _sessionStats = results[0] as Map<String, dynamic>;
          _sessionStreak = results[1] as int;
          final tasks = results[2] as List<TaskItem>;
          _totalTasks = tasks.length;
          _completedTasks = tasks.where((t) => t.done).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) return '0 min';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  @override
  Widget build(BuildContext context) {
    final int apiTotal = _sessionStats?['totalTimeStudied'] as int? ?? 0;
    final int apiSupposed = _sessionStats?['supposedTotalTimeStudied'] as int? ?? 0;
    final int apiAvg = _sessionStats?['avgTimeStudied'] as int? ?? 0;
    final int finishedSessions =
        (_sessionStats?['finishedSessions'] as num?)?.toInt() ?? 0;

    final displayTotal = _isLoading ? '...' : _formatMinutes(apiTotal);
    final displaySupposed = _isLoading ? '...' : _formatMinutes(apiSupposed);
    final displayAvg = _isLoading ? '...' : _formatMinutes(apiAvg);

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: TempusColors.accent,
      backgroundColor: TempusColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estatísticas',
                    style: TextStyle(
                      color: TempusColors.text,
                      fontSize: 30,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Seu desempenho de estudos',
                    style: TextStyle(
                      color: TempusColors.textSub,
                      fontSize: 13,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ],
              ),
            ),

            TimeStatCard(
              realTime: displayTotal,
              plannedTime: displaySupposed,
              avgTime: displayAvg,
              iconColors: const [Color(0x1A60A5FA), Color(0x0D3B82F6)],
              barColors: const [Color(0xFF60A5FA), Color(0xFF3B82F6)],
              icon: Icons.av_timer_rounded,
            ),

            const SizedBox(height: 16),

            // 2-column row: Sessions + Tasks
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SummaryStatCard(
                      title: 'Sessões Finalizadas',
                      value: _isLoading ? '...' : '$finishedSessions',
                      iconColors: const [Color(0x1AA855F7), Color(0x0D7C3AED)],
                      barColors: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryStatCard(
                      title: 'Tarefas Concluídas',
                      value: '$_completedTasks/$_totalTasks',
                      iconColors: const [Color(0x1A34D399), Color(0x0D059669)],
                      barColors: const [Color(0xFF34D399), Color(0xFF059669)],
                      icon: Icons.task_alt_rounded,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SummaryStatCard(
              title: 'Sequência de sessões',
              value: _isLoading ? '...' : '$_sessionStreak',
              iconColors: const [Color(0x1AF59E0B), Color(0x0DD97706)],
              barColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
              icon: Icons.local_fire_department_rounded,
            ),

            const SizedBox(height: 32),

            _buildLogoutButton(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final svc = context.read<SupabaseService>();
        try {
          await svc.signOut();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao sair da conta.')),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: TempusColors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: TempusColors.red.withOpacity(0.4),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: TempusColors.red, size: 18),
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
    );
  }
}
