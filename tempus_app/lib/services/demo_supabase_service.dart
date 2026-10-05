import 'dart:math';
import 'package:tempus_app/models/category.dart';
import 'package:tempus_app/models/task.dart';
import 'supabase_service.dart';

/// Implementação em memória do [SupabaseService] para o modo demonstração.
class DemoSupabaseService extends SupabaseService {
  final List<Category> _categories = [
    Category(id: 'c1', name: 'Cálculo II', hexColor: '#A855F7', userId: 'demo'),
    Category(id: 'c2', name: 'Física', hexColor: '#60A5FA', userId: 'demo'),
    Category(id: 'c3', name: 'Inglês', hexColor: '#34D399', userId: 'demo'),
    Category(id: 'c4', name: 'Química', hexColor: '#F59E0B', userId: 'demo'),
  ];

  late final List<TaskItem> _tasks = [
    TaskItem(id: 't1', title: 'Lista de integrais por partes', subjectId: 'c1', minutesMeta: 45),
    TaskItem(id: 't2', title: 'Revisar cinemática — cap. 3', subjectId: 'c2', minutesMeta: 30),
    TaskItem(id: 't3', title: 'Reading: TED talk + resumo', subjectId: 'c3', minutesMeta: 25),
    TaskItem(id: 't4', title: 'Exercícios de estequiometria', subjectId: 'c4', minutesMeta: 50),
    TaskItem(id: 't5', title: 'Flashcards de vocabulário', subjectId: 'c3', minutesMeta: 15, done: true),
    TaskItem(id: 't6', title: 'Simulado de derivadas', subjectId: 'c1', minutesMeta: 60, done: true),
  ];

  /// Sessões finalizadas geradas de forma determinística (últimos ~90 dias).
  late final List<Map<String, dynamic>> _sessions = _generateSessions();

  List<Map<String, dynamic>> _generateSessions() {
    final rnd = Random(7);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessions = <Map<String, dynamic>>[];
    var id = 0;
    for (var d = 90; d >= 0; d--) {
      final day = today.subtract(Duration(days: d));
      // Sequência recente de 12 dias; antes disso, ~70% dos dias.
      final studied = d < 12 || rnd.nextDouble() < 0.7;
      if (!studied) continue;
      final count = d == 0 ? 2 : 1 + rnd.nextInt(3);
      for (var i = 0; i < count; i++) {
        final planned = [25, 25, 30, 45, 50, 60][rnd.nextInt(6)];
        final real = (planned * (0.75 + rnd.nextDouble() * 0.25)).round();
        final start = day.add(Duration(hours: 8 + i * 3 + rnd.nextInt(2), minutes: rnd.nextInt(50)));
        sessions.add({
          'id': 's${id++}',
          'start_dt': start.toIso8601String(),
          'finish_dt': start.add(Duration(minutes: real)).toIso8601String(),
          'supposed_finish': start.add(Duration(minutes: planned)).toIso8601String(),
          'studying_minutes': real,
          'category_id': _categories[rnd.nextInt(_categories.length)].id,
        });
      }
    }
    return sessions;
  }

  Iterable<Map<String, dynamic>> _since(DateTime start) => _sessions
      .where((s) => !DateTime.parse(s['start_dt']).isBefore(start));

  @override
  String get displayName => 'Nicolas Porto';
  @override
  String get email => 'demo@tempus.app';
  @override
  String? get avatarUrl => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<List<Category>> listCategories() async => List.of(_categories);

  @override
  Future<void> createCategory(String name, String hexColor) async {
    _categories.add(Category(
        id: 'c${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        hexColor: hexColor,
        userId: 'demo'));
  }

  @override
  Future<void> deleteCategory(String id) async =>
      _categories.removeWhere((c) => c.id == id);

  @override
  Future<List<TaskItem>> listTasks() async => _tasks
      .map((t) => TaskItem(
          id: t.id,
          title: t.title,
          subjectId: t.subjectId,
          minutesMeta: t.minutesMeta,
          done: t.done))
      .toList();

