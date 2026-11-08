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
        throw Exception(
          'Không thể kết nối đến máy chủ AuthAPI (${ApiConstants.authService}). '
          'Vui lòng đảm bảo backend đang chạy (run_backend.ps1).',
        );
      } else {
        final serverMsg = e.response?.data?['message'] ?? e.message;
        throw Exception('Lỗi đăng nhập [HTTP ${e.response?.statusCode}]: $serverMsg');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi xử lý dữ liệu đăng nhập: $e');
    }
  }
}
