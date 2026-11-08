class StaffMember {
  final int id;
  final String username;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final int role; // 1: Admin, 2: Receptionist, 3: Staff Room
  final String roleName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StaffMember({
    required this.id,
    required this.username,
    required this.fullName,
    this.phoneNumber,
    this.email,
    required this.role,
    required this.roleName,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayRole {
    if (role == 1 || roleName.toLowerCase().contains('admin')) return 'Admin';
    if (role == 2 || roleName.toLowerCase().contains('reception')) return 'Receptionist';
    if (role == 3 || roleName.toLowerCase().contains('room') || roleName.toLowerCase().contains('house')) {
      return 'Staff Room';
    }
    return roleName.isNotEmpty ? roleName : 'Staff';
  }

  StaffMember copyWith({
    int? id,
    String? username,
    String? fullName,
    String? phoneNumber,
    String? email,
    int? role,
    String? roleName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffMember(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      roleName: roleName ?? this.roleName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
