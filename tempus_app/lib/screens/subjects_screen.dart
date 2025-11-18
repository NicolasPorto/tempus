import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/subject.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final store = StorageService.instance;
  final TextEditingController _ctrl = TextEditingController();
  Color selectedColor = Colors.indigo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _cycleColor() {
    final colors = [
      Colors.indigo,
      Colors.pink,
      Colors.green,
      Colors.orange,
      Colors.cyan,
      Colors.purple,
    ];
    final idx = colors.indexWhere((c) => c.value == selectedColor.value);
    setState(() => selectedColor = colors[(idx + 1) % colors.length]);
  }

  void _addSubject() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    final s = Subject(name: name, colorValue: selectedColor.value);
    await store.addSubject(s);
    _ctrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Assunto'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Novo assunto',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _cycleColor,
                  child: CircleAvatar(backgroundColor: selectedColor),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSubject,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (store.subjects.isEmpty) {
      return const Center(
        child: Text('Sem assuntos.', style: TextStyle(color: Colors.white60)),
      );
    }
    return ListView.builder(
      itemCount: store.subjects.length,
      itemBuilder: (context, i) {
        final s = store.subjects[i];
        return Card(
          color: Colors.white12,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Color(s.colorValue)),
            title: Text(s.name, style: const TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white70),
              onPressed: () async {
                await store.removeSubject(s.id);
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}
