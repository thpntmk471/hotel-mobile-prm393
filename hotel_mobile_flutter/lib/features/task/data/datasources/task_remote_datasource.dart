import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/housekeeping_task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<HousekeepingTaskModel>> fetchTasks();
  Future<void> updateTaskStatus(
    int taskId,
    String status, {
    String? staffName,
    String? rowVersion,
    int? accountId,
  });
  Future<void> assignTask(int taskId, int staffAccountId, {String? rowVersion});
  Future<HousekeepingTaskModel> createTask(Map<String, dynamic> payload);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl(this.dio);

  Future<String> _ensureRowVersion(int taskId, String? rowVersion) async {
    if (rowVersion != null && rowVersion.isNotEmpty) return rowVersion;
    try {
      final res = await dio.get('${ApiConstants.taskService}/$taskId');
      if (res.data is Map) {
        return (res.data['rowVersion'] ?? res.data['RowVersion'] ?? '').toString();
      }
    } catch (_) {}
    return '';
  }

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
  Future<void> updateTaskStatus(
    int taskId,
    String status, {
    String? staffName,
    String? rowVersion,
    int? accountId,
  }) async {
    try {
      final rv = await _ensureRowVersion(taskId, rowVersion);

      if (status == 'Đang dọn' || status == 'InProgress') {
        // Backend: PUT /api/hotel-tasks/{id}/progress với status = 3 (Bắt đầu dọn)
        await dio.put(
          '${ApiConstants.taskService}/$taskId/progress',
          data: {
            'status': 3,
            'notes': 'Nhân viên bắt đầu dọn phòng qua Mobile App',
            'rowVersion': rv,
          },
        );
      } else if (status == 'Hoàn thành' || status == 'Completed') {
        // Backend: POST /api/hotel-tasks/{id}/complete
        await dio.post(
          '${ApiConstants.taskService}/$taskId/complete',
          data: {
            'completionNotes': 'Hoàn thành dọn phòng qua Mobile App bởi ${staffName ?? "Nhân viên"}',
            'completedByAccountId': accountId ?? 1,
            'rowVersion': rv,
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
  Future<void> assignTask(int taskId, int staffAccountId, {String? rowVersion}) async {
    try {
      final rv = await _ensureRowVersion(taskId, rowVersion);
      await dio.put(
        '${ApiConstants.taskService}/$taskId/assign',
        data: {
          'assignedToAccountId': staffAccountId,
          'rowVersion': rv,
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] assignTask error: $e');
      throw Exception('Lỗi phân công nhân viên: $e');
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
          'housekeepingKind': payload['housekeepingKind'] ?? 1, // 1: Dọn phòng, 2: Kiểm tra
          'title': payload['taskType'] ?? payload['title'] ?? 'Dọn phòng',
          'description': payload['description'] ?? 'Nhiệm vụ dọn dẹp vệ sinh phòng ${payload['roomNumber'] ?? ""} tạo từ Mobile App',
          'priority': payload['priority'] is int ? payload['priority'] : 2, // 1: Thấp, 2: Trung bình, 3: Cao, 4: Khẩn cấp
          'assignedToAccountId': payload['assignedToAccountId'],
          'createdByAccountId': payload['createdByAccountId'] ?? 1,
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
