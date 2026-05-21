import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/task.dart';
import '../screens/auth_wrapper.dart';

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
      print('Erro ao carregar estatísticas: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final svc = context.read<SupabaseService>();
        try {
          await svc.signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthWrapper()),
              (route) => false,
            );
          }
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
        height: 56,
        decoration: ShapeDecoration(
          color: const Color(0x1AFF3B30),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFFF3B30)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFFF3B30), size: 20),
            SizedBox(width: 10),
            Text(
              'Sair da Conta',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int apiTotalMinutes = _sessionStats?['totalTimeStudied'] as int? ?? 0;
    final int apiSupposedMinutes =
        _sessionStats?['supposedTotalTimeStudied'] as int? ?? 0;
    final int apiAvgMinutes = _sessionStats?['avgTimeStudied'] as int? ?? 0;
    final int finishedSessions =
        (_sessionStats?['finishedSessions'] as num?)?.toInt() ?? 0;

    final String displayTotal = _isLoading ? '...' : '$apiTotalMinutes min';
    final String displaySupposed =
        _isLoading ? '...' : '$apiSupposedMinutes min';
    final String displayAvg = _isLoading ? '...' : '$apiAvgMinutes min';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimeStatCard(
              realTime: displayTotal,
              plannedTime: displaySupposed,
              avgTime: displayAvg,
              iconColors: const [
                Color.fromARGB(24, 70, 203, 255),
                Color.fromARGB(24, 50, 168, 246)
              ],
              barColors: const [
                Color.fromARGB(255, 70, 172, 255),
                Color.fromARGB(255, 50, 168, 246)
              ],
              icon: Icons.av_timer,
            ),

            const SizedBox(height: 32),

            SummaryStatCard(
              title: 'Sessões Finalizadas',
              value: _isLoading ? '...' : '$finishedSessions',
              iconColors: const [Color(0x19AC46FF), Color(0x19F6329A)],
              barColors: const [Color(0xFFAC46FF), Color(0xFFF6329A)],
              icon: Icons.check_circle_outline,
            ),

            const SizedBox(height: 32),

            SummaryStatCard(
              title: 'Tarefas Concluídas',
              value: '$_completedTasks/$_totalTasks',
              iconColors: const [Color(0x1900C850), Color(0x1900BC7C)],
              barColors: const [Color(0xFF00C850), Color(0xFF00BC7C)],
              icon: Icons.task_alt,
            ),

            const SizedBox(height: 32),

            SummaryStatCard(
              title: 'Sequência de sessões (Streak)',
              value: _isLoading ? '...' : '$_sessionStreak',
              iconColors: const [Color(0x19FF6800), Color(0x19FD9900)],
              barColors: const [Color(0xFFFF6800), Color(0xFFFD9900)],
              icon: Icons.local_fire_department,
            ),

            const SizedBox(height: 48.0),

            _buildLogoutButton(context),

            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
