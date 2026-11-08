import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_datasource.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StaffMember>> getStaffList({
    String? keyword,
    int? role,
    bool? isActive,
    int page = 1,
    int pageSize = 50,
  }) {
    return remoteDataSource.fetchStaffList(
      keyword: keyword,
      role: role,
      isActive: isActive,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<StaffMember> getStaffById(int id) {
    return remoteDataSource.fetchStaffById(id);
  }

  @override
  Future<StaffMember> createStaff({
    required String username,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? email,
    required int role,
  }) {
    return remoteDataSource.createStaff(
      username: username,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
    );
  }

  @override
  Future<StaffMember> updateStaff({
    required int id,
    required String fullName,
    String? phoneNumber,
    String? email,
  }) {
    return remoteDataSource.updateStaff(
      id: id,
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
    );
  }

  @override
  Future<StaffMember> updateRole({
    required int id,
    required int role,
  }) {
    return remoteDataSource.updateRole(
      id: id,
      role: role,
    );
  }

  @override
  Future<StaffMember> updateStatus({
    required int id,
    required bool isActive,
  }) {
    return remoteDataSource.updateStatus(
      id: id,
      isActive: isActive,
    );
  }
}
