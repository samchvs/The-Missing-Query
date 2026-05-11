import 'package:graphics_project/domain/entities/app_user.dart';

abstract class AuthRepository {
  /// Signs up a new user with email, password, and display username.
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String username,
  });

  /// Signs in an existing user with email and password.
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Returns the currently authenticated user from the active session, or null.
  AppUser? getCurrentUser();

  /// Submits the total accumulated points to the user's profile (high_score column).
  Future<void> submitScore({required String userId, required int score});

  /// Returns the total high_score from the profiles table.
  Future<int> getScore(String userId);

  /// Returns per-case points as a map: {'case1': x, 'case2': y, 'case3': z}
  Future<Map<String, int>> getCasePoints(String userId);

  /// Updates a specific case's points in Supabase (only if higher).
  Future<void> updateCasePoints({
    required String userId,
    required String caseId,
    required int points,
  });
}
