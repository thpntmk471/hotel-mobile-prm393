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

  Future<void> acceptTask(int taskId, String staffName) async {
    await taskRepository.acceptTask(taskId, staffName);
    await fetchTasks();
  }

  Future<void> completeTask(int taskId) async {
    await taskRepository.completeTask(taskId);
    await fetchTasks();
  }
}
