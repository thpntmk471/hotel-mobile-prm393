import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../../staff/presentation/providers/staff_provider.dart';
import '../providers/task_provider.dart';
import 'task_detail_page.dart';

class CreateHousekeepingTaskPage extends StatefulWidget {
  final int? preselectedRoomId;

  const CreateHousekeepingTaskPage({super.key, this.preselectedRoomId});

  @override
  State<CreateHousekeepingTaskPage> createState() => _CreateHousekeepingTaskPageState();
}

class _CreateHousekeepingTaskPageState extends State<CreateHousekeepingTaskPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedRoomId;
  int _housekeepingKind = 1; // 1: Dọn phòng, 2: Kiểm tra phòng
  int _priority = 2; // 1: Thấp, 2: Bình thường, 3: Cao, 4: Khẩn cấp

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  int? _assignedToAccountId; // Chỉ chọn nhân viên Room Staff (role 3)
  DateTime? _dueAt;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRoomId = widget.preselectedRoomId;
    _titleController.text = 'Dọn phòng';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().fetchRooms();
      context.read<StaffProvider>().fetchStaffList();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now.add(const Duration(hours: 2)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 30)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _dueAt != null
            ? TimeOfDay(hour: _dueAt!.hour, minute: _dueAt!.minute)
            : const TimeOfDay(hour: 17, minute: 0),
      );

      if (pickedTime != null) {
        setState(() {
          _dueAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phòng cần xử lý!'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();

    final descText = _descController.text.trim();
    final finalDesc = descText.isNotEmpty ? descText : 'Dọn dẹp và kiểm tra phòng theo yêu cầu';

    try {
      final createdTask = await context.read<TaskProvider>().createHousekeepingTask(
        roomId: _selectedRoomId!,
        housekeepingKind: _housekeepingKind,
        title: _titleController.text.trim(),
        description: finalDesc,
        priority: _priority,
        dueAt: _dueAt,
        assignedToAccountId: _assignedToAccountId,
        createdByAccountId: auth.currentUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _assignedToAccountId != null
                  ? 'Đã tạo công việc "${createdTask.title}" và chuyển trạng thái sang Đã phân công!'
                  : 'Đã tạo công việc "${createdTask.title}" thành công!',
            ),
            backgroundColor: AppColors.statusActiveText,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailPage(taskId: createdTask.id, initialTask: createdTask),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo việc: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomProvider>().rooms;
    final allStaff = context.watch<StaffProvider>().staffList;

    // QUY TẮC CỐT LÕI: Phân công công việc CHỈ ĐƯỢC PHÂN CHO ROLE LÀ ROOM STAFF (role 3)
    final roomStaffList = allStaff.where((s) => s.role == 3 && s.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tạo việc dọn/kiểm tra phòng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề khối
              const Text(
                'VẬN HÀNH / CÔNG VIỆC MỚI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tạo việc dọn/kiểm tra phòng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tạo yêu cầu dọn phòng hoặc kiểm tra phòng, thiết lập mức ưu tiên và phân công nhân viên thực hiện.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Card 1: Phòng và loại công việc
              _buildSectionCard(
                title: '1. Phòng và loại công việc',
                subtitle: 'Xác định phòng cần xử lý và mức độ ưu tiên.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mã phòng *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedRoomId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      hint: const Text('-- Chọn phòng --'),
                      items: rooms.map((r) {
                        return DropdownMenuItem<int>(
                          value: r.id,
                          child: Text(
                            'Phòng ${r.roomNumber} (${r.roomTypeName}) - ${r.housekeepingStatus}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedRoomId = val;
                          if (val != null) {
                            final r = rooms.firstWhere((e) => e.id == val);
                            if (_housekeepingKind == 1) {
                              _titleController.text = 'Dọn phòng ${r.roomNumber}';
                            } else {
                              _titleController.text = 'Kiểm tra phòng ${r.roomNumber}';
                            }
                          }
                        });
                      },
                      validator: (val) => val == null ? 'Vui lòng chọn phòng' : null,
                    ),
                    const SizedBox(height: 14),

                    const Text('Loại công việc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _housekeepingKind,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Dọn phòng')),
                        DropdownMenuItem(value: 2, child: Text('Kiểm tra phòng')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _housekeepingKind = val;
                            if (_selectedRoomId != null) {
                              final r = rooms.firstWhere((e) => e.id == _selectedRoomId);
                              _titleController.text = val == 1 ? 'Dọn phòng ${r.roomNumber}' : 'Kiểm tra phòng ${r.roomNumber}';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    const Text('Mức ưu tiên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Thấp')),
                        DropdownMenuItem(value: 2, child: Text('Bình thường')),
                        DropdownMenuItem(value: 3, child: Text('Cao')),
                        DropdownMenuItem(value: 4, child: Text('Khẩn cấp')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 2: Nội dung công việc
              _buildSectionCard(
                title: '2. Nội dung công việc',
                subtitle: 'Mô tả rõ công việc để nhân viên biết rõ yêu cầu cần thực hiện.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tiêu đề *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tiêu đề công việc',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
                    ),
                    const SizedBox(height: 14),

                    const Text('Mô tả *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập nội dung công việc cần thực hiện...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mô tả công việc' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 3: Phân công và thời hạn
              _buildSectionCard(
                title: '3. Phân công và thời hạn',
                subtitle: 'Chọn nhân viên phụ trách và hạn hoàn thành nếu cần.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Text('Mã nhân viên được giao', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Chỉ Room Staff (vai trò 3)', style: TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int?>(
                      initialValue: _assignedToAccountId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('-- Chưa phân công --', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        ...roomStaffList.map((s) {
                          return DropdownMenuItem<int?>(
                            value: s.id,
                            child: Text(
                              '${s.fullName} (${s.username}) - #${s.id}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() => _assignedToAccountId = val);
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Có thể để trống và phân công sau.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),

                    const Text('Hạn hoàn thành', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _selectDueDateTime,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dueAt != null
                                  ? '${_dueAt!.day.toString().padLeft(2, '0')}/${_dueAt!.month.toString().padLeft(2, '0')}/${_dueAt!.year} ${_dueAt!.hour.toString().padLeft(2, '0')}:${_dueAt!.minute.toString().padLeft(2, '0')}'
                                  : 'dd/mm/yyyy --:--',
                              style: TextStyle(
                                color: _dueAt != null ? AppColors.textPrimary : AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Quay lại'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Tạo công việc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
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
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
