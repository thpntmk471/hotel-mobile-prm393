import '../entities/staff_member.dart';

abstract class StaffRepository {
  Future<List<StaffMember>> getStaffList({
    String? keyword,
    int? role,
    bool? isActive,
    int page = 1,
    int pageSize = 50,
  });

  Future<StaffMember> getStaffById(int id);

  Future<StaffMember> createStaff({
    required String username,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? email,
    required int role,
  });

  Future<StaffMember> updateStaff({
    required int id,
    required String fullName,
    String? phoneNumber,
    String? email,
  });

  Future<StaffMember> updateRole({
    required int id,
    required int role,
  });

  Future<StaffMember> updateStatus({
    required int id,
    required bool isActive,
  });
}
