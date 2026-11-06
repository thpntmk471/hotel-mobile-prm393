import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage_service.dart';

class DioClient {
  final LocalStorageService _storageService;
  late final Dio dio;

  DioClient(this._storageService) {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Tự động gắn Bearer Token vào Header cho mọi request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Xử lý 401 Unauthorized (khi token hết hạn)
          if (error.response?.statusCode == 401) {
            await _storageService.clearAuth();
          }
          return handler.next(error);
        },
      ),
    );
  }
}

