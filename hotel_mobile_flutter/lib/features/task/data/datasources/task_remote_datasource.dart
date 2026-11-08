import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/housekeeping_task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<HousekeepingTaskModel>> fetchTasks({
    String? keyword,
    int? roomId,
    int? taskType,
    int? status,
    int? priority,
    int? assignedToAccountId,
    int page = 1,
    int pageSize = 100,
  });

  Future<HousekeepingTaskModel> getTaskById(int id);

  Future<HousekeepingTaskModel> createHousekeepingTask(Map<String, dynamic> payload);

  Future<HousekeepingTaskModel> createMaintenanceTask(Map<String, dynamic> payload);

  Future<void> assignTask(int taskId, int staffAccountId, {String? rowVersion});

  Future<void> startTask(int taskId, {String? rowVersion, String? notes});

  Future<void> cancelTask(int taskId, {String? rowVersion, String? notes});

  Future<void> completeTask(
    int taskId, {
    required int completedByAccountId,
    String? completionNotes,
    String? rowVersion,
  });
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl(this.dio);

  Future<String> _ensureRowVersion(int taskId, String? rowVersion) async {
    if (rowVersion != null && rowVersion.trim().isNotEmpty) return rowVersion;
    try {
      final res = await dio.get('${ApiConstants.taskService}/$taskId');
      if (res.data is Map) {
        return (res.data['rowVersion'] ?? res.data['RowVersion'] ?? '').toString();
      }
    } catch (_) {}
    return '';
  }

  @override
  Future<List<HousekeepingTaskModel>> fetchTasks({
    String? keyword,
    int? roomId,
    int? taskType,
    int? status,
    int? priority,
    int? assignedToAccountId,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (keyword != null && keyword.trim().isNotEmpty) {
        queryParams['keyword'] = keyword.trim();
      }
      if (roomId != null && roomId > 0) {
        queryParams['roomId'] = roomId;
      }
      if (taskType != null && taskType > 0) {
        queryParams['taskType'] = taskType;
      }
      if (status != null && status > 0) {
        queryParams['status'] = status;
      }
      if (priority != null && priority > 0) {
        queryParams['priority'] = priority;
      }
      if (assignedToAccountId != null && assignedToAccountId > 0) {
        queryParams['assignedToAccountId'] = assignedToAccountId;
      }

      final res = await dio.get(
        ApiConstants.taskService,
        queryParameters: queryParams,
      );

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
  Future<HousekeepingTaskModel> getTaskById(int id) async {
    try {
      final res = await dio.get('${ApiConstants.taskService}/$id');
      return HousekeepingTaskModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] getTaskById error: $e');
      throw Exception('Không thể tải chi tiết công việc #$id: $e');
    }
  }

  @override
  Future<HousekeepingTaskModel> createHousekeepingTask(Map<String, dynamic> payload) async {
    try {
      // Backend: POST /api/hotel-tasks/housekeeping
      final res = await dio.post(
        '${ApiConstants.taskService}/housekeeping',
        data: {
          'roomId': payload['roomId'],
          'housekeepingKind': payload['housekeepingKind'] ?? 1, // 1 = Dọn phòng, 2 = Kiểm tra phòng
          'title': payload['title'],
          'description': payload['description'] ?? '',
          'priority': payload['priority'] ?? 2,
          'dueAt': payload['dueAt'],
          'assignedToAccountId': payload['assignedToAccountId'],
          'createdByAccountId': payload['createdByAccountId'] ?? 1,
        },
      );
      return HousekeepingTaskModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] createHousekeepingTask error: $e');
      throw Exception('Lỗi tạo việc dọn/kiểm tra phòng: $e');
    }
  }

  @override
  Future<HousekeepingTaskModel> createMaintenanceTask(Map<String, dynamic> payload) async {
    try {
      // Backend: POST /api/hotel-tasks/maintenance
      final res = await dio.post(
        '${ApiConstants.taskService}/maintenance',
        data: {
          'roomId': payload['roomId'],
          'title': payload['title'],
          'description': payload['description'] ?? '',
          'priority': payload['priority'] ?? 2,
          'dueAt': payload['dueAt'],
          'assignedToAccountId': payload['assignedToAccountId'],
          'blockStartAt': payload['blockStartAt'] ?? DateTime.now().toIso8601String(),
          'blockEndAt': payload['blockEndAt'],
          'createdByAccountId': payload['createdByAccountId'] ?? 1,
        },
      );
      return HousekeepingTaskModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] createMaintenanceTask error: $e');
      throw Exception('Lỗi tạo việc bảo trì: $e');
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
  Future<void> startTask(int taskId, {String? rowVersion, String? notes}) async {
    try {
      final rv = await _ensureRowVersion(taskId, rowVersion);
      // Backend: PUT /api/hotel-tasks/{id}/progress với status = 3 (Bắt đầu dọn)
      await dio.put(
        '${ApiConstants.taskService}/$taskId/progress',
        data: {
          'status': 3,
          'notes': notes ?? 'Nhân viên bắt đầu thực hiện công việc',
          'rowVersion': rv,
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] startTask error: $e');
      throw Exception('Lỗi bắt đầu công việc: $e');
    }
  }

  @override
  Future<void> cancelTask(int taskId, {String? rowVersion, String? notes}) async {
    try {
      final rv = await _ensureRowVersion(taskId, rowVersion);
      // Backend: PUT /api/hotel-tasks/{id}/progress với status = 5 (Hủy việc)
      await dio.put(
        '${ApiConstants.taskService}/$taskId/progress',
        data: {
          'status': 5,
          'notes': notes ?? 'Hủy công việc',
          'rowVersion': rv,
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] cancelTask error: $e');
      throw Exception('Lỗi hủy công việc: $e');
    }
  }

  @override
  Future<void> completeTask(
    int taskId, {
    required int completedByAccountId,
    String? completionNotes,
    String? rowVersion,
  }) async {
    try {
      final rv = await _ensureRowVersion(taskId, rowVersion);
      // Backend: POST /api/hotel-tasks/{id}/complete
      await dio.post(
        '${ApiConstants.taskService}/$taskId/complete',
        data: {
          'completionNotes': completionNotes ?? 'Hoàn thành công việc qua Mobile App',
          'completedByAccountId': completedByAccountId,
          'rowVersion': rv,
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ [TaskRemoteDataSource] completeTask error: $e');
      throw Exception('Lỗi hoàn thành công việc: $e');
    }
  }
}
