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
      });
    }
    return AppUser(id: user.id, email: email, username: username);
  }

  /// Signs in an existing user and fetches their profile username + avatar.
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
  }

  /// Returns the current high_score from the profiles table.
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

  /// Updates high_score only if [score] is greater than the current stored value.
  Future<void> submitHighScore({
    required String userId,
    required int score,
  }) async {
    final currentBest = await getHighScore(userId);
    if (score > currentBest) {
      await _updateScoreDirectly(userId: userId, score: score);
    }
  }

  Future<void> _updateScoreDirectly({
    required String userId,
    required int score,
  }) async {
    await _client
        .from('profiles')
        .update({'high_score': score}).eq('id', userId);
  }

  Future<void> submitScore({
    required String userId,
    required int score,
  }) => submitHighScore(userId: userId, score: score);

  /// Returns the avatar index (0–3) stored in the profiles table.
  Future<int> getAvatarIndex(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('avatar')
          .eq('id', userId)
          .maybeSingle();
      if (response == null) return 0;
      return (response['avatar'] as int?) ?? 0;
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
      return 0;
    }
  }

  /// Updates the avatar column in the profiles table.
  Future<void> updateAvatar({
    required String userId,
    required int avatarIndex,
  }) async {
    await _client
        .from('profiles')
        .update({'avatar': avatarIndex}).eq('id', userId);
  }
}
