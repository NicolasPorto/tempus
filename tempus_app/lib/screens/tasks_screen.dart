import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus_app/services/api_service.dart';
import '../models/task.dart';
import '../models/subject.dart';
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
  final TextEditingController _ctrl = TextEditingController();

  List<TaskItem> _tasks = [];
  List<Subject> _subjects = [];
  String selectedSubjectId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final api = context.read<ApiService>();

    try {
      final results = await Future.wait([
        api.listAllCategories(),
        api.getAllTasks(),
      ]);

      final categories = results[0] as List<dynamic>;
      final tasks = results[1] as List<dynamic>;

      if (mounted) {
        setState(() {
          _subjects = categories
              .map((c) => c.toSubject())
              .toList()
              .cast<Subject>();
          _tasks = tasks.cast<TaskItem>();

          if (_subjects.isNotEmpty &&
              !_subjects.any((s) => s.id == selectedSubjectId)) {
            selectedSubjectId = _subjects.first.id;
          }
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_subjects.isEmpty) return;
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    String subjectIdToUse = selectedSubjectId;
    if (subjectIdToUse.isEmpty && _subjects.isNotEmpty) {
      subjectIdToUse = _subjects.first.id;
    }

    setState(() => _isLoading = true);
    final api = context.read<ApiService>();

    final success = await api.createTask(text, subjectIdToUse);

    if (success) {
      _ctrl.clear();
      await _loadData();
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTask(TaskItem task) async {
    setState(() {
      task.done = !task.done;
    });

    final api = context.read<ApiService>();

    final success = await api.toggleTaskStatus(task.id, task.done);

    if (!success) {
      setState(() {
        task.done = !task.done;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update task status")),
      );
    } else {
      // _loadData();
    }
  }

  Future<void> _deleteTask(String taskId) async {
    setState(() => _isLoading = true);
    final api = context.read<ApiService>();
    await api.deleteTask(taskId);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_subjects.isNotEmpty &&
        !_subjects.any((s) => s.id == selectedSubjectId)) {
      selectedSubjectId = _subjects.first.id;
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const TasksHeader(),

            const SizedBox(height: 20),

            NewTaskCard(
              controller: _ctrl,
              subjects: _subjects,
              selectedSubjectId: selectedSubjectId,
              onSubjectChanged: (newValue) {
                setState(() {
                  selectedSubjectId = newValue ?? '';
                });
              },
              onAddTask: _addTask,
            ),

            const SizedBox(height: 20),

            if (_isLoading && _tasks.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              _buildTaskList(),

            const SizedBox(height: 64.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_tasks.isEmpty || _subjects.isEmpty) {
      return EmptyTasksView(hasSubjects: _subjects.isNotEmpty);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tasks.length,
      itemBuilder: (context, i) {
        final t = _tasks[i];

        final subj = _subjects.firstWhere(
          (s) => s.id == t.subjectId,
          orElse: () => _subjects.first,
        );

        return TaskTile(
          task: t,
          subject: subj,
          onToggle: (_) => _toggleTask(t),
          onDelete: () => _deleteTask(t.id),
        );
      },
    );
  }
}
