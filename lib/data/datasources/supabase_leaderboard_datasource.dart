import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graphics_project/data/models/leaderboard_model.dart';

/// Handles all direct Supabase calls for the leaderboards table.
class SupabaseLeaderboardDataSource {
  final SupabaseClient _client;

  SupabaseLeaderboardDataSource(this._client);

  /// Fetches the top-10 rows, JOINing profiles to get the avatar index.
  ///
  /// Supabase resolves `profiles!id_fk(avatar)` automatically because the FK
  /// constraint on id_fk → profiles.id is declared in the migration.
  Future<(List<LeaderboardModel>, int)> fetchTopLeaderboard() async {
    try {
      // In supabase_flutter 2.x, we often chain .select().count()
      final response = await _client
          .from('leaderboards')
          .select('id, id_fk, username, highscore, profiles!id_fk(avatar)')
          .order('highscore', ascending: false)
          .limit(10)
          .count(CountOption.exact);

      // Cast data to List and handle the potential PostgrestResponse structure
      final List data = response.data as List;
      final int count = response.count ?? 0;

      final entries = data
          .map((row) => LeaderboardModel.fromJson(row as Map<String, dynamic>))
          .toList();
      
      return (entries, count);
    } catch (e) {
      debugPrint('LeaderboardDS.fetch error: $e');
      return (const <LeaderboardModel>[], 0);
    }
  }

  /// Delegates to the server-side PostgreSQL function `push_leaderboard_score`
  /// which atomically enforces the top-10 rule without race conditions.
  Future<void> pushScore({
    required String userId,
    required String username,
    required int score,
  }) async {
    try {
      await _client.rpc('push_leaderboard_score', params: {
        'p_user_id': userId,
        'p_username': username,
        'p_score': score,
      });
    } catch (e) {
      debugPrint('LeaderboardDS.pushScore error: $e');
    }
  }
}
