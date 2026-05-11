import 'package:graphics_project/data/datasources/supabase_leaderboard_datasource.dart';
import 'package:graphics_project/domain/entities/leaderboard_entry.dart';
import 'package:graphics_project/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final SupabaseLeaderboardDataSource _dataSource;

  LeaderboardRepositoryImpl(this._dataSource);

  @override
  Future<(List<LeaderboardEntry>, int)> fetchTopLeaderboard() =>
      _dataSource.fetchTopLeaderboard();

  @override
  Future<void> pushScore({
    required String userId,
    required String username,
    required int score,
  }) =>
      _dataSource.pushScore(
        userId: userId,
        username: username,
        score: score,
      );
}
