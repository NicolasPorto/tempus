import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/ui.dart';

class TasksHeader extends StatelessWidget {
  final int pendingCount;
  final int completedCount;
  final VoidCallback onManageSubjects;

  const TasksHeader({
    super.key,
    required this.pendingCount,
    this.completedCount = 0,
    required this.onManageSubjects,
  });

  @override
  Widget build(BuildContext context) {
    final total = pendingCount + completedCount;
    final progress = total > 0 ? completedCount / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          eyebrow: 'Seu plano de estudos',
          title: 'Tarefas',
          subtitle: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              key: ValueKey(pendingCount),
              total == 0
                  ? 'Nada por aqui ainda'
                  : pendingCount == 0
                      ? 'Tudo em dia!'
                      : '$pendingCount ${pendingCount == 1 ? 'pendente' : 'pendentes'}',
            ),
          ),
          trailing: Tooltip(
            message: 'Gerenciar matérias',
            child: Pressable(
              onTap: onManageSubjects,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: TempusColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TempusColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category_rounded,
                        color: TempusColors.textSub, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'Matérias',
                      style: TextStyle(
                        color: TempusColors.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (total > 0)
          TempusCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '$completedCount de $total concluídas',
                      style: const TextStyle(
                        color: TempusColors.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        color: progress >= 1
                            ? TempusColors.green
                            : TempusColors.accentSoft,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Stack(
                      children: [
                        Container(height: 6, color: TempusColors.surfaceHigher),
                        FractionallySizedBox(
                          widthFactor: v,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: progress >= 1
                                  ? const LinearGradient(colors: [
                                      TempusColors.green,
                                      Color(0xFF6EE7B7)
                                    ])
                                  : TempusColors.gradient,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
