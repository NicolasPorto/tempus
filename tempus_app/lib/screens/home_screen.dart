import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/timer_controller.dart';
import '../services/supabase_service.dart';
import '../widgets/navigation_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O TimerController fica acima das abas para que Perfil (som, meta),
    // Tarefas ("focar nesta tarefa") e Timer compartilhem o mesmo estado.
    return ChangeNotifierProvider(
      create: (context) => TimerController(
        supabaseService: context.read<SupabaseService>(),
      ),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: NavigationContainer(),
      ),
    );
  }
}
