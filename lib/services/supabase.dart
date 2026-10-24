import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client =
      Supabase.instance.client;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser {
    return _client.auth.currentUser;
  }

  String? get currentUserId {
    return _client.auth.currentUser?.id;
  }

  // ============================================================
  // GET ENTRIES
  // ============================================================

  Future<List<Map<String, dynamic>>> getEntries() async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final response = await _client
        .from('daily_entries')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================================
  // ADD ENTRY
  // ============================================================

  Future<Map<String, dynamic>> addEntry({
    required DateTime date,
    required String type,
    required double amount,
    required String note,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final response = await _client
        .from('daily_entries')
        .insert({
          'user_id': userId,
          'date': date.toIso8601String().split('T').first,
          'type': type,
          'amount': amount,
          'note': note,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // UPDATE ENTRY
  // ============================================================

  Future<Map<String, dynamic>> updateEntry({
    required String id,
    required DateTime date,
    required String type,
    required double amount,
    required String note,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final response = await _client
        .from('daily_entries')
        .update({
          'date': date.toIso8601String().split('T').first,
          'type': type,
          'amount': amount,
          'note': note,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // DELETE ENTRY
  // ============================================================

  Future<void> deleteEntry(String id) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    await _client
        .from('daily_entries')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}