import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../widgets/stats_components/summary_stat_card.dart';
import '../widgets/stats_components/weekly_activity_card.dart';
import '../widgets/stats_components/subjects_breakdown_card.dart';
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
    // Carregar dados assim que a tela iniciar
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
    final int apiSupposedMinutes = _sessionStats?['supposedTotalTimeStudied'] ?? 0;
    final int apiAvgMinutes = _sessionStats?['timeStudied'] ?? 0;

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
            // BLOCO SUPERIOR: DADOS DA API
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatCard(
                    'Tempo Real',
                    _isLoading ? '...' : '$apiTotalMinutes min',
                    const Color(0xFF2B7FFF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStatCard(
                    'Planejado',
                    _isLoading ? '...' : '$apiSupposedMinutes min',
                    const Color(0xFFAC46FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStatCard(
                    'Média/Sessão',
                    _isLoading ? '...' : '$apiAvgMinutes min',
                    const Color(0xFF00C850),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Card 2: Sessões (Local)
            SummaryStatCard(
              title: 'Sessões',
              value: _isLoading ? '...' : '$_finishedSessions',
              iconColors: const [Color(0x19AC46FF), Color(0x19F6329A)],
              barColors: const [Color(0xFFAC46FF), Color(0xFFF6329A)],
            ),
            const SizedBox(height: 32),

            // Card 3: Tarefas (Local)
            // SummaryStatCard(
            //   title: 'Tarefas',
            //   value: '$completedTasks/$totalTasks',
            //   iconColors: const [Color(0x1900C850), Color(0x1900BC7C)],
            //   barColors: const [Color(0xFF00C850), Color(0xFF00BC7C)],
            // ),
            // const SizedBox(height: 32),

            // Card 4: Streak (Placeholder)
            SummaryStatCard(
              title: 'Streak',
              value: _isLoading ? '...' : '$_sessionStreak',
              iconColors: const [Color(0x19FF6800), Color(0x19FD9900)],
              barColors: const [Color(0xFFFF6800), Color(0xFFFD9900)],
            ),
            // const SizedBox(height: 32),

            // Card 5: Atividade Semanal
            // const WeeklyActivityCard(),
            // const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Se estiver carregando, mostra um indicador pequeno, senão o valor
          value == '...'
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}