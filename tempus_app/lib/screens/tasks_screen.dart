import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/task.dart';
import '../models/subject.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final store = StorageService.instance;
  final TextEditingController _ctrl = TextEditingController();
  String selectedSubjectId = '';

  @override
  void initState() {
    super.initState();
    if (store.subjects.isNotEmpty) selectedSubjectId = store.subjects.first.id;
  }

  void _addTask() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final t = TaskItem(title: text, subjectId: selectedSubjectId);
    await store.addTask(t);
    _ctrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'New task'))),
            const SizedBox(width: 8),
            DropdownButton<String>(
                value: selectedSubjectId,
                items: store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setState(() => selectedSubjectId = v ?? selectedSubjectId))
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [ElevatedButton(onPressed: _addTask, child: const Text('Add'))]),
          const SizedBox(height: 12),
          Expanded(child: _buildTasks())
        ]),
      ),
    );
  }

  Widget _buildTasks() {
    if (store.tasks.isEmpty) return const Center(child: Text('No tasks yet.', style: TextStyle(color: Colors.white60)));
    return ListView.builder(
      itemCount: store.tasks.length,
      itemBuilder: (context, i) {
        final t = store.tasks[i];
        final subj = store.subjects.firstWhere((s) => s.id == t.subjectId, orElse: () => store.subjects.first);
        return Card(
          color: Colors.white10,
          child: ListTile(
            leading: Checkbox(value: t.done, onChanged: (_) async { await store.toggleTask(t.id); setState(() {}); }),
            title: Text(t.title, style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null)),
            subtitle: Text(subj.name),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async { await store.removeTask(t.id); setState(() {}); }),
          ),
        );
      },
    );
  }
}
