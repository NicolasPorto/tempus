import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus_app/services/supabase_service.dart';
import '../models/task.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import '../widgets/tasks_components/tasks_header.dart';
import '../widgets/tasks_components/empty_tasks_view.dart';
import '../widgets/tasks_components/task_tile.dart';
import '../widgets/tasks_components/subject_filter_chips.dart';
import '../widgets/tasks_components/add_task_sheet.dart';
import '../widgets/tasks_components/edit_task_sheet.dart';
import '../widgets/subject_manager_modal.dart';
import '../widgets/common/skeleton_widget.dart';

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
  List<TaskItem> _tasks = [];
  List<Subject> _subjects = [];
  Map<String, Subject> _subjectMap = {};
  String? _selectedSubjectId;
  bool _isLoading = false;
  bool _showCompleted = false;
  List<String> _taskOrder = [];

  TaskItem? _pendingDeleteTask;
  late SupabaseService _svc;

  List<TaskItem> get _filteredTasks {
    final all = _selectedSubjectId == null
        ? _tasks
        : _tasks.where((t) => t.subjectId == _selectedSubjectId).toList();
    return all;
  }

  List<TaskItem> get _pendingTasks =>
      _filteredTasks.where((t) => !t.done).toList();

  List<TaskItem> get _completedTasks =>
      _filteredTasks.where((t) => t.done).toList();

  @override
  void initState() {
    super.initState();
    _svc = context.read<SupabaseService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _taskOrder = prefs.getStringList('task_order') ?? [];

      final results = await Future.wait([
        _svc.listCategories(),
        _svc.listTasks(),
      ]);

      final categories = results[0] as List<dynamic>;
      final tasks = results[1] as List<dynamic>;

      if (mounted) {
        setState(() {
          _subjects =
              categories.map((c) => c.toSubject()).toList().cast<Subject>();
          _subjectMap = {for (final s in _subjects) s.id: s};
          final rawTasks = tasks.cast<TaskItem>();
          _tasks = _sortByOrder(rawTasks);

          if (_selectedSubjectId != null &&
              !_subjects.any((s) => s.id == _selectedSubjectId)) {
            _selectedSubjectId = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TaskItem> _sortByOrder(List<TaskItem> tasks) {
    if (_taskOrder.isEmpty) return tasks;
    return [
      ..._taskOrder
          .where((id) => tasks.any((t) => t.id == id))
          .map((id) => tasks.firstWhere((t) => t.id == id)),
      ...tasks.where((t) => !_taskOrder.contains(t.id)),
    ];
  }

  Future<void> _saveTaskOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('task_order', _taskOrder);
  }

  void _reorder(int oldIndex, int newIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final pending = [..._pendingTasks];
      final item = pending.removeAt(oldIndex);
      pending.insert(newIndex, item);

      // Rebuild _tasks preserving pending order, keeping completed at end
      final reordered = <TaskItem>[...pending];
      for (final t in _tasks) {
        if (!reordered.any((r) => r.id == t.id)) {
          reordered.add(t);
        }
      }
      _tasks = reordered;
      _taskOrder = _tasks.map((t) => t.id).toList();
    });
    _saveTaskOrder();
  }

  @override
  void dispose() {
    if (_pendingDeleteTask != null) {
      _svc.deleteTask(_pendingDeleteTask!.id);
    }
    super.dispose();
  }

  Future<bool> _addTask(String title, String subjectId, int minutes) async {
    final success =
        await _svc.createTask(title, subjectId, minutesMeta: minutes);
    if (success) await _loadData();
    return success;
  }

  Future<bool> _editTask(
      TaskItem task, String title, String subjectId, int minutes) async {
    final success = await _svc.updateTask(task.id, title, subjectId, minutes);
    if (success) await _loadData();
    return success;
  }

  void _openEditTaskSheet(TaskItem task) {
    EditTaskSheet.show(
      context,
      task: task,
      subjects: _subjects,
      onSave: (title, subjectId, minutes) =>
          _editTask(task, title, subjectId, minutes),
    );
  }

  Future<void> _toggleTask(TaskItem task) async {
    HapticFeedback.mediumImpact();
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
      _taskOrder.remove(task.id);
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
                _tasks.insert(0, task);
                _taskOrder.insert(0, task.id);
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

  void _openAddTaskSheet() {
    HapticFeedback.selectionClick();
    AddTaskSheet.show(
      context,
      subjects: _subjects,
      initialSubjectId: _selectedSubjectId ?? '',
      onAdd: _addTask,
    );
  }

  void _manageSubjects() {
    showDialog(
      context: context,
      builder: (_) => const SubjectManagerModal(),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _tasks.where((t) => !t.done).length;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadData,
          color: TempusColors.accent,
          backgroundColor: TempusColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TasksHeader(
                  pendingCount: pendingCount,
                  onManageSubjects: _manageSubjects,
                ),
                const SizedBox(height: 16),
                if (_subjects.isNotEmpty) ...[
                  SubjectFilterChips(
                    subjects: _subjects,
                    selectedId: _selectedSubjectId,
                    onChanged: (id) =>
                        setState(() => _selectedSubjectId = id),
                  ),
                  const SizedBox(height: 20),
                ],
                if (_isLoading && _tasks.isEmpty)
                  _buildSkeletonList()
                else
                  _buildTaskList(),
                SizedBox(height: bottomPadding + 160),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: bottomPadding + 100,
          right: 24,
          child: _buildFab(),
        ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i == 3 ? 0 : 0),
          child: const SkeletonTaskTile(),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: _openAddTaskSheet,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: TempusColors.gradient,
          boxShadow: [
            BoxShadow(
              color: TempusColors.accent.withValues(alpha: 0.40),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_subjects.isEmpty) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.50,
        ),
        child: Center(
          child: EmptyTasksView(
            hasSubjects: false,
            onManageSubjects: _manageSubjects,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pendingTasks.isEmpty && _completedTasks.isEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.42,
            ),
            child: Center(child: EmptyTasksView(hasSubjects: true)),
          )
        else ...[
          if (_pendingTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Tudo concluído! 🎉',
                style: const TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 13,
                  fontFamily: 'Arimo',
                ),
              ),
            )
          else
            ReorderableListView.builder(
              buildDefaultDragHandles: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingTasks.length,
              itemBuilder: (context, i) {
                final t = _pendingTasks[i];
                final subj = _subjectMap[t.subjectId] ?? _subjects.first;
                return TaskTile(
                  key: ValueKey('tile_${t.id}'),
                  task: t,
                  subject: subj,
                  onToggle: (_) => _toggleTask(t),
                  onDelete: () => _deleteTask(t),
                  onEdit: () => _openEditTaskSheet(t),
                  dragIndex: i,
                );
              },
              onReorder: _reorder,
            ),
          if (_completedTasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildCompletedSection(),
          ],
        ],
      ],
    );
  }

  Widget _buildCompletedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showCompleted = !_showCompleted),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _showCompleted ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: TempusColors.textSub,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Concluídas (${_completedTasks.length})',
                  style: const TextStyle(
                    color: TempusColors.textSub,
                    fontSize: 13,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _showCompleted
              ? Opacity(
                  opacity: 0.65,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _completedTasks.length,
                    itemBuilder: (context, i) {
                      final t = _completedTasks[i];
                      final subj = _subjectMap[t.subjectId] ?? _subjects.first;
                      return TaskTile(
                        key: ValueKey('done_${t.id}'),
                        task: t,
                        subject: subj,
                        onToggle: (_) => _toggleTask(t),
                        onDelete: () => _deleteTask(t),
                        onEdit: () => _openEditTaskSheet(t),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
