import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> fetchStaffList({
    String? keyword,
    int? role,
    bool? isActive,
    int page = 1,
    int pageSize = 50,
  });

  Future<StaffModel> fetchStaffById(int id);

  Future<StaffModel> createStaff({
    required String username,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? email,
    required int role,
  });

  Future<StaffModel> updateStaff({
    required int id,
    required String fullName,
    String? phoneNumber,
    String? email,
  });

  Future<StaffModel> updateRole({
    required int id,
    required int role,
  });

  Future<StaffModel> updateStatus({
    required int id,
    required bool isActive,
  });
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final Dio dio;

  StaffRemoteDataSourceImpl(this.dio);

  @override
  Future<List<StaffModel>> fetchStaffList({
    String? keyword,
    int? role,
    bool? isActive,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'PageNumber': page,
        'PageSize': pageSize,
      };
      if (keyword != null && keyword.trim().isNotEmpty) {
        queryParams['Keyword'] = keyword.trim();
      }
      if (role != null && role > 0) {
        queryParams['Role'] = role;
      }
      if (isActive != null) {
        queryParams['IsActive'] = isActive;
      }

      final response = await dio.get(
        ApiConstants.staffService,
        queryParameters: queryParams,
      );

      dynamic data = response.data;
      if (data is Map && (data.containsKey('items') || data.containsKey('Items'))) {
        data = data['items'] ?? data['Items'];
      }

      if (data is List) {
        return data
            .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      // ignore: avoid_print
      print('❌ [StaffRemoteDataSource] fetchStaffList DioException: ${e.response?.data}');
      String msg = 'Không thể tải danh sách nhân viên.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StaffRemoteDataSource] fetchStaffList error: $e');
      throw Exception('Không thể tải danh sách nhân viên: $e');
    }
  }

  @override
  Future<StaffModel> fetchStaffById(int id) async {
    try {
      final response = await dio.get('${ApiConstants.staffService}/$id');
      return StaffModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      String msg = 'Không thể lấy thông tin nhân viên.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi lấy thông tin nhân viên: $e');
    }
  }

  @override
  Future<StaffModel> createStaff({
    required String username,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? email,
    required int role,
  }) async {
    try {
      final payload = {
        'username': username.trim(),
        'password': password.trim(),
        'fullName': fullName.trim(),
        'phoneNumber': (phoneNumber != null && phoneNumber.trim().isNotEmpty) ? phoneNumber.trim() : null,
        'email': (email != null && email.trim().isNotEmpty) ? email.trim() : null,
        'role': role,
      };

      final response = await dio.post(
        ApiConstants.staffService,
        data: payload,
      );

      return StaffModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // ignore: avoid_print
      print('❌ [StaffRemoteDataSource] createStaff DioException: ${e.response?.data}');
      String msg = 'Không thể tạo tài khoản nhân viên.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [StaffRemoteDataSource] createStaff error: $e');
      throw Exception('Lỗi tạo tài khoản nhân viên: $e');
    }
  }

  @override
  Future<StaffModel> updateStaff({
    required int id,
    required String fullName,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      final payload = {
        'fullName': fullName.trim(),
        'phoneNumber': (phoneNumber != null && phoneNumber.trim().isNotEmpty) ? phoneNumber.trim() : null,
        'email': (email != null && email.trim().isNotEmpty) ? email.trim() : null,
      };

      final response = await dio.put(
        '${ApiConstants.staffService}/$id',
        data: payload,
      );

      return StaffModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      String msg = 'Không thể cập nhật nhân viên.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi cập nhật nhân viên: $e');
    }
  }

  @override
  Future<StaffModel> updateRole({
    required int id,
    required int role,
  }) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.staffService}/$id/role',
        data: {'role': role},
      );
      return StaffModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      String msg = 'Không thể đổi vai trò nhân viên.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi đổi vai trò: $e');
    }
  }

  @override
  Future<StaffModel> updateStatus({
    required int id,
    required bool isActive,
  }) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.staffService}/$id/status',
        data: {'isActive': isActive},
      );
      return StaffModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      String msg = 'Không thể cập nhật trạng thái hoạt động.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['message']?.toString() ?? d['title']?.toString() ?? msg;
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái: $e');
    }
  }
}

