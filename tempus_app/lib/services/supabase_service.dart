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

  Future<void> stopSession(String sessionId) async {
    try {
      await _supabase.from('session_focus').update({
        'finish_dt': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);
    } catch (e) {
      print('Error stopping session: $e');
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
}