  @override
  Future<bool> createTask(String name, String categoryId,
      {int minutesMeta = 25}) async {
    _tasks.add(TaskItem(
        id: 't${DateTime.now().microsecondsSinceEpoch}',
        title: name,
        subjectId: categoryId,
        minutesMeta: minutesMeta));
    return true;
  }

  @override
  Future<bool> toggleTask(String id, bool done) async {
    for (final t in _tasks) {
      if (t.id == id) t.done = done;
    }
    return true;
  }

  @override
  Future<bool> updateTask(
      String id, String name, String categoryId, int minutes) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i < 0) return false;
    _tasks[i] = TaskItem(
        id: id,
        title: name,
        subjectId: categoryId,
        minutesMeta: minutes,
        done: _tasks[i].done);
    return true;
  }

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.id == id);

  final Map<String, Map<String, dynamic>> _open = {};

  @override
  Future<String?> startSession(int studyingMinutes, String categoryId) async {
    final now = DateTime.now();
    final id = 'live${now.microsecondsSinceEpoch}';
    _open[id] = {
      'id': id,
      'start_dt': now.toIso8601String(),
      'supposed_finish':
          now.add(Duration(minutes: studyingMinutes)).toIso8601String(),
      'studying_minutes': studyingMinutes,
      'category_id': categoryId,
    };
    return id;
  }

  @override
  Future<void> stopSession(String sessionId, {int? realMinutes}) async {
    final s = _open.remove(sessionId);
    if (s == null) return;
    if (realMinutes != null && realMinutes > 0) {
      s['studying_minutes'] = realMinutes;
    }
    s['finish_dt'] = DateTime.now().toIso8601String();
    _sessions.add(s);
  }

  @override
  Future<Map<String, int>> getSessionTimeSummary() async {
    var real = 0, planned = 0;
    for (final s in _sessions) {
      real += s['studying_minutes'] as int;
      planned += DateTime.parse(s['supposed_finish'])
          .difference(DateTime.parse(s['start_dt']))
          .inMinutes;
    }
    return {'real': real, 'planned': planned};
  }

  @override
  Future<Map<String, dynamic>> getSessionStats() async =>
      {'finishedSessions': _sessions.length};

  @override
  Future<int> getStreak() async {
    final activity = await getDailyActivity(days: 400);
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!activity.containsKey(day)) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while (activity.containsKey(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Future<List<Map<String, dynamic>>> getSessionHistory({int limit = 50}) async {
    final sorted = List.of(_sessions)
      ..sort((a, b) => (b['start_dt'] as String).compareTo(a['start_dt']));
    return sorted.take(limit).toList();
  }

  @override
  Future<int> getDailyMinutes() async {
    final now = DateTime.now();
    return _since(DateTime(now.year, now.month, now.day))
        .fold<int>(0, (a, s) => a + (s['studying_minutes'] as int));
  }

  @override
  Future<Map<String, int>> getSubjectBreakdown() async {
    final Map<String, int> r = {};
    for (final s in _sessions) {
      final id = s['category_id'] as String;
      r[id] = (r[id] ?? 0) + (s['studying_minutes'] as int);
    }
    return r;
  }

  @override
  Future<Map<DateTime, int>> getDailyActivity({int days = 84}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final Map<DateTime, int> r = {};
    for (final s in _since(start)) {
      final dt = DateTime.parse(s['start_dt']);
      final day = DateTime(dt.year, dt.month, dt.day);
      r[day] = (r[day] ?? 0) + (s['studying_minutes'] as int);
    }
    return r;
  }

  @override
  Future<List<int>> getWeeklyActivity() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final minutes = List.filled(7, 0);
    for (final s in _since(startOfWeek)) {
      final dt = DateTime.parse(s['start_dt']);
      minutes[dt.weekday - 1] += s['studying_minutes'] as int;
    }
    return minutes;
  }
}
