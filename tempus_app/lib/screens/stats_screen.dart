import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/stats_components/summary_stat_card.dart';
import '../widgets/stats_components/weekly_activity_card.dart';
import '../widgets/stats_components/subjects_breakdown_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StorageService.instance;
    
    final totalMinutes = store.sessions.fold<int>(
      0,
      (p, e) => p + e.durationMinutes,
    );
    
    final totalSessions = store.sessions.length;
    
    final totalTasks = store.tasks.length;
    final completedTasks = store.tasks.where((t) => t.done).length;

    final bySubject = <String, int>{};
    for (var s in store.subjects) {
      bySubject[s.id] = 0;
    }
    for (var sess in store.sessions) {
      bySubject[sess.subjectId] = (bySubject[sess.subjectId] ?? 0) + sess.durationMinutes;
    }

    // 2. Construção da Interface
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
            // Card 1: Total Estudado
            SummaryStatCard(
              title: 'Total Estudado',
              value: '$totalMinutes min',
              iconColors: const [Color(0x192B7FFF), Color(0x1900B8DA)],
              barColors: const [Color(0xFF2B7FFF), Color(0xFF00B8DA)],
            ),
            const SizedBox(height: 32),

            // Card 2: Sessões
            SummaryStatCard(
              title: 'Sessões',
              value: '$totalSessions',
              iconColors: const [Color(0x19AC46FF), Color(0x19F6329A)],
              barColors: const [Color(0xFFAC46FF), Color(0xFFF6329A)],
            ),
            const SizedBox(height: 32),

            // Card 3: Tarefas
            SummaryStatCard(
              title: 'Tarefas',
              value: '$completedTasks/$totalTasks',
              iconColors: const [Color(0x1900C850), Color(0x1900BC7C)],
              barColors: const [Color(0xFF00C850), Color(0xFF00BC7C)],
            ),
            const SizedBox(height: 32),

            // Card 4: Streak (Placeholder)
            SummaryStatCard(
              title: 'Streak',
              value: '0',
              iconColors: const [Color(0x19FF6800), Color(0x19FD9900)],
              barColors: const [Color(0xFFFF6800), Color(0xFFFD9900)],
            ),
            const SizedBox(height: 32),

            // Card 5: Atividade Semanal
            const WeeklyActivityCard(),
            const SizedBox(height: 32),

            // Card 6: Matérias
            SubjectsBreakdownCard(
              minutesBySubjectId: bySubject,
              allSubjects: store.subjects,
            ),
          ],
        ),
      ),
    );
  }
}