import 'package:graphics_project/data/repositories/auth_repository_impl.dart';

/// Submits a score to Supabase — only updates if it beats the current high score.
/// Silently does nothing if the user is not logged in (guest mode).
class SubmitScoreUseCase {
  final AuthRepositoryImpl repository;

  const SubmitScoreUseCase(this.repository);

  Future<void> call({required String? userId, required int score}) async {
    // Guest users (no Supabase session) — skip silently
    if (userId == null || userId.isEmpty) return;
    await repository.submitHighScore(userId: userId, score: score);
  }
}
