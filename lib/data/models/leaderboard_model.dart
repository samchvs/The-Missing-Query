import 'package:graphics_project/domain/entities/leaderboard_entry.dart';

/// JSON ↔ entity adapter for a leaderboard row.
///
/// The query uses Supabase's auto-JOIN via the FK to profiles:
///   .select('id, id_fk, username, highscore, profiles!id_fk(avatar)')
///
/// The resulting JSON looks like:
///   { "id": "...", "id_fk": "...", "username": "...", "highscore": 120,
///     "profiles": { "avatar": 2 } }
class LeaderboardModel extends LeaderboardEntry {
  const LeaderboardModel({
    required super.id,
    required super.idFk,
    required super.username,
    required super.highScore,
    required super.avatar,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;
    return LeaderboardModel(
      id: json['id'] as String,
      idFk: json['id_fk'] as String,
      username: json['username'] as String,
      highScore: (json['highscore'] as num).toInt(),
      avatar: (profileData?['avatar'] as num?)?.toInt() ?? 0,
    );
  }
}
