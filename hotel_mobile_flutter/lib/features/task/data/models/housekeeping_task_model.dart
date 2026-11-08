import '../../domain/entities/housekeeping_task.dart';

class HousekeepingTaskModel {
  final int id;
  final String taskCode;
  final int roomId;
  final String roomNumber;
  final int floor;
  final String roomTypeName;
  final int taskType;
  final String taskTypeName;
  final int? housekeepingKind;
  final String title;
  final String description;
  final int priority;
  final String priorityName;
  final int status;
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

  HousekeepingTaskModel({
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

  factory HousekeepingTaskModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['Id'] ?? 1;
    final id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 1;
    final taskCode = (json['taskCode'] ?? json['TaskCode'] ?? 'TSK-$id').toString();
    final rawRoomId = json['roomId'] ?? json['RoomId'] ?? 1;
    final roomId = rawRoomId is int ? rawRoomId : int.tryParse(rawRoomId.toString()) ?? 1;

    final rawTaskType = json['taskType'] ?? json['TaskType'] ?? 1;
    final taskType = rawTaskType is int ? rawTaskType : int.tryParse(rawTaskType.toString()) ?? 1;
    final taskTypeName = (json['taskTypeName'] ?? json['TaskTypeName'] ?? (taskType == 2 ? 'Maintenance' : 'Housekeeping')).toString();

    final rawHkKind = json['housekeepingKind'] ?? json['HousekeepingKind'];
    final housekeepingKind = rawHkKind != null ? int.tryParse(rawHkKind.toString()) : null;

    final title = (json['title'] ?? json['Title'] ?? 'Công việc').toString();
    final description = (json['description'] ?? json['Description'] ?? '').toString();

    final rawPriority = json['priority'] ?? json['Priority'] ?? 2;
    final priority = rawPriority is int ? rawPriority : int.tryParse(rawPriority.toString()) ?? 2;
    final priorityName = (json['priorityName'] ?? json['PriorityName'] ?? 'Bình thường').toString();

    final rawStatus = json['status'] ?? json['Status'] ?? 1;
    final status = rawStatus is int ? rawStatus : int.tryParse(rawStatus.toString()) ?? 1;
    final statusName = (json['statusName'] ?? json['StatusName'] ?? 'Chờ phân công').toString();

    final rawAssignedTo = json['assignedToAccountId'] ?? json['AssignedToAccountId'];
    final assignedToAccountId = rawAssignedTo != null ? int.tryParse(rawAssignedTo.toString()) : null;

    final rawCreatedBy = json['createdByAccountId'] ?? json['CreatedByAccountId'] ?? 1;
    final createdByAccountId = rawCreatedBy is int ? rawCreatedBy : int.tryParse(rawCreatedBy.toString()) ?? 1;

    final dueAt = json['dueAt'] != null ? DateTime.tryParse(json['dueAt'].toString()) : null;
    final startedAt = json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null;
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();
    final completedAt = json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null;

    final rawCompletedBy = json['completedByAccountId'] ?? json['CompletedByAccountId'];
    final completedByAccountId = rawCompletedBy != null ? int.tryParse(rawCompletedBy.toString()) : null;

    final completionNotes = json['completionNotes']?.toString();
    final rowVersion = (json['rowVersion'] ?? json['RowVersion'] ?? '').toString();

    final roomNumber = (json['roomNumber'] ?? json['RoomNumber'] ?? 'P$roomId').toString();
    final floor = json['floor'] ?? json['Floor'] ?? 1;
    final roomTypeName = (json['roomTypeName'] ?? json['RoomTypeName'] ?? 'Tiêu chuẩn').toString();
    final assignedStaff = json['assignedStaff']?.toString() ?? json['assignedToName']?.toString();

    return HousekeepingTaskModel(
      id: id,
      taskCode: taskCode,
      roomId: roomId,
      roomNumber: roomNumber,
      floor: floor is int ? floor : int.tryParse(floor.toString()) ?? 1,
      roomTypeName: roomTypeName,
      taskType: taskType,
      taskTypeName: taskTypeName,
      housekeepingKind: housekeepingKind,
      title: title,
      description: description,
      priority: priority,
      priorityName: priorityName,
      status: status,
      statusName: statusName,
      assignedStaff: assignedStaff,
      assignedToAccountId: assignedToAccountId,
      createdByAccountId: createdByAccountId,
      dueAt: dueAt,
      startedAt: startedAt,
      createdAt: createdAt,
      completedAt: completedAt,
      completedByAccountId: completedByAccountId,
      completionNotes: completionNotes,
      rowVersion: rowVersion,
    );
  }

  HousekeepingTask toEntity() => HousekeepingTask(
        id: id,
        taskCode: taskCode,
        roomId: roomId,
        roomNumber: roomNumber,
        floor: floor,
        roomTypeName: roomTypeName,
        taskType: taskType,
        taskTypeName: taskTypeName,
        housekeepingKind: housekeepingKind,
        title: title,
        description: description,
        priority: priority,
        priorityName: priorityName,
        status: status,
        statusName: statusName,
        assignedStaff: assignedStaff,
        assignedToAccountId: assignedToAccountId,
        createdByAccountId: createdByAccountId,
        dueAt: dueAt,
        startedAt: startedAt,
        createdAt: createdAt,
        completedAt: completedAt,
        completedByAccountId: completedByAccountId,
        completionNotes: completionNotes,
        rowVersion: rowVersion,
      );
}
