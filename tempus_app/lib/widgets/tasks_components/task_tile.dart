import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus_app/models/subject.dart';
import 'package:tempus_app/models/task.dart';
import '../../theme/app_theme.dart';

class TaskTile extends StatelessWidget {
  final TaskItem task;
  final Subject subject;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final int? dragIndex;

  const TaskTile({
    super.key,
    required this.task,
    required this.subject,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
    this.dragIndex,
  });

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(subject.colorValue);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.mediumImpact();
          onToggle(!task.done);
          return false;
        }
        return true;
      },
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TempusColors.green.withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TempusColors.green.withValues(alpha: 0.35)),
        ),
        child: const Icon(
          Icons.check_circle_outline_rounded,
          color: TempusColors.green,
          size: 22,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              TempusColors.red.withValues(alpha: 0.18),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TempusColors.red.withValues(alpha: 0.35)),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: TempusColors.red,
          size: 22,
        ),
      ),
      child: GestureDetector(
        onLongPress: onEdit != null
            ? () {
                HapticFeedback.selectionClick();
                onEdit!();
              }
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: TempusColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TempusColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 4,
                    color: task.done
                        ? subjectColor.withValues(alpha: 0.25)
                        : subjectColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              onToggle(!task.done);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutBack,
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: task.done
                                    ? subjectColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: task.done
                                      ? subjectColor
                                      : TempusColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: AnimatedScale(
                                scale: task.done ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
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
                                const SizedBox(height: 4),
                                Text(
                                  subject.name,
                                  style: TextStyle(
                                    color: subjectColor.withValues(alpha: 0.75),
                                    fontSize: 11,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (task.minutesMeta != 25) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: TempusColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(7),
                                border:
                                    Border.all(color: TempusColors.border),
                              ),
                              child: Text(
                                '${task.minutesMeta}m',
                                style: const TextStyle(
                                  color: TempusColors.textSub,
                                  fontSize: 11,
                                  fontFamily: 'Arimo',
                                ),
                              ),
                            ),
                          ],
                          if (dragIndex != null) ...[
                            const SizedBox(width: 8),
                            ReorderableDelayedDragStartListener(
                              index: dragIndex!,
                              child: const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.drag_handle_rounded,
                                  color: TempusColors.textMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
