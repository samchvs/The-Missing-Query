/// Pure Dart entity representing an authenticated user.
/// No Supabase imports — inner layer only.
class AppUser {
  final String id;
  final String email;
  final String username;

  const AppUser({
    required this.id,
    required this.email,
    required this.username,
  });
}
