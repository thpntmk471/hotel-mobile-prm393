import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserSessionModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserSessionModel> login(String username, String password) async {
    try {
      final response = await dio.post(
        '${ApiConstants.authService}/login',
        data: {'username': username.trim(), 'password': password.trim()},
      );
      return UserSessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Tên đăng nhập hoặc mật khẩu không chính xác.');
      } else if (e.response?.statusCode == 403) {
        final msg = e.response?.data?['message'] ?? 'Tài khoản của bạn đã bị khóa hoặc không có quyền.';
        throw Exception(msg.toString());
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Nếu Backend chưa chạy, cung cấp chế độ Mock Demo kèm thông báo
        final u = username.toLowerCase().trim();
        if (u.startsWith('demo.')) {
          return _generateDemoSession(username);
        }
        throw Exception(
          'Không thể kết nối đến máy chủ AuthAPI (${ApiConstants.authService}). '
          'Vui lòng đảm bảo đã chạy backend (chạy file run_backend.ps1).',
        );
      } else {
        final serverMsg = e.response?.data?['message'] ?? e.message;
        throw Exception('Lỗi đăng nhập [HTTP ${e.response?.statusCode}]: $serverMsg');
      }
    } catch (e) {
      throw Exception('Lỗi xử lý dữ liệu đăng nhập: $e');
    }
  }

  UserSessionModel _generateDemoSession(String username) {
    final u = username.toLowerCase().trim();
    if (u.contains('admin')) {
      return UserSessionModel(
        userId: 1,
        username: username,
        fullName: 'Quản trị Demo',
        role: 'Admin',
        token: 'mock_jwt_token_admin_2026',
      );
    } else if (u.contains('house') || u.contains('room') || u.contains('buồng')) {
      return UserSessionModel(
        userId: 3,
        username: username,
        fullName: 'Buồng phòng Demo',
        role: 'Housekeeping',
        token: 'mock_jwt_token_housekeeping_2026',
      );
    } else {
      return UserSessionModel(
        userId: 2,
        username: username,
        fullName: 'Lễ tân Demo',
        role: 'Receptionist',
        token: 'mock_jwt_token_reception_2026',
      );
    }
  }
}
