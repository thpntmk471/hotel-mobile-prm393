import '../../domain/entities/audit_log_item.dart';

class AuditLogModel {
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

  const AuditLogModel({
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

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    final rawId = json['id'] ?? json['Id'] ?? 0;
    final id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawActorId = json['actorAccountId'] ?? json['ActorAccountId'];
    final actorId = rawActorId == null
        ? null
        : (rawActorId is int ? rawActorId : int.tryParse(rawActorId.toString()));

    return AuditLogModel(
      id: id,
      actorAccountId: actorId,
      actorUsernameSnapshot: (json['actorUsernameSnapshot'] ?? json['ActorUsernameSnapshot'])?.toString(),
      action: (json['action'] ?? json['Action'] ?? 'UNKNOWN').toString(),
      entityType: (json['entityType'] ?? json['EntityType'] ?? '').toString(),
      entityId: (json['entityId'] ?? json['EntityId'] ?? '').toString(),
      entityCodeSnapshot: (json['entityCodeSnapshot'] ?? json['EntityCodeSnapshot'])?.toString(),
      occurredAt: parseDate(json['occurredAt'] ?? json['OccurredAt']),
      summary: (json['summary'] ?? json['Summary'] ?? '').toString(),
      oldValuesJson: (json['oldValuesJson'] ?? json['OldValuesJson'])?.toString(),
      newValuesJson: (json['newValuesJson'] ?? json['NewValuesJson'])?.toString(),
      correlationId: (json['correlationId'] ?? json['CorrelationId'])?.toString(),
    );
  }

  AuditLogItem toEntity() {
    return AuditLogItem(
      id: id,
      actorAccountId: actorAccountId,
      actorUsernameSnapshot: actorUsernameSnapshot,
      action: action,
      entityType: entityType,
      entityId: entityId,
      entityCodeSnapshot: entityCodeSnapshot,
      occurredAt: occurredAt,
      summary: summary,
      oldValuesJson: oldValuesJson,
      newValuesJson: newValuesJson,
      correlationId: correlationId,
    );
  }
}

class AuditLogPageModel {
  final List<AuditLogModel> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const AuditLogPageModel({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory AuditLogPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['Items'] ?? [];
    final itemsList = (rawItems is List)
        ? rawItems.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>)).toList()
        : <AuditLogModel>[];

    final totalCount = (json['totalCount'] ?? json['TotalCount'] ?? itemsList.length) as int;
    final pageNumber = (json['pageNumber'] ?? json['PageNumber'] ?? 1) as int;
    final pageSize = (json['pageSize'] ?? json['PageSize'] ?? 20) as int;
    final totalPages = (json['totalPages'] ?? json['TotalPages'] ?? 1) as int;
    final hasPrev = (json['hasPreviousPage'] ?? json['HasPreviousPage'] ?? (pageNumber > 1)) as bool;
    final hasNext = (json['hasNextPage'] ?? json['HasNextPage'] ?? (pageNumber < totalPages)) as bool;

    return AuditLogPageModel(
      items: itemsList,
      totalCount: totalCount,
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalPages: totalPages,
      hasPreviousPage: hasPrev,
      hasNextPage: hasNext,
    );
  }

  AuditLogPage toEntity() {
    return AuditLogPage(
      items: items.map((e) => e.toEntity()).toList(),
      totalCount: totalCount,
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalPages: totalPages,
      hasPreviousPage: hasPreviousPage,
      hasNextPage: hasNextPage,
    );
  }
}

