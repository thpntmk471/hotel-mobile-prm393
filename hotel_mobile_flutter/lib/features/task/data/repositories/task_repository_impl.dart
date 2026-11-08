import '../../domain/entities/housekeeping_task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<HousekeepingTask>> getTasks({String? status, int? floor}) async {
    final models = await remoteDataSource.fetchTasks();
    var list = models.map((m) => m.toEntity()).toList();

    if (status != null && status != 'Tất cả') {
      list = list.where((t) => t.status == status).toList();
    }
    if (floor != null && floor != 0) {
      list = list.where((t) => t.floor == floor).toList();
    }
    return list;
  }

  @override
  Future<void> acceptTask(int taskId, String staffName, {String? rowVersion, int? accountId}) async {
    await remoteDataSource.updateTaskStatus(
      taskId,
      'Đang dọn',
      staffName: staffName,
      rowVersion: rowVersion,
      accountId: accountId,
    );
  }

  @override
  Future<void> completeTask(int taskId, {String? staffName, String? rowVersion, int? accountId}) async {
    await remoteDataSource.updateTaskStatus(
      taskId,
      'Hoàn thành',
      staffName: staffName,
      rowVersion: rowVersion,
      accountId: accountId,
    );
  }

  @override
  Future<void> assignTask(int taskId, int staffAccountId, {String? rowVersion}) async {
    await remoteDataSource.assignTask(taskId, staffAccountId, rowVersion: rowVersion);
  }

  @override
  Future<HousekeepingTask> createCleaningTask({
    required int roomId,
    required String roomNumber,
    required int floor,
    required String roomTypeName,
    required String taskType,
    required String priority,
    String? description,
    int? assignedToAccountId,
    int? createdByAccountId,
  }) async {
    int priorityVal = 2;
    if (priority == 'Khẩn cấp') {
      priorityVal = 4;
    } else if (priority == 'Cao') {
      priorityVal = 3;
    } else if (priority == 'Thấp') {
      priorityVal = 1;
    }

    final payload = {
      'roomId': roomId,
      'roomNumber': roomNumber,
      'floor': floor,
      'roomTypeName': roomTypeName,
      'taskType': taskType,
      'priority': priorityVal,
      'description': description,
      'assignedToAccountId': assignedToAccountId,
      'createdByAccountId': createdByAccountId,
    };
    final model = await remoteDataSource.createTask(payload);
    return model.toEntity();
  }
}

