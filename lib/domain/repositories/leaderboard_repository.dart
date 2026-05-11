import 'package:graphics_project/domain/entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  /// Fetches the top 10 (or fewer) leaderboard entries and the total player count.
  Future<(List<LeaderboardEntry>, int)> fetchTopLeaderboard();

  /// Attempts to push [userId]'s [score] into the leaderboard.
  ///
  /// Rules enforced on the data layer:
  ///  - Only 10 rows exist at a time.
  ///  - The score must beat the lowest ranked score (or the board is not full).
  ///  - If the user already has a row, it is updated in-place.
  ///  - If a new row is inserted and the board grows past 10, the lowest is removed.
  Future<void> pushScore({
    required String userId,
    required String username,
    required int score,
  });
}
