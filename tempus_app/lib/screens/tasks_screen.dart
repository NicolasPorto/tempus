import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/task.dart';
import '../widgets/tasks_components/tasks_header.dart';
import '../widgets/tasks_components/new_task_card.dart';
import '../widgets/tasks_components/empty_tasks_view.dart';
import '../widgets/tasks_components/task_tile.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TasksScreenContent();
  }
}

class _TasksScreenContent extends StatefulWidget {
  const _TasksScreenContent();

  @override
  State<_TasksScreenContent> createState() => _TasksScreenContentState();
}

class _TasksScreenContentState extends State<_TasksScreenContent> {
  final store = StorageService.instance;
  final TextEditingController _ctrl = TextEditingController();
  String selectedSubjectId = '';

  @override
  void initState() {
    super.initState();
    _initializeSubjectSelection();
  }

  void _initializeSubjectSelection() {
    if (store.subjects.isNotEmpty) {
      setState(() {
        selectedSubjectId = store.subjects.first.id;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addTask() async {
    if (store.subjects.isEmpty) return;

    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    if (selectedSubjectId.isEmpty && store.subjects.isNotEmpty) {
      selectedSubjectId = store.subjects.first.id;
    }

    final t = TaskItem(title: text, subjectId: selectedSubjectId);
    await store.addTask(t);
    _ctrl.clear();
    setState(() {});
  }

  Future<void> _toggleTask(String taskId) async {
    await store.toggleTask(taskId);
    setState(() {});
  }

  Future<void> _deleteTask(String taskId) async {
    await store.removeTask(taskId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (store.subjects.isNotEmpty &&
        !store.subjects.any((s) => s.id == selectedSubjectId)) {
      selectedSubjectId = store.subjects.first.id;
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const TasksHeader(),

            const SizedBox(height: 50),

            NewTaskCard(
              controller: _ctrl,
              subjects: store.subjects,
              selectedSubjectId: selectedSubjectId,
              onSubjectChanged: (newValue) {
                setState(() {
                  selectedSubjectId = newValue ?? '';
                });
              },
              onAddTask: _addTask,
            ),

            const SizedBox(height: 32),

            _buildTaskList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (store.tasks.isEmpty || store.subjects.isEmpty) {
      return EmptyTasksView(hasSubjects: store.subjects.isNotEmpty);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: store.tasks.length,
      itemBuilder: (context, i) {
        final t = store.tasks[i];
        final subj = store.subjects.firstWhere(
          (s) => s.id == t.subjectId,
          orElse: () => store.subjects.isNotEmpty
              ? store.subjects.first
              : store.subjects.firstWhere((s) => true),
        );

        return TaskTile(
          task: t,
          subject: subj,
          onToggle: (_) => _toggleTask(t.id),
          onDelete: () => _deleteTask(t.id),
        );
      },
    );
  }
}
