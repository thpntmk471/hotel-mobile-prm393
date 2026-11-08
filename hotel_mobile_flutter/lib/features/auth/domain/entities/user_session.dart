class UserSession {
  final int userId;
  final String username;
  final String fullName;
  final String role; // Receptionist, Housekeeping, Guest, Admin
  final String token;
  final String? email;
  final String? phone;

  const UserSession({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    required this.token,
    this.email,
    this.phone,
  });
}

