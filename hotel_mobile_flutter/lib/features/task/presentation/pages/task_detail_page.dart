import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../../staff/presentation/providers/staff_provider.dart';
import '../../domain/entities/housekeeping_task.dart';
import '../providers/task_provider.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;
  final HousekeepingTask? initialTask;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    this.initialTask,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  HousekeepingTask? _task;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _task = widget.initialTask;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
      context.read<RoomProvider>().fetchRooms();
      context.read<StaffProvider>().fetchStaffList();
    });
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    final task = await context.read<TaskProvider>().getTaskDetails(widget.taskId);
    if (mounted) {
      setState(() {
        if (task != null) _task = task;
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Chưa có thông tin';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
      case 1: // Pending
        return AppColors.statusBlueText;
      case 2: // Assigned
        return const Color(0xFF2563EB);
      case 3: // InProgress
        return AppColors.statusWarningText;
      case 4: // Completed
        return AppColors.statusActiveText;
      case 5: // Cancelled
        return AppColors.statusOccupiedText;
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

  // Thao tác: Bắt đầu thực hiện (chuyển sang InProgress)
  Future<void> _startTask(HousekeepingTask task) async {
    try {
      await context.read<TaskProvider>().startTask(task.id, rowVersion: task.rowVersion);
      await _loadDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã bắt đầu công việc. Trạng thái chuyển sang Đang thực hiện (InProgress)!'),
            backgroundColor: AppColors.statusActiveText,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi bắt đầu việc: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // Thao tác: Hoàn thành công việc (chuyển sang Completed & cập nhật phòng sạch)
  Future<void> _completeTask(HousekeepingTask task, int accountId) async {
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.statusActiveText),
            SizedBox(width: 8),
            Text('Xác nhận hoàn thành việc', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn đã hoàn tất dọn dẹp/kiểm tra cho công việc ${task.taskCode}?'),
            const SizedBox(height: 12),
            const Text('Ghi chú hoàn thành (tùy chọn):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú hoặc kết quả dọn...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusActiveText),
            onPressed: () async {
              final roomProv = context.read<RoomProvider>();
              final taskProv = context.read<TaskProvider>();
              Navigator.pop(ctx);
              try {
                // 1. Hoàn thành task trong TaskAPI
                await taskProv.completeTask(
                  task.id,
                  completedByAccountId: accountId,
                  completionNotes: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : 'Hoàn tất dọn phòng',
                  rowVersion: task.rowVersion,
                );

                // 2. Chuyển trạng thái phòng về Sạch sẵn sàng đón khách
                try {
                  await roomProv.setHousekeepingStatus(task.roomId, 'Sạch');
                  await roomProv.fetchRooms();
                } catch (_) {}

                await _loadDetails();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã hoàn thành công việc! Phòng chuyển về trạng thái Sạch sẵn sàng cho đặt phòng!'),
                      backgroundColor: AppColors.statusActiveText,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi hoàn thành việc: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Xác nhận hoàn thành', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Thao tác: Phân công nhân viên (Chỉ Room Staff - role 3)
  Future<void> _showAssignDialog(HousekeepingTask task) async {
    final staffList = context.read<StaffProvider>().staffList;
    final roomStaff = staffList.where((s) => s.role == 3 && s.isActive).toList();

    int? chosenStaffId = task.assignedToAccountId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add_alt_1, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Phân công công việc', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phân công cho công việc ${task.taskCode}:'),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Chọn nhân viên:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Chỉ Room Staff (vai trò 3)', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: chosenStaffId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                hint: const Text('-- Chọn nhân viên phòng --'),
                items: roomStaff.map((s) {
                  return DropdownMenuItem<int>(
                    value: s.id,
                    child: Text('${s.fullName} (${s.username}) - #${s.id}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => chosenStaffId = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (chosenStaffId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn nhân viên!'), backgroundColor: AppColors.error),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await context.read<TaskProvider>().assignTask(
                    task.id,
                    chosenStaffId!,
                    rowVersion: task.rowVersion,
                  );
                  await _loadDetails();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã phân công nhân viên và chuyển trạng thái sang Đã phân công (Assigned)!'),
                        backgroundColor: AppColors.statusActiveText,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi phân công: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Lưu phân công', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Thao tác: Hủy công việc
  Future<void> _showCancelDialog(HousekeepingTask task) async {
    final noteCtrl = TextEditingController(text: 'Khách không cần dọn / Hủy tác vụ');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy công việc'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc muốn hủy công việc ${task.taskCode}?'),
            const SizedBox(height: 12),
            const Text('Lý do hủy:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Quay lại')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusOccupiedText),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<TaskProvider>().cancelTask(
                  task.id,
                  notes: noteCtrl.text.trim(),
                  rowVersion: task.rowVersion,
                );
                await _loadDetails();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã hủy công việc thành công!'),
                      backgroundColor: AppColors.statusOccupiedText,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi hủy việc: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Hủy việc', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentUserId;
    final currentRole = auth.session?.role.toLowerCase() ?? '';
    final isRoomStaff = currentRole.contains('room') || currentRole.contains('house') || currentRole.contains('buồng');
    final isAdminOrReceptionist = currentRole.contains('admin') || currentRole.contains('reception') || currentRole.contains('tân');

    final rooms = context.watch<RoomProvider>().rooms;
    final allStaff = context.watch<StaffProvider>().staffList;

    final task = _task;

    if (_isLoading && task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết công việc')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết công việc')),
        body: const Center(child: Text('Không tìm thấy thông tin công việc.')),
      );
    }

    // Phân giải tên phòng
    String roomCode = 'P${task.roomId}';
    final matchingRoom = rooms.where((r) => r.id == task.roomId).firstOrNull;
    if (matchingRoom != null) {
      roomCode = 'Phòng ${matchingRoom.roomNumber}';
    } else if (task.roomNumber.isNotEmpty) {
      roomCode = 'Phòng ${task.roomNumber}';
    }

    // Phân giải tên nhân viên được giao
    String assignedPerson = 'Chưa phân công';
    if (task.assignedStaff != null && task.assignedStaff!.isNotEmpty) {
      assignedPerson = task.assignedStaff!;
    } else if (task.assignedToAccountId != null) {
      final matchingStaff = allStaff.where((s) => s.id == task.assignedToAccountId).firstOrNull;
      if (matchingStaff != null) {
        assignedPerson = '${matchingStaff.fullName} (#${matchingStaff.id})';
      } else {
        assignedPerson = 'Tài khoản #${task.assignedToAccountId}';
      }
    }

    // Phân giải người tạo
    String createdByPerson = 'Tài khoản #${task.createdByAccountId}';
    final matchingCreator = allStaff.where((s) => s.id == task.createdByAccountId).firstOrNull;
    if (matchingCreator != null) {
      createdByPerson = '${matchingCreator.fullName} (${matchingCreator.username})';
    }

    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);
    final statusBgColor = _getStatusBgColor(task.status);

    // Kiểm tra quyền thao tác của nhân viên phòng
    final isAssignedToCurrentUser = task.assignedToAccountId == currentUserId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDetails,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Tiêu đề lớn
            const Text(
              'VẬN HÀNH / CHI TIẾT CÔNG VIỆC',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              task.taskCode,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            const Text(
              'Thông tin và tiến độ xử lý công việc',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Top Badges Card: Phòng, Mức ưu tiên, Trạng thái
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeaderMetric('Phòng', roomCode, AppColors.textPrimary),
                  Container(height: 35, width: 1, color: AppColors.border),
                  _buildHeaderMetric('Mức ưu tiên', task.displayPriorityName, priorityColor),
                  Container(height: 35, width: 1, color: AppColors.border),
                  _buildHeaderMetricBadge('Trạng thái', task.displayStatusName, statusColor, statusBgColor),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Thông tin công việc
            _buildSectionCard(
              title: 'Thông tin công việc',
              child: Column(
                children: [
                  _buildInfoRow('Tiêu đề', task.title, isBold: true),
                  const Divider(height: 18),
                  _buildInfoRow('Mô tả', task.description.isNotEmpty ? task.description : 'Không có'),
                  const Divider(height: 18),
                  _buildInfoRow('Phòng', roomCode),
                  const Divider(height: 18),
                  _buildInfoRow('Loại công việc', task.isMaintenance ? 'Maintenance (Bảo trì)' : 'Housekeeping (Buồng phòng)'),
                  const Divider(height: 18),
                  _buildInfoRow('Loại xử lý phòng', task.displayKindName),
                  const Divider(height: 18),
                  _buildInfoRow('Mức ưu tiên', task.displayPriorityName, valueColor: priorityColor, isBold: true),
                  const Divider(height: 18),
                  _buildInfoRow('Trạng thái', task.displayStatusName, valueColor: statusColor, isBold: true),
                  const Divider(height: 18),
                  _buildInfoRow('Người được giao', assignedPerson, isBold: true),
                  const Divider(height: 18),
                  _buildInfoRow('Người tạo', createdByPerson),
                  const Divider(height: 18),
                  _buildInfoRow('Ghi chú hoàn thành', task.completionNotes ?? 'Không có'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Tiến độ và thời gian
            _buildSectionCard(
              title: 'Tiến độ và thời gian',
              child: Column(
                children: [
                  _buildInfoRow('Ngày tạo', _formatDateTime(task.createdAt)),
                  const Divider(height: 18),
                  _buildInfoRow('Hạn hoàn thành', _formatDateTime(task.dueAt)),
                  const Divider(height: 18),
                  _buildInfoRow('Bắt đầu lúc', task.startedAt != null ? _formatDateTime(task.startedAt) : 'Chưa bắt đầu'),
                  const Divider(height: 18),
                  _buildInfoRow('Hoàn thành lúc', task.completedAt != null ? _formatDateTime(task.completedAt) : 'Chưa hoàn thành'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Thao tác công việc
            _buildSectionCard(
              title: 'Thao tác công việc',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THAO TÁC CHO ROOM STAFF
                  if (isRoomStaff || isAssignedToCurrentUser) ...[
                    if (task.isAssigned || task.isPending) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _startTask(task),
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text(
                            'Bắt đầu thực hiện (In Progress)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] else if (task.isInProgress) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _completeTask(task, currentUserId),
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: const Text(
                            'Hoàn thành công việc (Completed)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusActiveText,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] else if (task.isCompleted) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.statusActiveBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.statusActiveText.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.statusActiveText),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Công việc đã hoàn thành. Phòng đã sẵn sàng đón khách!',
                                style: TextStyle(color: AppColors.statusActiveText, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],

                  // THAO TÁC CHO ADMIN / LỄ TÂN
                  if (isAdminOrReceptionist) ...[
                    Row(
                      children: [
                        if (!task.isCompleted && !task.isCancelled) ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showAssignDialog(task),
                              icon: const Icon(Icons.person_add, size: 18, color: Colors.white),
                              label: Text(
                                task.assignedToAccountId != null ? 'Đổi nhân viên' : 'Phân công',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showCancelDialog(task),
                              icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.statusOccupiedText),
                              label: const Text('Hủy việc', style: TextStyle(color: AppColors.statusOccupiedText, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.statusOccupiedText),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: Text(
                              task.isCompleted ? 'Công việc này đã hoàn thành.' : 'Công việc này đã bị hủy.',
                              style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildHeaderMetricBadge(String label, String value, Color textColor, Color bgColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
