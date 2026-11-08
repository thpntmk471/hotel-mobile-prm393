import '../../domain/entities/housekeeping_task.dart';

class HousekeepingTaskModel {
  final int id;
  final String taskCode;
  final int roomId;
  final String roomNumber;
  final int floor;
  final String roomTypeName;
  final String taskType;
  final String priority;
  final String status;
  final String? assignedStaff;
  final DateTime createdAt;
  final DateTime? completedAt;

  HousekeepingTaskModel({
    required this.id,
    required this.taskCode,
    required this.roomId,
    required this.roomNumber,
    required this.floor,
    required this.roomTypeName,
    required this.taskType,
    required this.priority,
    required this.status,
    this.assignedStaff,
    required this.createdAt,
    this.completedAt,
  });

  factory HousekeepingTaskModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['Id'] ?? 1;
    final taskId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 1;
    final tCode = json['taskCode'] ?? json['TaskCode'] ?? 'DEV-TASK-$taskId';
    final rId = json['roomId'] ?? json['RoomId'] ?? 1;
    final rNumber = json['roomNumber'] ?? json['RoomNumber'] ?? 'DEV-$rId';
    final typeName = json['roomTypeName'] ?? json['RoomTypeName'] ?? 'Phòng Tiêu chuẩn';
    final tType = json['taskTypeName'] ?? json['title'] ?? json['Title'] ?? 'Dọn dẹp phòng';

    // Ánh xạ trạng thái byte của .NET TaskAPI
    // 1: Pending (Chờ nhận), 2: Assigned (Đã nhận), 3: InProgress (Đang dọn), 4: Completed (Hoàn thành), 5: Cancelled (Đã hủy)
    final rawStatus = json['status'] ?? json['Status'] ?? json['statusName'] ?? json['StatusName'];
    String statusStr = 'Chờ nhận';
    if (rawStatus is int || (rawStatus != null && int.tryParse(rawStatus.toString()) != null)) {
      final sInt = rawStatus is int ? rawStatus : int.parse(rawStatus.toString());
      if (sInt == 1) {
        statusStr = 'Chờ nhận';
      } else if (sInt == 2) {
        statusStr = 'Đã nhận';
      } else if (sInt == 3) {
        statusStr = 'Đang dọn';
      } else if (sInt == 4) {
        statusStr = 'Hoàn thành';
      } else if (sInt == 5) {
        statusStr = 'Đã hủy';
      }
    } else if (rawStatus != null) {
      final s = rawStatus.toString().toLowerCase();
      if (s.contains('progress') || s.contains('đang')) {
        statusStr = 'Đang dọn';
      } else if (s.contains('complet') || s.contains('hoàn')) {
        statusStr = 'Hoàn thành';
      } else if (s.contains('assign') || s.contains('nhận')) {
        statusStr = 'Đã nhận';
      } else {
        statusStr = 'Chờ nhận';
      }
    }

    final pName = json['priorityName'] ?? json['PriorityName'] ?? 'Trung bình';

    return HousekeepingTaskModel(
      id: taskId,
      taskCode: tCode.toString(),
      roomId: rId is int ? rId : int.tryParse(rId.toString()) ?? 1,
      roomNumber: rNumber.toString(),
      floor: json['floor'] ?? json['Floor'] ?? 2,
      roomTypeName: typeName.toString(),
      taskType: tType.toString(),
      priority: pName.toString(),
      status: statusStr,
      assignedStaff: json['assignedStaff']?.toString() ?? json['assignedToName']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
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
        priority: priority,
        status: status,
        assignedStaff: assignedStaff,
        createdAt: createdAt,
        completedAt: completedAt,
      );
}
