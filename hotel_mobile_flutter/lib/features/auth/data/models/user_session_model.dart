import 'dart:convert';
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
    // 1. Kiểm tra object lồng 'user' hoặc 'User' từ ASP.NET Core Web API
    final userObj = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : (json['User'] is Map<String, dynamic>)
            ? json['User'] as Map<String, dynamic>
            : json;

    final rawToken = json['token'] ?? json['Token'] ?? json['accessToken'];
    if (rawToken == null || rawToken.toString().trim().isEmpty) {
      throw const FormatException('Phản hồi từ máy chủ không chứa mã xác thực JWT (Token).');
    }
    final token = rawToken.toString().trim();

    // 2. Trích xuất và chuẩn hóa Role
    String extractedRole = '';
    final rawRoleName = userObj['roleName'] ?? userObj['RoleName'];
    final rawRoleByte = userObj['role'] ?? userObj['Role'];

    if (rawRoleName != null && rawRoleName.toString().trim().isNotEmpty) {
      final name = rawRoleName.toString().trim();
      final lower = name.toLowerCase();
      if (lower.contains('admin')) {
        extractedRole = 'Admin';
      } else if (lower.contains('house') || lower.contains('room') || lower.contains('buồng')) {
        extractedRole = 'Housekeeping';
      } else if (lower.contains('reception') || lower.contains('tân')) {
        extractedRole = 'Receptionist';
      } else {
        extractedRole = name;
      }
    } else if (rawRoleByte != null) {
      // PRN232 AccountRoles: 1 Admin, 2 Receptionist, 3 StaffRoom
      final rInt = int.tryParse(rawRoleByte.toString());
      if (rInt == 1) {
        extractedRole = 'Admin';
      } else if (rInt == 3) {
        extractedRole = 'Housekeeping';
      } else if (rInt == 2) {
        extractedRole = 'Receptionist';
      }
    }

    // 3. Fallback đọc Role từ JWT Token claims nếu có
    if (extractedRole.isEmpty && token.contains('.')) {
      try {
        final parts = token.split('.');
        if (parts.length >= 2) {
          final normalized = base64Url.normalize(parts[1]);
          final payloadStr = utf8.decode(base64Url.decode(normalized));
          final payload = jsonDecode(payloadStr) as Map<String, dynamic>;
          final claimRole = payload['role'] ??
              payload['Role'] ??
              payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
          if (claimRole != null) {
            final c = claimRole.toString().toLowerCase();
            if (c.contains('admin')) {
              extractedRole = 'Admin';
            } else if (c.contains('house') || c.contains('room') || c.contains('buồng')) {
              extractedRole = 'Housekeeping';
            } else if (c.contains('reception')) {
              extractedRole = 'Receptionist';
            }
          }
        }
      } catch (_) {}
    }

    // 4. Fallback nhận diện theo username nếu vẫn rỗng
    final rawUsername = (userObj['username'] ?? userObj['Username'] ?? json['username'] ?? '').toString();
    if (extractedRole.isEmpty) {
      final uLower = rawUsername.toLowerCase();
      if (uLower.contains('admin')) {
        extractedRole = 'Admin';
      } else if (uLower.contains('house') || uLower.contains('room')) {
        extractedRole = 'Housekeeping';
      } else {
        extractedRole = 'Receptionist';
      }
    }

    // 5. Trích xuất FullName
    final rawFullName = userObj['fullName'] ?? userObj['FullName'] ?? userObj['name'];
    final fullName = (rawFullName != null && rawFullName.toString().trim().isNotEmpty)
        ? rawFullName.toString().trim()
        : (extractedRole == 'Admin'
            ? 'Quản trị viên'
            : extractedRole == 'Housekeeping'
                ? 'Nhân viên Buồng phòng'
                : 'Lễ tân Khách sạn');

    // 6. Trích xuất User ID
    final rawId = userObj['id'] ?? userObj['Id'] ?? userObj['userId'] ?? 1;
    final userId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 1;

    return UserSessionModel(
      userId: userId,
      username: rawUsername.isNotEmpty ? rawUsername : 'user',
      fullName: fullName,
      role: extractedRole,
      token: token,
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
