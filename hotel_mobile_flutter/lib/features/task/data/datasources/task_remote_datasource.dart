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
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] fetchTasks error: $e');
      throw Exception('Không thể tải danh sách nhiệm vụ từ máy chủ: $e');
    }
  }

  @override
  Future<void> updateTaskStatus(int taskId, String status, {String? staffName}) async {
    try {
      if (status == 'Đang dọn' || status == 'InProgress') {
        // Backend: PUT /api/hotel-tasks/{id}/progress với status = 3 (Bắt đầu dọn)
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
      print('❌ [TaskRemoteDataSource] updateTaskStatus error: $e');
      throw Exception('Lỗi cập nhật tiến độ công việc: $e');
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
          'createdByAccountId': payload['createdByAccountId'] ?? 2,
        },
      );
      return HousekeepingTaskModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] createTask error: $e');
      throw Exception('Lỗi tạo nhiệm vụ buồng phòng trên hệ thống: $e');
    }
  }
}
