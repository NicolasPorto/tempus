import 'package:flutter/material.dart';
import 'package:tempus_app/models/subject.dart';
import 'package:tempus_app/models/task.dart';
import '../../theme/app_theme.dart';

class TaskTile extends StatelessWidget {
  final TaskItem task;
  final Subject subject;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.subject,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(subject.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TempusColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TempusColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left color accent stripe
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                color: task.done
                    ? subjectColor.withOpacity(0.3)
                    : subjectColor,
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () => onToggle(!task.done),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: task.done
                                ? subjectColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: task.done
                                  ? subjectColor
                                  : TempusColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: task.done
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: TextStyle(
                                color: task.done
                                    ? TempusColors.textSub
                                    : TempusColors.text,
                                fontSize: 14,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w500,
                                decoration: task.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor: TempusColors.textSub,
                              ),
                              child: Text(
                                task.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subject.name,
                              style: TextStyle(
                                color: subjectColor.withOpacity(0.8),
                                fontSize: 11,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete
                      GestureDetector(
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: TempusColors.textMuted,
                            size: 18,
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
      ),
    );
  }
}
