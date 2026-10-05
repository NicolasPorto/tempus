import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus_app/models/subject.dart';
import 'package:tempus_app/models/task.dart';
import '../../theme/app_theme.dart';
import '../common/ui.dart';

class TaskTile extends StatelessWidget {
  final TaskItem task;
  final Subject subject;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onFocus;
  final int? dragIndex;

  const TaskTile({
    super.key,
    required this.task,
    required this.subject,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
    this.onFocus,
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
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: TempusColors.green,
        icon: task.done ? Icons.undo_rounded : Icons.check_rounded,
        label: task.done ? 'Reabrir' : 'Concluir',
      ),
      secondaryBackground: const _SwipeBackground(
        alignment: Alignment.centerRight,
        color: TempusColors.red,
        icon: Icons.delete_outline_rounded,
        label: 'Excluir',
      ),
      child: GestureDetector(
        onTap: onEdit != null
            ? () {
                HapticFeedback.selectionClick();
                onEdit!();
              }
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          decoration: BoxDecoration(
            color: TempusColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(TempusRadius.lg - 2),
            border: Border.all(color: TempusColors.border),
          ),
          child: Row(
            children: [
              _Checkbox(
                done: task.done,
                color: subjectColor,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onToggle(!task.done);
                },
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
                        fontFamily: AppTheme.fontFamily,
                        color: task.done
                            ? TempusColors.textSub
                            : TempusColors.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: subjectColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subject.name,
                            style: TextStyle(
                              color: Color.lerp(subjectColor, Colors.white, 0.3),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.schedule_rounded,
                            size: 12, color: TempusColors.textSub),
                        const SizedBox(width: 3),
                        Text(
                          formatMinutes(task.minutesMeta),
                          style: const TextStyle(
                            color: TempusColors.textSub,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onFocus != null && !task.done) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Focar nesta tarefa',
                  child: Pressable(
                    onTap: onFocus!,
                    pressedScale: 0.88,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: subjectColor.withValues(alpha: 0.16),
                        border: Border.all(
                            color: subjectColor.withValues(alpha: 0.4)),
                      ),
                      child: Icon(Icons.play_arrow_rounded,
                          color: Color.lerp(subjectColor, Colors.white, 0.25),
                          size: 22),
                    ),
                  ),
                ),
              ],
              if (dragIndex != null)
                ReorderableDelayedDragStartListener(
                  index: dragIndex!,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: TempusColors.textMuted,
                      size: 20,
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

class _Checkbox extends StatelessWidget {
  final bool done;
  final Color color;
  final VoidCallback onTap;

  const _Checkbox(
      {required this.done, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: done,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: done ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: done ? color : color.withValues(alpha: 0.55),
                width: 2,
              ),
            ),
            child: AnimatedScale(
              scale: done ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final left = alignment == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(TempusRadius.lg - 2),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!left) ...[
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: color, size: 22),
          if (left) ...[
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}
