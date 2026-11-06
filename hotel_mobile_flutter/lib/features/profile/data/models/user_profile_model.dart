import '../../domain/entities/user_profile.dart';

class UserProfileModel {
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

  const UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int? ?? 1,
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Nhân viên',
      role: json['role'] as String? ?? 'Receptionist',
      email: json['email'] as String? ?? 'staff@hotelprm.com',
      phone: json['phone'] as String? ?? '0987 654 321',
      department: json['department'] as String? ?? 'Bộ phận Tiền sảnh & Lễ tân',
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'] as String)
          : DateTime(2024, 1, 15),
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'role': role,
      'email': email,
      'phone': phone,
      'department': department,
      'joinedDate': joinedDate.toIso8601String(),
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      username: username,
      fullName: fullName,
      role: role,
      email: email,
      phone: phone,
      department: department,
      joinedDate: joinedDate,
      isDarkMode: isDarkMode,
      notificationsEnabled: notificationsEnabled,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      username: entity.username,
      fullName: entity.fullName,
      role: entity.role,
      email: entity.email,
      phone: entity.phone,
      department: entity.department,
      joinedDate: entity.joinedDate,
      isDarkMode: entity.isDarkMode,
      notificationsEnabled: entity.notificationsEnabled,
    );
  }
}

