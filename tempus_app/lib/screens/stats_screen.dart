import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

import '../widgets/stats_components/time_stat_card.dart';
import '../widgets/stats_components/summary_stat_card.dart';
import '../widgets/stats_components/weekly_activity_card.dart';
import '../widgets/stats_components/subjects_breakdown_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _sessionStats;
  int? _finishedSessions;
  int? _sessionStreak;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final results = await Future.wait([
        apiService.obtainAverageSessionStats(),
        apiService.obtainFinishedSessions(),
        apiService.obtainSessionStreak(),
      ]);

      if (mounted) {
        setState(() {
          _sessionStats = results[0] as Map<String, dynamic>;
          _finishedSessions = results[1] as int;
          _sessionStreak = results[2] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar estatísticas: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StorageService.instance;

    final int apiTotalMinutes = _sessionStats?['totalTimeStudied'] ?? 0;
    final int apiSupposedMinutes = _sessionStats?['supposedTotalTimeStudied'] ?? 0;
    final int apiAvgMinutes = _sessionStats?['timeStudied'] ?? 0;

    final String displayTotal = _isLoading ? '...' : '$apiTotalMinutes min';
    final String displaySupposed = _isLoading ? '...' : '$apiSupposedMinutes min';
    final String displayAvg = _isLoading ? '...' : '$apiAvgMinutes min';

    final totalTasks = store.tasks.length;
    final completedTasks = store.tasks.where((t) => t.done).length;

    final bySubject = <String, int>{};
    for (var s in store.subjects) {
      bySubject[s.id] = 0;
    }

    for (var sess in store.sessions) {
      bySubject[sess.subjectId] = (bySubject[sess.subjectId] ?? 0) + sess.durationMinutes;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Card 1: Tempo
            TimeStatCard(
              realTime: displayTotal,
              plannedTime: displaySupposed,
              avgTime: displayAvg,
              iconColors: const [Color.fromARGB(24, 70, 203, 255), Color.fromARGB(24, 50, 168, 246)],
              barColors: const [Color.fromARGB(255, 70, 172, 255), Color.fromARGB(255, 50, 168, 246)],
              icon: Icons.av_timer,
            ),

            const SizedBox(height: 32),

            // Card 2: Sessões Finalizadas
            SummaryStatCard(
              title: 'Sessões Finalizadas',
              value: _isLoading ? '...' : '$_finishedSessions',
              iconColors: const [Color(0x19AC46FF), Color(0x19F6329A)],
              barColors: const [Color(0xFFAC46FF), Color(0xFFF6329A)],
              icon: Icons.check_circle_outline,
            ),
            
            const SizedBox(height: 32),

            // Card 3: Tarefas (Estava faltando no seu código anterior)
            SummaryStatCard(
              title: 'Tarefas Concluídas',
              value: '$completedTasks/$totalTasks',
              iconColors: const [Color(0x1900C850), Color(0x1900BC7C)],
              barColors: const [Color(0xFF00C850), Color(0xFF00BC7C)],
              icon: Icons.task_alt,
            ),

            const SizedBox(height: 32),

            // // Card 4: Streak
            // SummaryStatCard(
            //   title: 'Sequência (Streak)',
            //   value: _isLoading ? '...' : '$_sessionStreak dias',
            //   iconColors: const [Color(0x19FF6800), Color(0x19FD9900)],
            //   barColors: const [Color(0xFFFF6800), Color(0xFFFD9900)],
            //   icon: Icons.local_fire_department,
            // ),

            // const SizedBox(height: 32),

            // // Card 5: Atividade Semanal (Gráfico)
            // const WeeklyActivityCard(),

            // const SizedBox(height: 32),

            // // Card 6: Matérias (Lista)
            // SubjectsBreakdownCard(
            //   minutesBySubjectId: bySubject,
            //   allSubjects: store.subjects,
            // ),
          ],
        ),
      ),
    );
  }
}