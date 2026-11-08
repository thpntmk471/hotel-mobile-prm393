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
      taskCode: 'DEV-TASK-001',
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
      taskCode: 'DEV-TASK-002',
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
      taskCode: 'DEV-TASK-003',
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
      dynamic data = res.data;
      if (data is Map && (data.containsKey('items') || data.containsKey('Items'))) {
        data = data['items'] ?? data['Items'];
      }
      if (data is List) {
        return data
            .map((e) => HousekeepingTaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return _mockTasks;
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [TaskRemoteDataSource] fetchTasks error: $e');
      return _mockTasks;
    }
  }

  @override
  Future<void> updateTaskStatus(int taskId, String status, {String? staffName}) async {
    try {
      if (status == 'Đang dọn' || status == 'InProgress') {
        // Backend: PUT /api/hotel-tasks/{id}/progress với status = 3
        await dio.put(
          '${ApiConstants.taskService}/$taskId/progress',
          data: {'status': 3},
        );
      } else if (status == 'Hoàn thành' || status == 'Completed') {
        // Backend: POST /api/hotel-tasks/{id}/complete
        await dio.post(
          '${ApiConstants.taskService}/$taskId/complete',
          data: {
            'completionNotes': 'Hoàn thành dọn phòng qua Mobile App bởi ${staffName ?? "Nhân viên"}',
          },
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [TaskRemoteDataSource] updateTaskStatus error: $e');
    }

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

  @override
  Future<HousekeepingTaskModel> createTask(Map<String, dynamic> payload) async {
    try {
      // Backend: POST /api/hotel-tasks/housekeeping
      final res = await dio.post(
        '${ApiConstants.taskService}/housekeeping',
        data: {
          'roomId': payload['roomId'] ?? 1,
          'housekeepingKind': 1, // 1: Dọn phòng
          'title': payload['taskType'] ?? 'Dọn phòng sau check-out',
          'description': 'Nhiệm vụ dọn dẹp vệ sinh phòng ${payload['roomNumber']} tạo từ Mobile App',
          'priority': 2, // 2: Trung bình
          'createdByAccountId': 2,
        },
      );
      final model = HousekeepingTaskModel.fromJson(res.data as Map<String, dynamic>);
      _mockTasks.insert(0, model);
      return model;
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [TaskRemoteDataSource] createTask error: $e');
      final model = HousekeepingTaskModel(
        id: _mockTasks.length + 1,
        taskCode: 'DEV-TASK-00${_mockTasks.length + 1}',
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
