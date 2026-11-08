import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../../staff/presentation/providers/staff_provider.dart';
import '../../domain/entities/housekeeping_task.dart';
import '../providers/task_provider.dart';
import 'create_housekeeping_task_page.dart';
import 'create_maintenance_task_page.dart';
import 'task_detail_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _searchController = TextEditingController();
  bool _showFilterPanel = false;

  int? _filterRoomId;
  int? _filterTaskType; // 1: Housekeeping, 2: Maintenance
  int? _filterStatus; // 1: Chờ phân công, 2: Đã phân công, 3: Đang dọn, 4: Hoàn thành, 5: Đã hủy
  int? _filterPriority; // 1: Thấp, 2: Bình thường, 3: Cao, 4: Khẩn cấp

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    final isRoomStaff = (auth.session?.role.toLowerCase() ?? '').contains('room') ||
        (auth.session?.role.toLowerCase() ?? '').contains('house') ||
        (auth.session?.role.toLowerCase() ?? '').contains('buồng');

    // Nếu là Room Staff, TaskAPI tự giới hạn theo tài khoản hoặc có thể lọc theo ID
    context.read<TaskProvider>().fetchTasks(
      assignedToAccountId: isRoomStaff ? auth.currentUserId : null,
    );
    context.read<RoomProvider>().fetchRooms();
    context.read<StaffProvider>().fetchStaffList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final taskProvider = context.read<TaskProvider>();
    taskProvider.setKeyword(_searchController.text.trim());
    taskProvider.setRoomFilter(_filterRoomId);
    taskProvider.setTaskTypeFilter(_filterTaskType);
    taskProvider.setStatusFilter(_filterStatus);
    taskProvider.setPriorityFilter(_filterPriority);

    final auth = context.read<AuthProvider>();
    final isRoomStaff = (auth.session?.role.toLowerCase() ?? '').contains('room') ||
        (auth.session?.role.toLowerCase() ?? '').contains('house') ||
        (auth.session?.role.toLowerCase() ?? '').contains('buồng');

    taskProvider.fetchTasks(
      assignedToAccountId: isRoomStaff ? auth.currentUserId : null,
    );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _filterRoomId = null;
      _filterTaskType = null;
      _filterStatus = null;
      _filterPriority = null;
    });
    context.read<TaskProvider>().resetFilters();
    _loadData();
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.blue;
      case 2:
        return const Color(0xFF6B7280); // Normal
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return AppColors.statusBlueText;
      case 2:
        return const Color(0xFF2563EB); // Assigned
      case 3:
        return AppColors.statusWarningText; // InProgress
      case 4:
        return AppColors.statusActiveText; // Completed
      case 5:
        return AppColors.statusOccupiedText; // Cancelled
      default:
        return AppColors.textPrimary;
    }
  }

  Color _getStatusBgColor(int status) {
    switch (status) {
      case 1:
        return AppColors.statusBlueBg;
      case 2:
        return const Color(0xFFDBEAFE);
      case 3:
        return AppColors.statusWarningBg;
      case 4:
        return AppColors.statusActiveBg;
      case 5:
        return AppColors.statusOccupiedBg;
      default:
        return AppColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final auth = context.watch<AuthProvider>();
    final currentRole = auth.session?.role.toLowerCase() ?? '';
    final isRoomStaff = currentRole.contains('room') || currentRole.contains('house') || currentRole.contains('buồng');
    final isAdminOrReceptionist = currentRole.contains('admin') || currentRole.contains('reception') || currentRole.contains('tân');
    final rooms = context.watch<RoomProvider>().rooms;
    final allStaff = context.watch<StaffProvider>().staffList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý công việc'),
        actions: [
          IconButton(
            tooltip: 'Bộ lọc nâng cao',
            icon: Icon(
              _showFilterPanel ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilterPanel ? Colors.white : Colors.white70,
            ),
            onPressed: () {
              setState(() => _showFilterPanel = !_showFilterPanel);
            },
          ),
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header khối & Các nút tạo việc
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VẬN HÀNH / CÔNG VIỆC',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Quản lý công việc',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Text(
                      '${taskProvider.tasks.length} công việc',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Hàng nút tạo việc:
                // - Admin & Lễ tân: "+ Tạo việc dọn phòng" & "Tạo việc bảo trì"
                // - Room Staff: "Tạo việc bảo trì"
                Row(
                  children: [
                    if (isAdminOrReceptionist) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateHousekeepingTaskPage()),
                            ).then((_) => _loadData());
                          },
                          icon: const Icon(Icons.add, size: 17, color: Colors.white),
                          label: const Text('+ Tạo việc dọn phòng', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateMaintenanceTaskPage()),
                          ).then((_) => _loadData());
                        },
                        icon: const Icon(Icons.build_circle_outlined, size: 17, color: Colors.white),
                        label: const Text('Tạo việc bảo trì', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Thanh tìm kiếm nhanh & Bộ lọc
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context.read<TaskProvider>().setKeyword(val);
                    final isRoom = isRoomStaff;
                    context.read<TaskProvider>().fetchTasks(
                      assignedToAccountId: isRoom ? auth.currentUserId : null,
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm mã hoặc tiêu đề công việc...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),

                // Bảng lọc nâng cao (khi mở panel)
                if (_showFilterPanel) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tìm kiếm và bộ lọc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                initialValue: _filterRoomId,
                                isDense: true,
                                decoration: const InputDecoration(
                                  labelText: 'Mã phòng',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Tất cả phòng')),
                                  ...rooms.map((r) => DropdownMenuItem(value: r.id, child: Text('Phòng ${r.roomNumber}'))),
                                ],
                                onChanged: (val) => setState(() => _filterRoomId = val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                initialValue: _filterTaskType,
                                isDense: true,
                                decoration: const InputDecoration(
                                  labelText: 'Loại công việc',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Tất cả')),
                                  DropdownMenuItem(value: 1, child: Text('Dọn phòng')),
                                  DropdownMenuItem(value: 2, child: Text('Bảo trì')),
                                ],
                                onChanged: (val) => setState(() => _filterTaskType = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                initialValue: _filterStatus,
                                isDense: true,
                                decoration: const InputDecoration(
                                  labelText: 'Trạng thái',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Tất cả')),
                                  DropdownMenuItem(value: 1, child: Text('Chờ phân công')),
                                  DropdownMenuItem(value: 2, child: Text('Đã phân công')),
                                  DropdownMenuItem(value: 3, child: Text('Đang thực hiện')),
                                  DropdownMenuItem(value: 4, child: Text('Hoàn thành')),
                                  DropdownMenuItem(value: 5, child: Text('Đã hủy')),
                                ],
                                onChanged: (val) => setState(() => _filterStatus = val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                initialValue: _filterPriority,
                                isDense: true,
                                decoration: const InputDecoration(
                                  labelText: 'Mức ưu tiên',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Tất cả')),
                                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                                  DropdownMenuItem(value: 2, child: Text('Bình thường')),
                                  DropdownMenuItem(value: 3, child: Text('Cao')),
                                  DropdownMenuItem(value: 4, child: Text('Khẩn cấp')),
                                ],
                                onChanged: (val) => setState(() => _filterPriority = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _resetFilters,
                              child: const Text('Đặt lại', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: _applyFilters,
                              child: const Text('Áp dụng bộ lọc', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          // Danh sách công việc
          Expanded(
            child: Builder(
              builder: (context) {
                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (taskProvider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(taskProvider.errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
                        ],
                      ),
                    ),
                  );
                }
                if (taskProvider.tasks.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Không có công việc nào',
                    subtitle: 'Hiện tại chưa có công việc buồng phòng hay sự cố bảo trì nào phát sinh theo bộ lọc.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final t = taskProvider.tasks[index];
                      return _buildTaskCard(context, t, rooms, allStaff, auth);
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

  Widget _buildTaskCard(
    BuildContext context,
    HousekeepingTask task,
    List dynamicRooms,
    List dynamicStaff,
    AuthProvider auth,
  ) {
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);
    final statusBgColor = _getStatusBgColor(task.status);

    // Phân giải tên phòng
    String roomDisplay = 'P${task.roomId}';
    final matchingRoom = dynamicRooms.where((r) => r.id == task.roomId).firstOrNull;
    if (matchingRoom != null) {
      roomDisplay = 'Phòng ${matchingRoom.roomNumber}';
    } else if (task.roomNumber.isNotEmpty) {
      roomDisplay = 'Phòng ${task.roomNumber}';
    }

    // Phân giải nhân viên
    String staffDisplay = 'Chưa phân công';
    if (task.assignedStaff != null && task.assignedStaff!.isNotEmpty) {
      staffDisplay = task.assignedStaff!;
    } else if (task.assignedToAccountId != null) {
      final s = dynamicStaff.where((e) => e.id == task.assignedToAccountId).firstOrNull;
      staffDisplay = s != null ? '${s.fullName} (#${s.id})' : '#${task.assignedToAccountId}';
    }

    final isAssignedToMe = task.assignedToAccountId == auth.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailPage(taskId: task.id, initialTask: task),
            ),
          ).then((_) => _loadData());
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng 1: Mã công việc & Phòng & Trạng thái Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          task.taskCode,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            roomDisplay,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.displayStatusName,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Hàng 2: Tiêu đề công việc & Loại
              Text(
                task.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${task.taskTypeName} • ${task.displayKindName}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),

              const Divider(height: 1),
              const SizedBox(height: 10),

              // Hàng 3: Mức ưu tiên, Nhân viên, Thao tác nút Chi tiết
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.displayPriorityName,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: priorityColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            staffDisplay,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Nút thao tác nhanh hoặc xem Chi tiết
                  Row(
                    children: [
                      if (isAssignedToMe && (task.isAssigned || task.isPending)) ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () async {
                            try {
                              await context.read<TaskProvider>().startTask(task.id, rowVersion: task.rowVersion);
                              _loadData();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          },
                          child: const Text('Bắt đầu', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                        const SizedBox(width: 6),
                      ] else if (isAssignedToMe && task.isInProgress) ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusActiveText,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailPage(taskId: task.id, initialTask: task),
                              ),
                            ).then((_) => _loadData());
                          },
                          child: const Text('Hoàn tất dọn', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      const Text(
                        'Chi tiết →',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
