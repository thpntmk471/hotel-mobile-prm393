import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/housekeeping_task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<HousekeepingTaskModel>> fetchTasks();
  Future<void> updateTaskStatus(int taskId, String status, {String? staffName});
  Future<HousekeepingTaskModel> createTask(Map<String, dynamic> payload);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl(this.dio);

  final List<HousekeepingTaskModel> _mockTasks = [
    HousekeepingTaskModel(
      id: 1,
      taskCode: 'TSK-201',
      roomId: 3,
      roomNumber: 'DEV-201',
      floor: 2,
      roomTypeName: 'Phòng Deluxe',
      taskType: 'Dọn phòng sau check-out',
      priority: 'Cao',
      status: 'Chờ nhận',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    HousekeepingTaskModel(
      id: 2,
      taskCode: 'TSK-102',
      roomId: 2,
      roomNumber: 'DEV-102',
      floor: 1,
      roomTypeName: 'Phòng Standard',
      taskType: 'Bổ sung khăn & Minibar',
      priority: 'Trung bình',
      status: 'Đang dọn',
      assignedStaff: 'Buồng phòng Demo',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    HousekeepingTaskModel(
      id: 3,
      taskCode: 'TSK-301',
      roomId: 5,
      roomNumber: 'DEV-301',
      floor: 3,
      roomTypeName: 'Phòng VIP Suite',
      taskType: 'Tổng vệ sinh định kỳ',
      priority: 'Thấp',
      status: 'Hoàn thành',
      assignedStaff: 'Buồng phòng Demo',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Future<List<HousekeepingTaskModel>> fetchTasks() async {
    try {
      final res = await dio.get(ApiConstants.taskService);
      if (res.data is List) {
        return (res.data as List).map((e) => HousekeepingTaskModel.fromJson(e)).toList();
      }
      return _mockTasks;
    } catch (_) {
      return _mockTasks;
    }
  }

  @override
  Future<void> updateTaskStatus(int taskId, String status, {String? staffName}) async {
    try {
      await dio.put('${ApiConstants.taskService}/$taskId/status', data: {
        'status': status,
        'assignedStaff': staffName,
      });
    } catch (_) {
      final idx = _mockTasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        final cur = _mockTasks[idx];
        _mockTasks[idx] = HousekeepingTaskModel(
          id: cur.id,
          taskCode: cur.taskCode,
          roomId: cur.roomId,
          roomNumber: cur.roomNumber,
          floor: cur.floor,
          roomTypeName: cur.roomTypeName,
          taskType: cur.taskType,
          priority: cur.priority,
          status: status,
          assignedStaff: staffName ?? cur.assignedStaff,
          createdAt: cur.createdAt,
          completedAt: status == 'Hoàn thành' ? DateTime.now() : cur.completedAt,
        );
      }
    }
  }

  @override
  Future<HousekeepingTaskModel> createTask(Map<String, dynamic> payload) async {
    try {
      final res = await dio.post(ApiConstants.taskService, data: payload);
      final model = HousekeepingTaskModel.fromJson(res.data as Map<String, dynamic>);
      _mockTasks.insert(0, model);
      return model;
    } catch (_) {
      final model = HousekeepingTaskModel(
        id: _mockTasks.length + 1,
        taskCode: 'TSK-${payload['roomNumber']}',
        roomId: payload['roomId'] ?? 1,
        roomNumber: payload['roomNumber'] ?? 'DEV-101',
        floor: payload['floor'] ?? 1,
        roomTypeName: payload['roomTypeName'] ?? 'Phòng Standard',
        taskType: payload['taskType'] ?? 'Dọn phòng',
        priority: payload['priority'] ?? 'Trung bình',
        status: 'Chờ nhận',
        createdAt: DateTime.now(),
      );
      _mockTasks.insert(0, model);
      return model;
    }
  }
}
