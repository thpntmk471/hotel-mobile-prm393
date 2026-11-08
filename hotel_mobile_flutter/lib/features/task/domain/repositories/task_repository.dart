import '../entities/housekeeping_task.dart';

abstract class TaskRepository {
  Future<List<HousekeepingTask>> getTasks({
    String? keyword,
    int? roomId,
    int? taskType,
    int? status,
    int? priority,
    int? assignedToAccountId,
    int page = 1,
    int pageSize = 100,
  });

  Future<HousekeepingTask> getTaskById(int id);

  Future<HousekeepingTask> createHousekeepingTask({
    required int roomId,
    required int housekeepingKind,
    required String title,
    String? description,
    int priority = 2,
    DateTime? dueAt,
    int? assignedToAccountId,
    required int createdByAccountId,
  });

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
  });

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
