class HousekeepingTask {
  final int id;
  final String taskCode;
  final int roomId;
  final String roomNumber;
  final int floor;
  final String roomTypeName;
  final int taskType; // 1: Housekeeping, 2: Maintenance
  final String taskTypeName;
  final int? housekeepingKind; // 1: Dọn phòng, 2: Kiểm tra phòng
  final String title;
  final String description;
  final int priority; // 1: Thấp, 2: Bình thường, 3: Cao, 4: Khẩn cấp
  final String priorityName;
  final int status; // 1: Chờ phân công, 2: Đã phân công, 3: Đang thực hiện, 4: Hoàn thành, 5: Đã hủy
  final String statusName;
  final String? assignedStaff;
  final int? assignedToAccountId;
  final int createdByAccountId;
  final DateTime? dueAt;
  final DateTime? startedAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? completedByAccountId;
  final String? completionNotes;
  final String rowVersion;

  const HousekeepingTask({
    required this.id,
    required this.taskCode,
    required this.roomId,
    this.roomNumber = '',
    this.floor = 1,
    this.roomTypeName = '',
    this.taskType = 1,
    this.taskTypeName = 'Housekeeping',
    this.housekeepingKind = 1,
    required this.title,
    this.description = '',
    this.priority = 2,
    this.priorityName = 'Bình thường',
    this.status = 1,
    this.statusName = 'Chờ phân công',
    this.assignedStaff,
    this.assignedToAccountId,
    this.createdByAccountId = 1,
    this.dueAt,
    this.startedAt,
    required this.createdAt,
    this.completedAt,
    this.completedByAccountId,
    this.completionNotes,
    this.rowVersion = '',
  });

  bool get isPending => status == 1 || statusName.toLowerCase().contains('chờ');
  bool get isAssigned => status == 2 || statusName.toLowerCase().contains('phân công') || statusName.toLowerCase().contains('assigned');
  bool get isInProgress => status == 3 || statusName.toLowerCase().contains('đang') || statusName.toLowerCase().contains('progress');
  bool get isDone => isCompleted;
  bool get isCompleted => status == 4 || statusName.toLowerCase().contains('hoàn') || statusName.toLowerCase().contains('completed');
  bool get isCancelled => status == 5 || statusName.toLowerCase().contains('hủy') || statusName.toLowerCase().contains('cancelled');

  bool get isHousekeeping => taskType == 1 || taskTypeName.toLowerCase().contains('house');
  bool get isMaintenance => taskType == 2 || taskTypeName.toLowerCase().contains('maint') || taskTypeName.toLowerCase().contains('trì');

  String get displayKindName {
    if (isMaintenance) return 'Bảo trì phòng';
    return housekeepingKind == 2 ? 'Kiểm tra phòng' : 'Dọn phòng';
  }

  String get displayPriorityName {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Bình thường';
      case 3:
        return 'Cao';
      case 4:
        return 'Khẩn cấp';
      default:
        return priorityName.isNotEmpty ? priorityName : 'Bình thường';
    }
  }

  String get displayStatusName {
    switch (status) {
      case 1:
        return 'Chờ phân công';
      case 2:
        return 'Đã phân công';
      case 3:
        return 'Đang thực hiện';
      case 4:
        return 'Hoàn thành';
      case 5:
        return 'Đã hủy';
      default:
        return statusName.isNotEmpty ? statusName : 'Chờ phân công';
    }
  }

  HousekeepingTask copyWith({
    int? id,
    String? taskCode,
    int? roomId,
    String? roomNumber,
    int? floor,
    String? roomTypeName,
    int? taskType,
    String? taskTypeName,
    int? housekeepingKind,
    String? title,
    String? description,
    int? priority,
    String? priorityName,
    int? status,
    String? statusName,
    String? assignedStaff,
    int? assignedToAccountId,
    int? createdByAccountId,
    DateTime? dueAt,
    DateTime? startedAt,
    DateTime? createdAt,
    DateTime? completedAt,
    int? completedByAccountId,
    String? completionNotes,
    String? rowVersion,
  }) {
    return HousekeepingTask(
      id: id ?? this.id,
      taskCode: taskCode ?? this.taskCode,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      roomTypeName: roomTypeName ?? this.roomTypeName,
      taskType: taskType ?? this.taskType,
      taskTypeName: taskTypeName ?? this.taskTypeName,
      housekeepingKind: housekeepingKind ?? this.housekeepingKind,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      priorityName: priorityName ?? this.priorityName,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      assignedToAccountId: assignedToAccountId ?? this.assignedToAccountId,
      createdByAccountId: createdByAccountId ?? this.createdByAccountId,
      dueAt: dueAt ?? this.dueAt,
      startedAt: startedAt ?? this.startedAt,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      completedByAccountId: completedByAccountId ?? this.completedByAccountId,
      completionNotes: completionNotes ?? this.completionNotes,
      rowVersion: rowVersion ?? this.rowVersion,
    );
  }
}
