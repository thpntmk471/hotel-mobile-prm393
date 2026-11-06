import '../../domain/entities/user_session.dart';

class UserSessionModel {
  final int userId;
  final String username;
  final String fullName;
  final String role;
  final String token;

  UserSessionModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    required this.token,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      userId: json['userId'] ?? json['id'] ?? 1,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? 'Lễ tân Demo',
      role: json['role'] ?? 'Receptionist',
      token: json['token'] ?? json['accessToken'] ?? 'mock_jwt_token',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'role': role,
      'token': token,
    };
  }

  UserSession toEntity() {
    return UserSession(
      userId: userId,
      username: username,
      fullName: fullName,
      role: role,
      token: token,
    );
  }
}

