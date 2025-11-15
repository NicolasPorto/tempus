import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';
import '../models/task.dart';
import '../models/session.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;

  List<Subject> subjects = [];
  List<TaskItem> tasks = [];
  List<SessionLog> sessions = [];

  StorageService._internal();

  static Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
    await instance._loadData();
  }

  Future<void> _loadData() async {
    final sJson = _prefs.getString('subjects');
    if (sJson != null) {
      subjects = (jsonDecode(sJson) as List)
          .map((e) => Subject.fromMap(e))
          .toList();
    }

    final tJson = _prefs.getString('tasks');
    if (tJson != null) {
      tasks = (jsonDecode(tJson) as List)
          .map((e) => TaskItem.fromMap(e))
          .toList();
    }

    final seJson = _prefs.getString('sessions');
    if (seJson != null) {
      sessions = (jsonDecode(seJson) as List)
          .map((e) => SessionLog.fromMap(e))
          .toList();
    }
  }

  // ---------- MÉTODOS DE SALVAR ----------
  Future<void> saveSubjects() async => _prefs.setString(
    'subjects',
    jsonEncode(subjects.map((e) => e.toMap()).toList()),
  );

  Future<void> saveTasks() async => _prefs.setString(
    'tasks',
    jsonEncode(tasks.map((e) => e.toMap()).toList()),
  );

  Future<void> saveSessions() async => _prefs.setString(
    'sessions',
    jsonEncode(sessions.map((e) => e.toMap()).toList()),
  );

  // ---------- CRUD DE SUBJECTS ----------
  Future<void> addSubject(Subject s) async {
    subjects.add(s);
    await saveSubjects();
  }

  Future<void> removeSubject(String id) async {
    subjects.removeWhere((s) => s.id == id);
    await saveSubjects();
  }

  // ---------- CRUD DE TASKS ----------
  Future<void> addTask(TaskItem t) async {
    tasks.add(t);
    await saveTasks();
  }

  Future<void> toggleTask(String id) async {
    final t = tasks.firstWhere((task) => task.id == id);
    t.done = !t.done;
    await saveTasks();
  }

  Future<void> removeTask(String id) async {
    tasks.removeWhere((t) => t.id == id);
    await saveTasks();
  }

  // ---------- SESSÕES ----------
  Future<void> addSessionLog(SessionLog session) async {
    sessions.add(session);
    await saveSessions();
  }

  Future<void> addSessionFromSubject(String subjectId, int minutes) async {
    sessions.add(SessionLog(subjectId: subjectId, durationMinutes: minutes));
    await saveSessions();
  }

  static Future loadSubjects() async {}
}