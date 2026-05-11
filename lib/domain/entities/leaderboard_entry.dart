/// Pure Dart entity representing a single leaderboard row.
/// No Supabase imports — inner layer only.
///
/// [avatar] is an integer index (0–3) matching CharacterModel.all /
/// CharacterDisplayConfig.homeConfigs:
///   0 = Beanie, 1 = Carrotino, 2 = Broccoliandro, 3 = Tomathomas
class LeaderboardEntry {
  final String id;
  final String idFk;
  final String username;
  final int highScore;
  final int avatar;

  const LeaderboardEntry({
    required this.id,
    required this.idFk,
    required this.username,
    required this.highScore,
    required this.avatar,
  });
}
