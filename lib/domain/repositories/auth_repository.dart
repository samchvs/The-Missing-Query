import 'package:graphics_project/domain/entities/app_user.dart';

/// Abstract contract for authentication.
/// No Supabase imports — inner layer only.
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
}
