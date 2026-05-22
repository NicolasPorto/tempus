import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus_app/services/supabase_service.dart';
import '../models/task.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
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
  int _selectedHours = 0;
  bool _isLoading = false;

  TaskItem? _pendingDeleteTask;
  late SupabaseService _svc;

  @override
  void initState() {
    super.initState();
    _svc = context.read<SupabaseService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _svc.listCategories(),
        _svc.listTasks(),
      ]);

      final categories = results[0] as List<dynamic>;
      final tasks = results[1] as List<dynamic>;

      if (mounted) {
        setState(() {
          _subjects = categories.map((c) => c.toSubject()).toList().cast<Subject>();
          _tasks = tasks.cast<TaskItem>();

          if (_subjects.isNotEmpty &&
              !_subjects.any((s) => s.id == selectedSubjectId)) {
            selectedSubjectId = _subjects.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    if (_pendingDeleteTask != null) {
      _svc.deleteTask(_pendingDeleteTask!.id);
    }
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
    int minutesToSave = _selectedHours * 60;
    if (minutesToSave == 0) minutesToSave = 25;

    final success = await _svc.createTask(
      text,
      subjectIdToUse,
      minutesMeta: minutesToSave,
    );

    if (success) {
      _ctrl.clear();
      setState(() => _selectedHours = 0);
      await _loadData();
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTask(TaskItem task) async {
    setState(() => task.done = !task.done);

    final success = await _svc.toggleTask(task.id, task.done);

    if (!success) {
      setState(() => task.done = !task.done);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao atualizar tarefa')),
        );
      }
    }
  }

  void _deleteTask(TaskItem task) {
    if (_pendingDeleteTask != null && _pendingDeleteTask!.id != task.id) {
      _svc.deleteTask(_pendingDeleteTask!.id);
      _pendingDeleteTask = null;
    }

    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
      _pendingDeleteTask = task;
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '"${task.title}" removida',
          style: const TextStyle(fontFamily: 'Arimo'),
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: TempusColors.surface,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: TempusColors.accent,
          onPressed: () {
            if (mounted && _pendingDeleteTask?.id == task.id) {
              setState(() {
                _tasks.add(task);
                _tasks.sort((a, b) => a.title.compareTo(b.title));
                _pendingDeleteTask = null;
              });
            }
          },
        ),
      ),
    ).closed.then((reason) {
      if (reason != SnackBarClosedReason.action &&
          _pendingDeleteTask?.id == task.id) {
        _pendingDeleteTask = null;
        _svc.deleteTask(task.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_subjects.isNotEmpty &&
        !_subjects.any((s) => s.id == selectedSubjectId)) {
      selectedSubjectId = _subjects.first.id;
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: TempusColors.accent,
      backgroundColor: TempusColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TasksHeader(),
            const SizedBox(height: 20),
            NewTaskCard(
              controller: _ctrl,
              subjects: _subjects,
              selectedSubjectId: selectedSubjectId,
              selectedHours: _selectedHours,
              onSubjectChanged: (v) => setState(() => selectedSubjectId = v ?? ''),
              onHoursChanged: (v) => setState(() => _selectedHours = v),
              onAddTask: _addTask,
            ),
            const SizedBox(height: 20),
            if (_isLoading && _tasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: TempusColors.accent,
                  ),
                ),
              )
            else
              _buildTaskList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_tasks.isEmpty || _subjects.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.35,
        alignment: Alignment.center,
        child: EmptyTasksView(hasSubjects: _subjects.isNotEmpty),
      );
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
          onDelete: () => _deleteTask(t),
        );
      },
    );
  }
}
