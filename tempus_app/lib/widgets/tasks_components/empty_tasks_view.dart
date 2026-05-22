import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptyTasksView extends StatelessWidget {
  final bool hasSubjects;

  const EmptyTasksView({super.key, required this.hasSubjects});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: TempusColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: TempusColors.accent.withOpacity(0.2)),
            ),
            child: const Center(
              child: Icon(
                Icons.task_alt_rounded,
                color: TempusColors.accent,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasSubjects ? 'Sem tarefas' : 'Adicione matérias primeiro',
            style: const TextStyle(
              color: TempusColors.textSub,
              fontSize: 15,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasSubjects
                ? 'Adicione tarefas no cartão acima.'
                : 'Você precisa de uma matéria ativa para criar tarefas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TempusColors.textMuted,
              fontSize: 13,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }
}
