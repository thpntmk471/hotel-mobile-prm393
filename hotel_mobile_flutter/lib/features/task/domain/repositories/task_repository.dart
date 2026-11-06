import '../entities/housekeeping_task.dart';

abstract class TaskRepository {
  Future<List<HousekeepingTask>> getTasks({String? status, int? floor});
  Future<void> acceptTask(int taskId, String staffName);
  Future<void> completeTask(int taskId);
  Future<HousekeepingTask> createCleaningTask({
    required int roomId,
    required String roomNumber,
    required int floor,
    required String roomTypeName,
    required String taskType,
    required String priority,
  });
}
