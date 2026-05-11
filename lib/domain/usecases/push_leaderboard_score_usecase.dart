import 'package:graphics_project/domain/repositories/leaderboard_repository.dart';

/// Pushes the user's current score into the remote leaderboard
class PushLeaderboardScoreUseCase {
  final LeaderboardRepository repository;

  const PushLeaderboardScoreUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String username,
    required int score,
  }) =>
      repository.pushScore(
        userId: userId,
        username: username,
        score: score,
      );
}
