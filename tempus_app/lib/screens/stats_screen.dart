import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = StorageService.instance;
    final totalMinutes = store.sessions.fold<int>(0, (p, e) => p + e.durationMinutes);
    final bySubject = <String, int>{};
    for (var s in store.subjects) bySubject[s.id] = 0;
    for (var sess in store.sessions) bySubject[sess.subjectId] = (bySubject[sess.subjectId] ?? 0) + sess.durationMinutes;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total focused time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('$totalMinutes minutes', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Per subject', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...store.subjects.map((s) {
            final minutes = bySubject[s.id] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(children: [
                CircleAvatar(radius: 8, backgroundColor: Color(s.colorValue)),
                const SizedBox(width: 12),
                Expanded(child: Text(s.name)),
                Text('$minutes min'),
              ]),
            );
          }).toList(),
          const SizedBox(height: 16),
          const Text('Recent sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(child: _recentSessions(store)),
        ]),
      ),
    );
  }

  Widget _recentSessions(StorageService store) {
    final list = store.sessions.reversed.take(10).toList();
    if (list.isEmpty) return const Center(child: Text('No sessions yet', style: TextStyle(color: Colors.white60)));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final s = list[i];
        final subj = store.subjects.firstWhere((x) => x.id == s.subjectId, orElse: () => store.subjects.first);
        return Card(
          color: Colors.white10,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Color(subj.colorValue)),
            title: Text('${subj.name} — ${s.durationMinutes} min'),
            subtitle: Text('${s.createdAt.toLocal().toString().split(".").first}'),
          ),
        );
      },
    );
  }
}
