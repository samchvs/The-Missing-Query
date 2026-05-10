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

  /// Submits the total accumulated points to the user's profile.
  Future<void> submitScore({required String userId, required int score});
  Future<int> getScore(String userId);
}
