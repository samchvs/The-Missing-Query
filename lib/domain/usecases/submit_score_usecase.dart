import 'package:graphics_project/domain/repositories/auth_repository.dart';

/// Submits a score to Supabase — only updates if it beats the current high score.
/// Silently does nothing if the user is not logged in (guest mode).
class SubmitScoreUseCase {
  final AuthRepository repository;

  const SubmitScoreUseCase(this.repository);

  Future<void> call({required String? userId, required int score}) async {
    // Guest users (no Supabase session) — skip silently
    if (userId == null || userId.isEmpty) return;
    await repository.submitScore(userId: userId, score: score);
  }
}
