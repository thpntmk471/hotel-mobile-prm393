import '../entities/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login({required String username, required String password});
  Future<void> logout();
  Future<UserSession?> getCachedSession();
}
