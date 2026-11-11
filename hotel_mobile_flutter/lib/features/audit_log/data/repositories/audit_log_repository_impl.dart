import '../../domain/entities/audit_log_item.dart';
import '../../domain/repositories/audit_log_repository.dart';
import '../datasources/audit_log_remote_datasource.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final AuditLogRemoteDataSource remoteDataSource;

  AuditLogRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuditLogPage> getAuditLogs({
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
    final model = await remoteDataSource.fetchAuditLogs(
      page: page,
      pageSize: pageSize,
      keyword: keyword,
      action: action,
      entityType: entityType,
      actorAccountId: actorAccountId,
      entityId: entityId,
      fromDate: fromDate,
      toDate: toDate,
    );
    return model.toEntity();
  }

  @override
  Future<AuditLogItem> getAuditLogById(int id) async {
    final model = await remoteDataSource.fetchAuditLogById(id);
    return model.toEntity();
  }
}

