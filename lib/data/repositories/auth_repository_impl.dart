import 'package:graphics_project/data/datasources/supabase_auth_datasource.dart';
import 'package:graphics_project/domain/entities/app_user.dart';
import 'package:graphics_project/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String username,
  }) {
    return _dataSource.signUp(
      email: email,
      password: password,
      username: username,
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) {
    return _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  AppUser? getCurrentUser() => _dataSource.getCurrentUser();

  Future<void> updateUsername({
    required String userId,
    required String username,
  }) => _dataSource.updateUsername(userId: userId, username: username);

  @override
  Future<void> submitScore({
    required String userId,
    required int score,
  }) => _dataSource.submitScore(userId: userId, score: score);

  @override
  Future<int> getScore(String userId) => _dataSource.getHighScore(userId);

  @override
  Future<Map<String, int>> getCasePoints(String userId) =>
      _dataSource.getCasePoints(userId);

  @override
  Future<void> updateCasePoints({
    required String userId,
    required String caseId,
    required int points,
  }) => _dataSource.updateCasePoints(
        userId: userId,
        caseId: caseId,
        points: points,
      );

  @override
  Future<String?> fetchUsername(String userId) =>
      _dataSource.fetchUsername(userId);
}
