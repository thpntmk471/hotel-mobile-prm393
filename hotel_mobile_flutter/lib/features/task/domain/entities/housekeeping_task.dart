class HousekeepingTask {
  final int id;
  final String taskCode; // TSK-101
  final int roomId;
  final String roomNumber;
  final int floor;
  final String roomTypeName;
  final String taskType; // Dọn phòng sau check-out, Dọn định kỳ, Bổ sung đồ dùng, Bảo trì
  final String priority; // Cao, Trung bình, Thấp
  final String status; // Chờ nhận, Đang dọn, Hoàn thành
  final String? assignedStaff;
  final DateTime createdAt;
  final DateTime? completedAt;

  const HousekeepingTask({
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

  bool get isPending => status == 'Chờ nhận';
  bool get isInProgress => status == 'Đang dọn';
  bool get isDone => status == 'Hoàn thành';
}
