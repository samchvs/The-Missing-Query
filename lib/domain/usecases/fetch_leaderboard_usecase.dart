import 'package:graphics_project/domain/entities/leaderboard_entry.dart';
import 'package:graphics_project/domain/repositories/leaderboard_repository.dart';

/// Returns the top-10 leaderboard entries.
class FetchLeaderboardUseCase {
  final LeaderboardRepository repository;

  const FetchLeaderboardUseCase(this.repository);

  Future<(List<LeaderboardEntry>, int)> call() => repository.fetchTopLeaderboard();
}
