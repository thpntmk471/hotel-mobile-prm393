import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository profileRepository;

  ProfileProvider({required this.profileRepository}) {
    loadProfile();
  }

  UserProfile? _profile;
  bool _isDarkMode = false;
  bool _isLoading = false;
  String? _message;

  UserProfile? get profile => _profile;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String? get message => _message;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await profileRepository.getUserProfile();
      _isDarkMode = _profile?.isDarkMode ?? false;
    } catch (_) {
      // Fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    if (_profile != null) {
      _profile = _profile!.copyWith(isDarkMode: isDark);
    }
    await profileRepository.updateDarkMode(isDark);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (_profile != null) {
      _profile = _profile!.copyWith(notificationsEnabled: enabled);
      await profileRepository.updateNotifications(enabled);
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String email,
  }) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      await profileRepository.updateProfile(
        fullName: fullName,
        phone: phone,
        email: email,
      );
      _profile = _profile?.copyWith(
        fullName: fullName,
        phone: phone,
        email: email,
      );
      _message = 'Cập nhật thông tin thành công!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _message = 'Lỗi cập nhật: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
