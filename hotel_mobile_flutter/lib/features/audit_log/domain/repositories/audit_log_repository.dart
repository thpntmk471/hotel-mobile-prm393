import '../entities/audit_log_item.dart';

abstract class AuditLogRepository {
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
  });

  Future<AuditLogItem> getAuditLogById(int id);
}

