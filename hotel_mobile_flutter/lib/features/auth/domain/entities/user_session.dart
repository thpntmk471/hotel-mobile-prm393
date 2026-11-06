class UserSession {
  final int userId;
  final String username;
  final String fullName;
  final String role; // Receptionist, Staff, Guest, Admin
  final String token;

  const UserSession({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    required this.token,
  });
}

