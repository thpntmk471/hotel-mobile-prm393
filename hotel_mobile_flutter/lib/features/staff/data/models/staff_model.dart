import '../../domain/entities/staff_member.dart';

class StaffModel extends StaffMember {
  const StaffModel({
    required super.id,
    required super.username,
    required super.fullName,
    super.phoneNumber,
    super.email,
    required super.role,
    required super.roleName,
    required super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    int idVal = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    String userVal = json['username']?.toString() ?? '';
    String nameVal = json['fullName']?.toString() ?? userVal;
    String? phoneVal = json['phoneNumber']?.toString();
    String? emailVal = json['email']?.toString();

    int roleVal = 2;
    if (json['role'] is int) {
      roleVal = json['role'] as int;
    } else if (json['role'] != null) {
      roleVal = int.tryParse(json['role'].toString()) ?? 2;
    }

    String roleNameVal = json['roleName']?.toString() ?? '';
    if (roleNameVal.isEmpty) {
      if (roleVal == 1) {
        roleNameVal = 'Admin';
      } else if (roleVal == 2) {
        roleNameVal = 'Receptionist';
      } else if (roleVal == 3) {
        roleNameVal = 'Staff Room';
      }
    }

    bool activeVal = json['isActive'] is bool
        ? json['isActive'] as bool
        : json['isActive']?.toString().toLowerCase() == 'true';

    DateTime createdVal = DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();
    DateTime? updatedVal = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'].toString())
        : null;

    return StaffModel(
      id: idVal,
      username: userVal,
      fullName: nameVal,
      phoneNumber: (phoneVal != null && phoneVal.isNotEmpty) ? phoneVal : null,
      email: (emailVal != null && emailVal.isNotEmpty) ? emailVal : null,
      role: roleVal,
      roleName: roleNameVal,
      isActive: activeVal,
      createdAt: createdVal,
      updatedAt: updatedVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'roleName': roleName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
