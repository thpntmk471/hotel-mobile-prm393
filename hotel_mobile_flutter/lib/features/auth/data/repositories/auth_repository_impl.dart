import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<UserSession> login({required String username, required String password}) async {
    final model = await remoteDataSource.login(username, password);
    final entity = model.toEntity();

    // Lưu session và token an toàn vào storage cục bộ
    await storageService.saveTokens(accessToken: entity.token);
    await storageService.saveUserProfile(name: entity.fullName, role: entity.role);

    return entity;
  }

  @override
  Future<void> logout() async {
    await storageService.clearAuth();
  }

  @override
  Future<UserSession?> getCachedSession() async {
    final token = await storageService.getAccessToken();
    final name = storageService.getUserName();
    final role = storageService.getUserRole();

    if (token != null && name != null) {
      return UserSession(
        userId: 1,
        username: 'saved_user',
        fullName: name,
        role: role ?? 'Receptionist',
        token: token,
      );
    }
    return null;
  }
}

