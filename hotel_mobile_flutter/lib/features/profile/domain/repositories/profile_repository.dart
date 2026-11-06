import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile();
  Future<void> updateDarkMode(bool isDarkMode);
  Future<void> updateNotifications(bool enabled);
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String email,
  });
}

