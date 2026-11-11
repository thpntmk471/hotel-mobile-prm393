class AuditLogItem {
  final int id;
  final int? actorAccountId;
  final String? actorUsernameSnapshot;
  final String action;
  final String entityType;
  final String entityId;
  final String? entityCodeSnapshot;
  final DateTime occurredAt;
  final String summary;
  final String? oldValuesJson;
  final String? newValuesJson;
  final String? correlationId;

  const AuditLogItem({
    required this.id,
    this.actorAccountId,
    this.actorUsernameSnapshot,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.entityCodeSnapshot,
    required this.occurredAt,
    required this.summary,
    this.oldValuesJson,
    this.newValuesJson,
    this.correlationId,
  });
}

class AuditLogPage {
  final List<AuditLogItem> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const AuditLogPage({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}
