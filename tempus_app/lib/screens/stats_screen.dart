import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/task.dart';

// 1. Adicione estes imports para o Logout funcionar
import '../services/authentication_service.dart';
import 'auth_wrapper.dart'; 

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
  // ... (Seu código existente de variáveis e initState/fetchData permanece igual) ...
  bool _isLoading = true;
  Map<String, dynamic>? _sessionStats;
  int? _finishedSessions;
  int? _sessionStreak;
  int _completedTasks = 0;
  int _totalTasks = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    // ... (Seu código existente do _fetchData permanece igual) ...
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final results = await Future.wait([
        apiService.obtainAverageSessionStats(),
        apiService.obtainFinishedSessions(),
        apiService.obtainSessionStreak(),
        apiService.getAllTasks()
      ]);

      if (mounted) {
        setState(() {
          _sessionStats = results[0] as Map<String, dynamic>;
          _finishedSessions = results[1] as int;
          _sessionStreak = results[2] as int;
          final tasks = results[3] as List<TaskItem>;
          _totalTasks = tasks.length;
          _completedTasks = tasks.where((t) => t.done).length;
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

  // 2. Função auxiliar para criar o botão de Logout
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Mostra um indicador de carregamento rápido ou apenas executa
        final authService = Provider.of<AuthenticationService>(context, listen: false);
        
        try {
          await authService.logout();
          
          if (context.mounted) {
            // Redireciona para a tela de login/wrapper e remove a pilha de navegação
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthWrapper()),
              (route) => false,
            );
          }
        } catch (e) {
          print("Erro ao fazer logout: $e");
          if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Erro ao sair da conta.")),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          // Fundo vermelho bem suave
          color: const Color(0x1AFF3B30), 
          shape: RoundedRectangleBorder(
            // Borda vermelha para indicar ação destrutiva/sair
            side: const BorderSide(width: 1, color: Color(0xFFFF3B30)), 
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
    // ... (Cálculos de variáveis do build permanecem iguais) ...
    final store = StorageService.instance;

    final int apiTotalMinutes = _sessionStats?['totalTimeStudied'] ?? 0;
    final int apiSupposedMinutes = _sessionStats?['supposedTotalTimeStudied'] ?? 0;
    final int apiAvgMinutes = _sessionStats?['timeStudied'] ?? 0;

    final String displayTotal = _isLoading ? '...' : '$apiTotalMinutes min';
    final String displaySupposed = _isLoading ? '...' : '$apiSupposedMinutes min';
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
              iconColors: const [Color.fromARGB(24, 70, 203, 255), Color.fromARGB(24, 50, 168, 246)],
              barColors: const [Color.fromARGB(255, 70, 172, 255), Color.fromARGB(255, 50, 168, 246)],
              icon: Icons.av_timer,
            ),

            const SizedBox(height: 32),

            SummaryStatCard(
              title: 'Sessões Finalizadas',
              value: _isLoading ? '...' : '$_finishedSessions',
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
            
            const SizedBox(height: 48.0), // Aumentei um pouco o espaçamento

            // 3. Inserção do Botão de Logout
            _buildLogoutButton(context),
            
            const SizedBox(height: 32.0), // Margem final para garantir scroll
            
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