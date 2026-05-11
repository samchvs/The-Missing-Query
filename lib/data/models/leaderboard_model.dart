import 'package:graphics_project/domain/entities/leaderboard_entry.dart';

/// JSON ↔ entity adapter for a leaderboard row.
class LeaderboardModel extends LeaderboardEntry {
  const LeaderboardModel({
    required super.id,
    required super.idFk,
    required super.username,
    required super.highScore,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: json['id'] as String,
      idFk: json['id_fk'] as String,
      username: json['username'] as String,
      highScore: (json['highscore'] as num).toInt(),
    );
  }
}
