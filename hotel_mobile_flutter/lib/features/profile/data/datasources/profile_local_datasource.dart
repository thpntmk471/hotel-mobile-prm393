import '../../../../core/storage/local_storage_service.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getProfile();
  Future<void> saveDarkMode(bool isDark);
  Future<bool> getDarkMode();
  Future<void> saveNotifications(bool enabled);
  Future<void> saveProfile(UserProfileModel model);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final LocalStorageService storageService;

  ProfileLocalDataSourceImpl(this.storageService);

  @override
  Future<UserProfileModel> getProfile() async {
    final name = storageService.getUserName() ?? 'Lễ tân Demo';
    final role = storageService.getUserRole() ?? 'Receptionist';
    final email = storageService.getUserEmail() ?? '${role.toLowerCase()}@hotelmanagement.vn';
    final phone = storageService.getUserPhone() ?? '0901 234 567';
    final isDark = storageService.isDarkMode();

    return UserProfileModel(
      id: 1,
      username: name.toLowerCase().replaceAll(' ', '.'),
      fullName: name,
      role: role,
      email: email,
      phone: phone,
      department: role == 'Housekeeping'
          ? 'Bộ phận Buồng phòng'
          : role == 'Admin'
              ? 'Ban Quản trị & Điều hành Khách sạn'
              : 'Bộ phận Lễ tân & Tiền sảnh',
      joinedDate: DateTime(2024, 1, 10),
      isDarkMode: isDark,
      notificationsEnabled: true,
    );
  }

  @override
  Future<void> saveDarkMode(bool isDark) async {
    await storageService.setDarkMode(isDark);
  }

  @override
  Future<bool> getDarkMode() async {
    return storageService.isDarkMode();
  }

  @override
  Future<void> saveNotifications(bool enabled) async {
    // Saved in local storage if needed
  }

  @override
  Future<void> saveProfile(UserProfileModel model) async {
    await storageService.saveUserProfile(
      name: model.fullName,
      role: model.role,
      email: model.email,
      phone: model.phone,
    );
    await storageService.setDarkMode(model.isDarkMode);
  }
}

