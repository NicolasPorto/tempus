import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TasksHeader extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onManageSubjects;

  const TasksHeader({
    super.key,
    required this.pendingCount,
    required this.onManageSubjects,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Accent bar + title column
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gradient left accent bar
                Container(
                  width: 3,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: TempusColors.gradientDiag,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          TempusColors.gradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: const Text(
                        'Tarefas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        key: ValueKey(pendingCount),
                        pendingCount == 0
                            ? 'Tudo em dia!'
                            : '$pendingCount ${pendingCount == 1 ? 'pendente' : 'pendentes'}',
                        style: const TextStyle(
                          color: TempusColors.textSub,
                          fontSize: 13,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Manage subjects button
          GestureDetector(
            onTap: onManageSubjects,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: TempusColors.surfaceHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TempusColors.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: TempusColors.textSub,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Matérias',
                    style: TextStyle(
                      color: TempusColors.textSub,
                      fontSize: 12,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
