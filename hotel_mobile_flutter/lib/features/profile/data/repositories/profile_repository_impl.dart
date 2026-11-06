import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<UserProfile> getUserProfile() async {
    final model = await localDataSource.getProfile();
    return model.toEntity();
  }

  @override
  Future<void> updateDarkMode(bool isDarkMode) async {
    await localDataSource.saveDarkMode(isDarkMode);
  }

  @override
  Future<void> updateNotifications(bool enabled) async {
    await localDataSource.saveNotifications(enabled);
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String email,
  }) async {
    final current = await localDataSource.getProfile();
    final updated = UserProfileModel(
      id: current.id,
      username: current.username,
      fullName: fullName,
      role: current.role,
      email: email,
      phone: phone,
      department: current.department,
      joinedDate: current.joinedDate,
      isDarkMode: current.isDarkMode,
      notificationsEnabled: current.notificationsEnabled,
    );
    await localDataSource.saveProfile(updated);
  }
}
