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
    return HousekeepingTaskModel(
      id: json['id'] ?? 1,
      taskCode: json['taskCode'] ?? 'TSK-${json['id'] ?? 101}',
      roomId: json['roomId'] ?? 1,
      roomNumber: json['roomNumber'] ?? 'DEV-201',
      floor: json['floor'] ?? 2,
      roomTypeName: json['roomTypeName'] ?? 'Phòng Deluxe',
      taskType: json['taskType'] ?? 'Dọn phòng sau check-out',
      priority: json['priority'] ?? 'Cao',
      status: json['status'] ?? 'Chờ nhận',
      assignedStaff: json['assignedStaff'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
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

