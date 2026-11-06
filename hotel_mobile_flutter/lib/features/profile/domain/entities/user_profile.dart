class UserProfile {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final String email;
  final String phone;
  final String department;
  final DateTime joinedDate;
  final bool isDarkMode;
  final bool notificationsEnabled;

  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.email,
    required this.phone,
    required this.department,
    required this.joinedDate,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
  });

  UserProfile copyWith({
    int? id,
    String? username,
    String? fullName,
    String? role,
    String? email,
    String? phone,
    String? department,
    DateTime? joinedDate,
    bool? isDarkMode,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      joinedDate: joinedDate ?? this.joinedDate,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

