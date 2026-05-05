import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graphics_project/domain/entities/app_user.dart';

/// The ONLY file in this project that imports supabase_flutter.
/// Handles all direct Supabase API calls.
class SupabaseAuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  /// Signs up a new user, then inserts their profile row.
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username}, // picked up by the DB trigger
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign-up failed: no user returned.');
    }

    // If email confirmation is OFF, a live session exists and we insert manually.
    // If email confirmation is ON, the trigger on auth.users handles the insert.
    final session = response.session;
    if (session != null) {
      // Session is live — insert profile row directly (compatible with RLS)
      await _client.from('profiles').insert({
        'id': user.id,
        'username': username,
        'email': email,
      });
    }
    // If session is null, the DB trigger will have created the row already.

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

  /// Returns the current user from the active session, or null.
  AppUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    // Email will always be present on a valid session
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

  /// Updates high_score only if [score] is greater than the current stored value.
  Future<void> submitHighScore({
    required String userId,
    required int score,
  }) async {
    // Fetch current high score first
    final row = await _client
        .from('profiles')
        .select('high_score')
        .eq('id', userId)
        .single();

    final currentBest = (row['high_score'] as int?) ?? 0;
    if (score > currentBest) {
      await submitScore(userId: userId, score: score);
    }
  }

  /// Directly updates the high_score in the profiles table.
  Future<void> submitScore({
    required String userId,
    required int score,
  }) async {
    await _client
        .from('profiles')
        .update({'high_score': score}).eq('id', userId);
  }
}
