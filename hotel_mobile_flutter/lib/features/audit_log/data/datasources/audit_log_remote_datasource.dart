import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/audit_log_model.dart';

abstract class AuditLogRemoteDataSource {
  Future<AuditLogPageModel> fetchAuditLogs({
    int page = 1,
    int pageSize = 20,
    String? keyword,
    String? action,
    String? entityType,
    int? actorAccountId,
    String? entityId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<AuditLogModel> fetchAuditLogById(int id);
}

class AuditLogRemoteDataSourceImpl implements AuditLogRemoteDataSource {
  final Dio dio;

  AuditLogRemoteDataSourceImpl(this.dio);

  @override
  Future<AuditLogPageModel> fetchAuditLogs({
    int page = 1,
    int pageSize = 20,
    String? keyword,
    String? action,
    String? entityType,
    int? actorAccountId,
    String? entityId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'PageNumber': page,
        'PageSize': pageSize,
      };

      if (keyword != null && keyword.trim().isNotEmpty) {
        queryParams['Keyword'] = keyword.trim();
      }
      if (action != null && action.trim().isNotEmpty) {
        queryParams['Action'] = action.trim();
      }
      if (entityType != null && entityType.trim().isNotEmpty) {
        queryParams['EntityType'] = entityType.trim();
      }
      if (actorAccountId != null && actorAccountId > 0) {
        queryParams['ActorAccountId'] = actorAccountId;
      }
      if (entityId != null && entityId.trim().isNotEmpty) {
        queryParams['EntityId'] = entityId.trim();
      }
      if (fromDate != null) {
        queryParams['FromUtc'] = fromDate.toUtc().toIso8601String();
      }
      if (toDate != null) {
        queryParams['ToUtc'] = toDate.toUtc().toIso8601String();
      }

      final response = await dio.get(
        ApiConstants.auditService,
        queryParameters: queryParams,
      );

      return AuditLogPageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response!.data as Map).containsKey('message')
          ? (e.response!.data as Map)['message'].toString()
          : 'Không thể tải danh sách nhật ký hoạt động (Lỗi ${e.response?.statusCode ?? 'mạng'}).';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi nạp nhật ký: $e');
    }
  }

  @override
  Future<AuditLogModel> fetchAuditLogById(int id) async {
    try {
      final response = await dio.get('${ApiConstants.auditService}/$id');
      return AuditLogModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response!.data as Map).containsKey('message')
          ? (e.response!.data as Map)['message'].toString()
          : 'Không tìm thấy nhật ký #$id.';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Lỗi đọc chi tiết nhật ký: $e');
    }
  }
}
