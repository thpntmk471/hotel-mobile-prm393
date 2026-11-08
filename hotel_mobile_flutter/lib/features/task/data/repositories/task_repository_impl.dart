import '../../domain/entities/housekeeping_task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<HousekeepingTask>> getTasks({
    String? keyword,
    int? roomId,
    int? taskType,
    int? status,
    int? priority,
    int? assignedToAccountId,
    int page = 1,
    int pageSize = 100,
  }) async {
    final models = await remoteDataSource.fetchTasks(
      keyword: keyword,
      roomId: roomId,
      taskType: taskType,
      status: status,
      priority: priority,
      assignedToAccountId: assignedToAccountId,
      page: page,
      pageSize: pageSize,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<HousekeepingTask> getTaskById(int id) async {
    final model = await remoteDataSource.getTaskById(id);
    return model.toEntity();
  }

  @override
  Future<HousekeepingTask> createHousekeepingTask({
    required int roomId,
    required int housekeepingKind,
    required String title,
    String? description,
    int priority = 2,
    DateTime? dueAt,
    int? assignedToAccountId,
    required int createdByAccountId,
  }) async {
    final payload = {
      'roomId': roomId,
      'housekeepingKind': housekeepingKind,
      'title': title,
      'description': description,
      'priority': priority,
      'dueAt': dueAt?.toIso8601String(),
      'assignedToAccountId': assignedToAccountId,
      'createdByAccountId': createdByAccountId,
    };
    final model = await remoteDataSource.createHousekeepingTask(payload);
    return model.toEntity();
  }

  @override
  Future<HousekeepingTask> createMaintenanceTask({
    required int roomId,
    required String title,
    String? description,
    int priority = 2,
    DateTime? dueAt,
    int? assignedToAccountId,
    DateTime? blockStartAt,
    DateTime? blockEndAt,
    required int createdByAccountId,
  }) async {
    final payload = {
      'roomId': roomId,
      'title': title,
      'description': description,
      'priority': priority,
      'dueAt': dueAt?.toIso8601String(),
      'assignedToAccountId': assignedToAccountId,
      'blockStartAt': (blockStartAt ?? DateTime.now()).toIso8601String(),
      'blockEndAt': blockEndAt?.toIso8601String(),
      'createdByAccountId': createdByAccountId,
    };
    final model = await remoteDataSource.createMaintenanceTask(payload);
    return model.toEntity();
  }

  @override
  Future<void> assignTask(int taskId, int staffAccountId, {String? rowVersion}) async {
    await remoteDataSource.assignTask(taskId, staffAccountId, rowVersion: rowVersion);
  }

  @override
  Future<void> startTask(int taskId, {String? rowVersion, String? notes}) async {
    await remoteDataSource.startTask(taskId, rowVersion: rowVersion, notes: notes);
  }

  @override
  Future<void> cancelTask(int taskId, {String? rowVersion, String? notes}) async {
    await remoteDataSource.cancelTask(taskId, rowVersion: rowVersion, notes: notes);
  }

  @override
  Future<void> completeTask(
    int taskId, {
    required int completedByAccountId,
    String? completionNotes,
    String? rowVersion,
  }) async {
    await remoteDataSource.completeTask(
      taskId,
      completedByAccountId: completedByAccountId,
      completionNotes: completionNotes,
      rowVersion: rowVersion,
    );
  }
}
