import 'package:flutter/foundation.dart';
import '../../domain/entities/housekeeping_task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository taskRepository;

  TaskProvider({required this.taskRepository});

  List<HousekeepingTask> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedStatus = 'Tất cả';

  List<HousekeepingTask> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await taskRepository.getTasks(status: _selectedStatus);
    } catch (e) {
      _errorMessage = 'Không thể nạp danh sách công việc: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    fetchTasks();
  }

  Future<void> acceptTask(int taskId, String staffName, {String? rowVersion, int? accountId}) async {
    await taskRepository.acceptTask(taskId, staffName, rowVersion: rowVersion, accountId: accountId);
    await fetchTasks();
  }

  Future<void> completeTask(int taskId, {String? staffName, String? rowVersion, int? accountId}) async {
    await taskRepository.completeTask(taskId, staffName: staffName, rowVersion: rowVersion, accountId: accountId);
    await fetchTasks();
  }

  Future<void> assignTask(int taskId, int staffAccountId, {String? rowVersion}) async {
    await taskRepository.assignTask(taskId, staffAccountId, rowVersion: rowVersion);
    await fetchTasks();
  }

  Future<void> createCleaningTask({
    required int roomId,
    required String roomNumber,
    required int floor,
    required String roomTypeName,
    String taskType = 'Dọn phòng sau check-out',
    String priority = 'Cao',
    String? description,
    int? assignedToAccountId,
    int? createdByAccountId,
  }) async {
    try {
      await taskRepository.createCleaningTask(
        roomId: roomId,
        roomNumber: roomNumber,
        floor: floor,
        roomTypeName: roomTypeName,
        taskType: taskType,
        priority: priority,
        description: description,
        assignedToAccountId: assignedToAccountId,
        createdByAccountId: createdByAccountId,
      );
      await fetchTasks();
    } catch (_) {
      rethrow;
    }
  }
}

