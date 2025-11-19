import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus_app/widgets/stats_components/time_stat_card.dart';
import '../services/storage_service.dart';
import '../widgets/stats_components/summary_stat_card.dart';
import '../services/api_service.dart';

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
      final stats = await apiService.obtainAverageSessionStats();
      final finishedSessions = await apiService.obtainFinishedSessions();
      final sessionStreak = await apiService.obtainSessionStreak();
      if (mounted) {
        setState(() {
          _sessionStats = stats;
          _finishedSessions = finishedSessions;
          _sessionStreak = sessionStreak;
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
    final int apiSupposedMinutes =
        _sessionStats?['supposedTotalTimeStudied'] ?? 0;
    final int apiAvgMinutes = _sessionStats?['timeStudied'] ?? 0;

    final String displayTotal = _isLoading ? '...' : '$apiTotalMinutes min';
    final String displaySupposed = _isLoading
        ? '...'
        : '$apiSupposedMinutes min';
    final String displayAvg = _isLoading ? '...' : '$apiAvgMinutes min';

    final totalTasks = store.tasks.length;
    final completedTasks = store.tasks.where((t) => t.done).length;

    final bySubject = <String, int>{};
    for (var s in store.subjects) {
      bySubject[s.id] = 0;
    }
    for (var sess in store.sessions) {
      bySubject[sess.subjectId] =
          (bySubject[sess.subjectId] ?? 0) + sess.durationMinutes;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 32,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
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

            // Card 2: Sessões (Local)
            SummaryStatCard(
              title: 'Sessões Finalizadas',
              value: _isLoading ? '...' : '$_finishedSessions',
              iconColors: const [Color(0x19AC46FF), Color(0x19F6329A)],
              barColors: const [Color(0xFFAC46FF), Color(0xFFF6329A)],
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 32),

            // Card 3: Streak
            SummaryStatCard(
              title: 'Sequência (Streak)',
              value: _isLoading ? '...' : '$_sessionStreak dias',
              iconColors: const [Color(0x19FF6800), Color(0x19FD9900)],
              barColors: const [Color(0xFFFF6800), Color(0xFFFD9900)],
              icon: Icons.local_fire_department,
            ),
          ],
        ),
      ),
    );
  }
}
