import 'package:flutter/material.dart';
import 'package:tempus_app/models/subject.dart';
import 'package:tempus_app/models/task.dart';

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
    return Card(
      color: const Color(0x7F171717),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: onToggle,
          activeColor: Color(subject.colorValue),
          checkColor: Colors.white,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subject.name,
          style: TextStyle(
            color: Color(subject.colorValue),
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFD4D4D4)),
          onPressed: onDelete,
        ),
      ),
    );
  }
}