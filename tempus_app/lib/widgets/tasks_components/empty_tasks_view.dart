import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptyTasksView extends StatelessWidget {
  final bool hasSubjects;
  final VoidCallback? onManageSubjects;

  const EmptyTasksView({
    super.key,
    required this.hasSubjects,
    this.onManageSubjects,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: TempusColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(32),
              border:
                  Border.all(color: TempusColors.accent.withOpacity(0.2)),
            ),
            child: Center(
              child: Icon(
                hasSubjects
                    ? Icons.task_alt_rounded
                    : Icons.menu_book_rounded,
                color: TempusColors.accent,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasSubjects ? 'Nenhuma tarefa aqui' : 'Crie uma matéria primeiro',
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
                ? 'Toque no + para adicionar sua próxima tarefa.'
                : 'Organize seus estudos criando matérias como Matemática, Física...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TempusColors.textMuted,
              fontSize: 13,
              fontFamily: 'Arimo',
            ),
          ),
          if (!hasSubjects && onManageSubjects != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onManageSubjects,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: TempusColors.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Criar matéria',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
