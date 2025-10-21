import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/pomodoro_timer.dart';
import '../models/subject.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with TickerProviderStateMixin {
  static const defaultMinutes = 25;
  String selectedSubjectId = '';
  final store = StorageService.instance;

  @override
  void initState() {
    super.initState();
    if (store.subjects.isNotEmpty) selectedSubjectId = store.subjects.first.id;
  }

  void _onSessionComplete(String subjectId) async {
    await store.addSessionFromSubject(subjectId, _PomodoroScreenState.defaultMinutes);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Focus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              DropdownButton<String>(
                value: selectedSubjectId,
                dropdownColor: const Color(0xFF0B0B0D),
                underline: const SizedBox.shrink(),
                items: store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Row(children: [CircleAvatar(radius: 6, backgroundColor: Color(s.colorValue)), const SizedBox(width: 8), Text(s.name)]))).toList(),
                onChanged: (v) => setState(() => selectedSubjectId = v ?? store.subjects.first.id),
              )
            ]),
            const SizedBox(height: 18),
            Expanded(child: Center(child: PomodoroTimer(onComplete: () async {
              // add session record
              await StorageService.instance.addSessionFromSubject(selectedSubjectId, defaultMinutes);
              // refresh
              setState(() {});
            }))),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              OutlinedButton(onPressed: () {}, child: const Text('15 min')),
              OutlinedButton(onPressed: () {}, child: const Text('25 min')),
              OutlinedButton(onPressed: () {}, child: const Text('45 min')),
            ]),
            const SizedBox(height: 8),
            Text('Sessions completed: ${store.sessions.length}', style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
