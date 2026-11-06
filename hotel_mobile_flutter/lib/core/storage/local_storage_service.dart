import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  LocalStorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  // Secure Storage (Dùng cho JWT Tokens nhạy cảm)
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  Future<void> clearAuth() async {
    await _secureStorage.deleteAll();
    await _prefs.remove(StorageKeys.userName);
    await _prefs.remove(StorageKeys.userRole);
  }

  // SharedPreferences (Dùng cho thông tin hiển thị & cấu hình người dùng)
  Future<void> saveUserProfile({required String name, required String role}) async {
    await _prefs.setString(StorageKeys.userName, name);
    await _prefs.setString(StorageKeys.userRole, role);
  }

  String? getUserName() => _prefs.getString(StorageKeys.userName);
  String? getUserRole() => _prefs.getString(StorageKeys.userRole);

  // Cấu hình giao diện & cài đặt ứng dụng
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(StorageKeys.isDarkMode, isDark);
  }

  bool isDarkMode() => _prefs.getBool(StorageKeys.isDarkMode) ?? false;
}

