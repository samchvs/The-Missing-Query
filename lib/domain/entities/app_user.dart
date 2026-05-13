class AppUser {
  final String id;
  final String email;
  final String username;
  final int avatarIndex;

  const AppUser({
    required this.id,
    required this.email,
    required this.username,
    this.avatarIndex = 0,
  });
}
