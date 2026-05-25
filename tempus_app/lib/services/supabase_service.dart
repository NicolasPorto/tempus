import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tempus_app/models/category.dart';
import 'package:tempus_app/models/task.dart';
import 'package:tempus_app/core/supabase/supabase_client.dart';

class SupabaseService {
  SupabaseClient get _supabase => SupabaseClientConfig.client;

  // --- Auth ---

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.dev.tempusapp://login-callback/',
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // --- Categories ---

  Future<List<Category>> listCategories() async {
    try {
      final data = await _supabase
          .from('categories')
          .select()
          .order('created_at');
      return (data as List).map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      print('Error listing categories: $e');
      return [];
    }
  }

  Future<void> createCategory(String name, String hexColor) async {
    await _supabase.from('categories').insert({
      'name': name,
      'hex_color': hexColor,
      'user_id': currentUser!.id,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _supabase.from('categories').delete().eq('id', id);
  }

  // --- Tasks ---

  Future<List<TaskItem>> listTasks() async {
    try {
      final data = await _supabase
          .from('tasks')
          .select()
          .order('created_at');
      return (data as List).map((e) => TaskItem.fromJson(e)).toList();
    } catch (e) {
      print('Error listing tasks: $e');
      return [];
    }
  }

  Future<bool> createTask(String name, String categoryId,
      {int minutesMeta = 25}) async {
    try {
      await _supabase.from('tasks').insert({
        'name': name,
        'minutes_meta': minutesMeta,
        'category_id': categoryId,
        'user_id': currentUser!.id,
      });
      return true;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }

  Future<bool> toggleTask(String id, bool done) async {
    try {
      await _supabase.from('tasks').update({'done': done}).eq('id', id);
      return true;
    } catch (e) {
      print('Error toggling task: $e');
      return false;
    }
  }

  Future<bool> updateTask(
      String id, String name, String categoryId, int minutes) async {
    try {
      await _supabase.from('tasks').update({
        'name': name,
        'category_id': categoryId,
        'minutes_meta': minutes,
      }).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return false;
    }
  }

  Future<void> deleteTask(String id) async {
    await _supabase.from('tasks').delete().eq('id', id);
  }

  // --- Sessions ---

  Future<String?> startSession(int studyingMinutes, String categoryId) async {
    final now = DateTime.now();
    final supposedFinish = now.add(Duration(minutes: studyingMinutes));
    try {
      final response = await _supabase
          .from('session_focus')
          .insert({
            'start_dt': now.toIso8601String(),
            'supposed_finish': supposedFinish.toIso8601String(),
            'studying_minutes': studyingMinutes,
            'category_id': categoryId,
            'user_id': currentUser!.id,
          })
          .select('id')
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error starting session: $e');
      return null;
    }
  }

  Future<void> stopSession(String sessionId, {int? realMinutes}) async {
    try {
      await _supabase.from('session_focus').update({
        'finish_dt': DateTime.now().toIso8601String(),
        // Sobrescreve studying_minutes com o tempo real de foco (sem pausas).
        // O tempo planejado original é preservado em supposed_finish - start_dt.
        if (realMinutes != null && realMinutes > 0)
          'studying_minutes': realMinutes,
      }).eq('id', sessionId);
    } catch (e) {
      print('Error stopping session: $e');
    }
  }

  /// Busca sessões finalizadas e calcula tempo real e planejado diretamente
  /// das colunas (sem depender da RPC que pode estar incorreta).
  Future<Map<String, int>> getSessionTimeSummary() async {
    try {
      final data = await _supabase
          .from('session_focus')
          .select('start_dt, supposed_finish, studying_minutes')
          .not('finish_dt', 'is', null);

      int totalReal = 0;
      int totalPlanned = 0;

      for (final row in (data as List)) {
        totalReal += (row['studying_minutes'] as num?)?.toInt() ?? 0;

        final start = DateTime.tryParse(row['start_dt'] ?? '');
        final supposed = DateTime.tryParse(row['supposed_finish'] ?? '');
        if (start != null && supposed != null) {
          totalPlanned += supposed.difference(start).inMinutes;
        }
      }

      return {'real': totalReal, 'planned': totalPlanned};
    } catch (e) {
      print('Error getting session time summary: $e');
      return {'real': 0, 'planned': 0};
    }
  }

  // --- Stats ---

  Future<Map<String, dynamic>> getSessionStats() async {
    try {
      final response = await _supabase.rpc(
        'get_session_stats',
        params: {'p_user_id': currentUser!.id},
      );
      return (response as Map<String, dynamic>?) ?? {};
    } catch (e) {
      print('Error fetching session stats: $e');
      return {};
    }
  }

  Future<int> getStreak() async {
    try {
      final response = await _supabase.rpc(
        'get_session_streak',
        params: {'p_user_id': currentUser!.id},
      );
      return (response as num?)?.toInt() ?? 0;
    } catch (e) {
      print('Error fetching streak: $e');
      return 0;
    }
  }

  /// Returns the last [limit] completed sessions, newest first.
  Future<List<Map<String, dynamic>>> getSessionHistory({int limit = 50}) async {
    try {
      final data = await _supabase
          .from('session_focus')
          .select('id, start_dt, finish_dt, studying_minutes, category_id')
          .not('finish_dt', 'is', null)
          .order('start_dt', ascending: false)
          .limit(limit);
      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching session history: $e');
      return [];
    }
  }

  /// Returns total minutes studied today.
  Future<int> getDailyMinutes() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final data = await _supabase
          .from('session_focus')
          .select('studying_minutes')
          .not('finish_dt', 'is', null)
          .gte('start_dt', startOfDay.toIso8601String());
      int total = 0;
      for (final row in (data as List)) {
        total += (row['studying_minutes'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (e) {
      print('Error fetching daily minutes: $e');
      return 0;
    }
  }

  /// Returns total minutes studied per subject (subjectId → minutes).
  Future<Map<String, int>> getSubjectBreakdown() async {
    try {
      final data = await _supabase
          .from('session_focus')
          .select('category_id, studying_minutes')
          .not('finish_dt', 'is', null);
      final Map<String, int> breakdown = {};
      for (final row in (data as List)) {
        final id = row['category_id'] as String?;
        if (id != null) {
          breakdown[id] =
              (breakdown[id] ?? 0) + ((row['studying_minutes'] as num?)?.toInt() ?? 0);
        }
      }
      return breakdown;
    } catch (e) {
      print('Error fetching subject breakdown: $e');
      return {};
    }
  }

  /// Returns minutes studied per day for the current week (Mon=0, Sun=6).
  Future<List<int>> getWeeklyActivity() async {
    try {
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));

      final data = await _supabase
          .from('session_focus')
          .select('start_dt, studying_minutes')
          .not('finish_dt', 'is', null)
          .gte('start_dt', startOfWeek.toIso8601String());

      final List<int> minutes = List.filled(7, 0);
      for (final row in (data as List)) {
        final start = DateTime.tryParse(row['start_dt'] ?? '');
        if (start != null) {
          final dayIndex = start.weekday - 1;
          minutes[dayIndex] += (row['studying_minutes'] as num?)?.toInt() ?? 0;
        }
      }
      return minutes;
    } catch (e) {
      print('Error fetching weekly activity: $e');
      return List.filled(7, 0);
    }
  }
}
