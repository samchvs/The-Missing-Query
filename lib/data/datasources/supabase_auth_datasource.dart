import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graphics_project/domain/entities/app_user.dart';

/// Handles all direct Supabase API calls.
class SupabaseAuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign-up failed: no user returned.');
    }
    final session = response.session;
    if (session != null) {
      await _client.from('profiles').insert({
        'id': user.id,
        'username': username,
        'email': email,
        'case1_points': 0,
        'case2_points': 0,
        'case3_points': 0,
      });
    }
    return AppUser(id: user.id, email: email, username: username);
  }

  /// Signs in an existing user and fetches their profile username.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign-in failed: invalid credentials.');
    }

    // Fetch profile to get the display username
    final profile = await _client
        .from('profiles')
        .select('username')
        .eq('id', user.id)
        .single();

    final username = profile['username'] as String? ?? email;
    return AppUser(id: user.id, email: email, username: username);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  AppUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['username'] as String? ?? '',
    );
  }

  /// Updates the username in the profiles table.
  Future<void> updateUsername({
    required String userId,
    required String username,
  }) async {
    await _client
        .from('profiles')
        .update({'username': username}).eq('id', userId);
        
    // Also update the username in the leaderboards table if it exists
    await _client
        .from('leaderboards')
        .update({'username': username}).eq('id_fk', userId);

    // Update the auth metadata so getCurrentUser() returns the new name on restart
    await _client.auth.updateUser(
      UserAttributes(data: {'username': username}),
    );
  }

  /// Returns the current high_score (total) from the profiles table.
  Future<int> getHighScore(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('high_score')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return 0;
      return (response['high_score'] as int?) ?? 0;
    } catch (e) {
      debugPrint('Error fetching high score: $e');
      return 0;
    }
  }

  /// Returns per-case points as a map: {'case1': x, 'case2': y, 'case3': z}
  Future<Map<String, int>> getCasePoints(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('case1_points, case2_points, case3_points')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return {'case1': 0, 'case2': 0, 'case3': 0};
      return {
        'case1': (response['case1_points'] as int?) ?? 0,
        'case2': (response['case2_points'] as int?) ?? 0,
        'case3': (response['case3_points'] as int?) ?? 0,
      };
    } catch (e) {
      debugPrint('Error fetching case points: $e');
      return {'case1': 0, 'case2': 0, 'case3': 0};
    }
  }

  /// Updates a specific case's points only if the new value is higher.
  /// Also updates high_score (sum of all cases).
  Future<void> updateCasePoints({
    required String userId,
    required String caseId, // 'case1', 'case2', or 'case3'
    required int points,
  }) async {
    try {
      final column = '${caseId}_points';

      // Fetch current values
      final response = await _client
          .from('profiles')
          .select('case1_points, case2_points, case3_points')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return;

      final current = (response[column] as int?) ?? 0;
      if (points <= current) return; // Only update if higher

      final case1 = caseId == 'case1' ? points : ((response['case1_points'] as int?) ?? 0);
      final case2 = caseId == 'case2' ? points : ((response['case2_points'] as int?) ?? 0);
      final case3 = caseId == 'case3' ? points : ((response['case3_points'] as int?) ?? 0);
      final total = case1 + case2 + case3;

      await _client.from('profiles').update({
        column: points,
        'high_score': total,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Error updating case points: $e');
    }
  }

  Future<void> submitScore({
    required String userId,
    required int score,
  }) async {
    final currentBest = await getHighScore(userId);
    if (score > currentBest) {
      await _client
          .from('profiles')
          .update({'high_score': score}).eq('id', userId);
    }
  }

  /// Fetches the latest username from the profiles table.
  Future<String?> fetchUsername(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('username')
          .eq('id', userId)
          .maybeSingle();
      return response?['username'] as String?;
    } catch (e) {
      debugPrint('Error fetching username: $e');
      return null;
    }
  }
}
