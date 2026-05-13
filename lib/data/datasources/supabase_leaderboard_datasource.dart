import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graphics_project/data/models/leaderboard_model.dart';

/// Handles all direct Supabase calls for the leaderboards table.
class SupabaseLeaderboardDataSource {
  final SupabaseClient _client;

  SupabaseLeaderboardDataSource(this._client);

  /// Fetches the top-10 rows from the leaderboards table.
  Future<(List<LeaderboardModel>, int)> fetchTopLeaderboard() async {
    try {
      final response = await _client
          .from('leaderboards')
          .select('id, id_fk, username, highscore')
          .order('highscore', ascending: false)
          .limit(10)
          .count(CountOption.exact);

      final List data = response.data as List;
      final int count = response.count;

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
