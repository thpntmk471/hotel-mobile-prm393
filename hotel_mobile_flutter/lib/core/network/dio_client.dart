import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

    // Logging interceptor để debug kết nối API thật trực tiếp
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('🌐 [DIO REQ] ${options.method} ${options.uri}');
          if (options.data != null) {
            debugPrint('   Payload: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ [DIO RES] [${response.statusCode}] ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          debugPrint('❌ [DIO ERR] [${error.response?.statusCode}] ${error.requestOptions.uri}');
          debugPrint('   Detail: ${error.message} | Response: ${error.response?.data}');
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

