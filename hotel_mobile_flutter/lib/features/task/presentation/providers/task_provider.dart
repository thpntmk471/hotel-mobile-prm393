import 'package:flutter/foundation.dart';
import '../../domain/entities/housekeeping_task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository taskRepository;

  TaskProvider({required this.taskRepository});

  List<HousekeepingTask> _tasks = [];
  HousekeepingTask? _selectedTask;
  bool _isLoading = false;
  String? _errorMessage;

  // Bộ lọc
  String _keyword = '';
  int? _selectedRoomId;
  int? _selectedTaskType;
  int? _selectedStatus;
  int? _selectedPriority;

  List<HousekeepingTask> get tasks => _tasks;
  HousekeepingTask? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get keyword => _keyword;
  int? get selectedRoomId => _selectedRoomId;
  int? get selectedTaskType => _selectedTaskType;
  int? get selectedStatus => _selectedStatus;
  int? get selectedPriority => _selectedPriority;

  Future<void> fetchTasks({int? assignedToAccountId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await taskRepository.getTasks(
        keyword: _keyword.isNotEmpty ? _keyword : null,
        roomId: _selectedRoomId,
        taskType: _selectedTaskType,
        status: _selectedStatus,
        priority: _selectedPriority,
        assignedToAccountId: assignedToAccountId,
      );
    } catch (e) {
      _errorMessage = 'Không thể nạp danh sách công việc: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setKeyword(String kw) {
    _keyword = kw;
  }

  void setRoomFilter(int? rId) {
    _selectedRoomId = rId;
  }

  void setTaskTypeFilter(int? type) {
    _selectedTaskType = type;
  }

  void setStatusFilter(int? status) {
    _selectedStatus = status;
  }

  void setPriorityFilter(int? priority) {
    _selectedPriority = priority;
  }

  void resetFilters() {
    _keyword = '';
    _selectedRoomId = null;
    _selectedTaskType = null;
    _selectedStatus = null;
    _selectedPriority = null;
    fetchTasks();
  }

  Future<HousekeepingTask?> getTaskDetails(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final task = await taskRepository.getTaskById(id);
      _selectedTask = task;
      return task;
    } catch (e) {
      _errorMessage = 'Lỗi nạp chi tiết công việc: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    try {
      final created = await taskRepository.createHousekeepingTask(
        roomId: roomId,
        housekeepingKind: housekeepingKind,
        title: title,
        description: description,
        priority: priority,
        dueAt: dueAt,
        assignedToAccountId: assignedToAccountId,
        createdByAccountId: createdByAccountId,
      );
      await fetchTasks();
      return created;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    }
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
    int pVal = 2;
    if (priority == 'Cao') pVal = 3;
    if (priority == 'Khẩn cấp') pVal = 4;
    if (priority == 'Thấp') pVal = 1;

    await createHousekeepingTask(
      roomId: roomId,
      housekeepingKind: 1,
      title: taskType,
      description: description ?? 'Dọn dẹp phòng sau khi khách trả phòng',
      priority: pVal,
      assignedToAccountId: assignedToAccountId,
      createdByAccountId: createdByAccountId ?? 1,
    );
  }

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
    try {
      final created = await taskRepository.createMaintenanceTask(
        roomId: roomId,
        title: title,
        description: description,
        priority: priority,
        dueAt: dueAt,
        assignedToAccountId: assignedToAccountId,
        blockStartAt: blockStartAt,
        blockEndAt: blockEndAt,
        createdByAccountId: createdByAccountId,
      );
      await fetchTasks();
      return created;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    }
  }

  Future<void> assignTask(int taskId, int staffAccountId, {String? rowVersion}) async {
    try {
      await taskRepository.assignTask(taskId, staffAccountId, rowVersion: rowVersion);
      await getTaskDetails(taskId);
      await fetchTasks();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    }
  }

  Future<void> startTask(int taskId, {String? rowVersion, String? notes}) async {
    try {
      await taskRepository.startTask(taskId, rowVersion: rowVersion, notes: notes);
      await getTaskDetails(taskId);
      await fetchTasks();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    }
  }

  Future<void> cancelTask(int taskId, {String? rowVersion, String? notes}) async {
    try {
      await taskRepository.cancelTask(taskId, rowVersion: rowVersion, notes: notes);
      await getTaskDetails(taskId);
      await fetchTasks();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    }
  }

  Future<void> completeTask(
    int taskId, {
    required int completedByAccountId,
    String? completionNotes,
    String? rowVersion,
  }) async {
    try {
      await taskRepository.completeTask(
        taskId,
        completedByAccountId: completedByAccountId,
        completionNotes: completionNotes,
        rowVersion: rowVersion,
      );
      await getTaskDetails(taskId);
      await fetchTasks();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    }
  }
}
