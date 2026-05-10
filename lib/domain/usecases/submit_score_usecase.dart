import 'package:graphics_project/domain/repositories/auth_repository.dart';

/// Submits a score to Supabase 
/// Updates high score
class SubmitScoreUseCase {
  final AuthRepository repository;

  const SubmitScoreUseCase(this.repository);

  Future<void> call({required String? userId, required int score}) async {
    if (userId == null || userId.isEmpty) return;
    await repository.submitScore(userId: userId, score: score);
  }
}
