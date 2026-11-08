import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../domain/entities/housekeeping_task.dart';
import '../providers/task_provider.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final List<String> _statuses = ['Tất cả', 'Chờ nhận', 'Đang dọn', 'Hoàn thành'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
      context.read<RoomProvider>().fetchRooms();
    });
  }

  void _showCreateTaskDialog(BuildContext context) {
    final roomProvider = context.read<RoomProvider>();
    final rooms = roomProvider.rooms;

    int? selectedRoomId = rooms.isNotEmpty ? rooms.first.id : null;
    String selectedTaskType = 'Dọn phòng sau check-out';
    String selectedPriority = 'Cao';
    final descCtrl = TextEditingController();

    final taskTypes = [
      'Dọn phòng sau check-out',
      'Dọn phòng định kỳ',
      'Kiểm tra phòng',
      'Bảo trì / Sửa chữa thiết bị',
    ];

    final priorities = ['Bình thường', 'Cao', 'Khẩn cấp', 'Thấp'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cleaning_services, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Giao việc buồng phòng', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chọn phòng cần xử lý *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  initialValue: selectedRoomId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  hint: const Text('Chọn phòng...'),
                  items: rooms.map((r) {
                    return DropdownMenuItem<int>(
                      value: r.id,
                      child: Text('Phòng ${r.roomNumber} (${r.roomTypeName})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedRoomId = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                const Text('Loại công việc *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedTaskType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: taskTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedTaskType = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                const Text('Mức độ ưu tiên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedPriority = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                const Text('Ghi chú chi tiết', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nhập ghi chú hoặc yêu cầu đặc biệt...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (selectedRoomId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn phòng'), backgroundColor: AppColors.error),
                  );
                  return;
                }
                final chosenRoom = rooms.firstWhere((r) => r.id == selectedRoomId);
                Navigator.pop(ctx);
                try {
                  final auth = context.read<AuthProvider>();
                  await context.read<TaskProvider>().createCleaningTask(
                    roomId: chosenRoom.id,
                    roomNumber: chosenRoom.roomNumber,
                    floor: chosenRoom.floor,
                    roomTypeName: chosenRoom.roomTypeName,
                    taskType: selectedTaskType,
                    priority: selectedPriority,
                    description: descCtrl.text.trim(),
                    createdByAccountId: auth.currentUserId,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã tạo nhiệm vụ "$selectedTaskType" cho phòng ${chosenRoom.roomNumber}!'),
                        backgroundColor: AppColors.statusActiveText,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi tạo nhiệm vụ: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Tạo việc', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final auth = context.watch<AuthProvider>();
    final currentStaff = auth.session?.fullName ?? 'Buồng phòng Demo';
    final currentAccountId = auth.currentUserId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Buồng phòng & Tác vụ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TaskProvider>().fetchTasks(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('Tạo nhiệm vụ', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showCreateTaskDialog(context),
      ),
      body: Column(
        children: [
          // Lọc trạng thái công việc
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statuses.map((st) {
                  final isSelected = taskProvider.selectedStatus == st;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(st),
                      selected: isSelected,
                      onSelected: (_) => context.read<TaskProvider>().setStatusFilter(st),
                      selectedColor: AppColors.primaryLight,
                      backgroundColor: AppColors.background,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách công việc buồng phòng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Có ${taskProvider.tasks.length} việc', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (taskProvider.errorMessage != null) {
                  return Center(child: Text(taskProvider.errorMessage!));
                }
                if (taskProvider.tasks.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Không có nhiệm vụ nào cần xử lý',
                    subtitle:
                        'Hiện tại tất cả các phòng đã được dọn sạch sẽ hoặc chưa có phòng nào phát sinh yêu cầu dọn.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<TaskProvider>().fetchTasks(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final t = taskProvider.tasks[index];
                      return _buildTaskCard(context, t, currentStaff, currentAccountId);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, HousekeepingTask task, String currentStaff, int currentAccountId) {
    Color priorityColor = Colors.orange;
    if (task.priority == 'Cao' || task.priority == 'Khẩn cấp') priorityColor = Colors.red;
    if (task.priority == 'Thấp') priorityColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Phòng ${task.roomNumber} (Tầng ${task.floor})',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ưu tiên: ${task.priority}',
                  style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(task.taskType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text('Loại phòng: ${task.roomTypeName}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (task.assignedStaff != null && task.assignedStaff!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Người thực hiện: ${task.assignedStaff}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: task.isDone
                      ? AppColors.statusActiveBg
                      : task.isInProgress
                          ? AppColors.statusWarningBg
                          : AppColors.statusBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: task.isDone
                        ? AppColors.statusActiveText
                        : task.isInProgress
                            ? AppColors.statusWarningText
                            : AppColors.statusBlueText,
                  ),
                ),
              ),
              if (task.isPending) ...[
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<TaskProvider>().acceptTask(
                            task.id,
                            currentStaff,
                            rowVersion: task.rowVersion,
                            accountId: currentAccountId,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã nhận dọn phòng ${task.roomNumber}'),
                            backgroundColor: AppColors.statusActiveText,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi nhận việc: $e'),
                            backgroundColor: AppColors.statusOccupiedText,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Nhận việc', style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ] else if (task.isInProgress) ...[
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<TaskProvider>().completeTask(
                            task.id,
                            staffName: currentStaff,
                            rowVersion: task.rowVersion,
                            accountId: currentAccountId,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã hoàn tất dọn phòng ${task.roomNumber}!'),
                            backgroundColor: AppColors.statusActiveText,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi hoàn tất việc: $e'),
                            backgroundColor: AppColors.statusOccupiedText,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusActiveText,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Hoàn tất dọn', style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
