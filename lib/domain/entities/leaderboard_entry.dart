/// Pure Dart entity representing a single leaderboard row.
/// No Supabase imports — inner layer only.
class LeaderboardEntry {
  final String id;
  final String idFk;
  final String username;
  final int highScore;

  const LeaderboardEntry({
    required this.id,
    required this.idFk,
    required this.username,
    required this.highScore,
  });
}
