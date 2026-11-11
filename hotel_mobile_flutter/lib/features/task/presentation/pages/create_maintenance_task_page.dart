import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../../staff/presentation/providers/staff_provider.dart';
import '../providers/task_provider.dart';
import 'task_detail_page.dart';

class CreateMaintenanceTaskPage extends StatefulWidget {
  final int? preselectedRoomId;

  const CreateMaintenanceTaskPage({super.key, this.preselectedRoomId});

  @override
  State<CreateMaintenanceTaskPage> createState() => _CreateMaintenanceTaskPageState();
}

class _CreateMaintenanceTaskPageState extends State<CreateMaintenanceTaskPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedRoomId;
  int _priority = 2; // 1: Thấp, 2: Bình thường, 3: Cao, 4: Khẩn cấp

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  int? _assignedToAccountId;
  DateTime? _dueAt;
  final DateTime _blockStartAt = DateTime.now();
  DateTime? _blockEndAt;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRoomId = widget.preselectedRoomId;
    _titleController.text = 'Báo cáo sự cố phòng';

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

  Future<void> _selectDateTime({required bool isDue, required bool isBlockEnd}) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 2)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 30)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 17, minute: 0),
      );

      if (pickedTime != null) {
        final dt = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isDue) {
            _dueAt = dt;
          } else if (isBlockEnd) {
            _blockEndAt = dt;
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phòng phát sinh sự cố!'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    final isRoomStaff = (auth.session?.role.toLowerCase() ?? '').contains('room') ||
        (auth.session?.role.toLowerCase() ?? '').contains('house') ||
        (auth.session?.role.toLowerCase() ?? '').contains('buồng');

    try {
      final createdTask = await context.read<TaskProvider>().createMaintenanceTask(
        roomId: _selectedRoomId!,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        dueAt: _dueAt,
        // Nhân viên phòng chỉ báo cáo sự cố, không được tự phân công người xử lý
        assignedToAccountId: isRoomStaff ? null : _assignedToAccountId,
        blockStartAt: _blockStartAt,
        blockEndAt: _blockEndAt,
        createdByAccountId: auth.currentUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo phiếu bảo trì "${createdTask.title}" thành công!'),
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
          SnackBar(content: Text('Lỗi tạo phiếu bảo trì: $e'), backgroundColor: AppColors.error),
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
    final auth = context.watch<AuthProvider>();
    final isRoomStaff = (auth.session?.role.toLowerCase() ?? '').contains('room') ||
        (auth.session?.role.toLowerCase() ?? '').contains('house') ||
        (auth.session?.role.toLowerCase() ?? '').contains('buồng');

    // Phân công chỉ chọn role 3 (Room Staff)
    final roomStaffList = allStaff.where((s) => s.role == 3 && s.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Báo sự cố & Tạo việc bảo trì'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VẬN HÀNH / BẢO TRÌ PHÒNG',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tạo việc bảo trì & Báo cáo sự cố',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ghi nhận sự cố hư hỏng phòng để đội ngũ kỹ thuật và buồng phòng xử lý kịp thời.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Card 1: Phòng & Mức độ khẩn cấp
              _buildSectionCard(
                title: '1. Phòng phát sinh sự cố',
                subtitle: 'Chọn phòng và đánh giá mức độ khẩn cấp.',
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
                            'Phòng ${r.roomNumber} (${r.roomTypeName}) - ${r.operationalStatus}',
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
                            _titleController.text = 'Bảo trì phòng ${r.roomNumber}';
                          }
                        });
                      },
                      validator: (val) => val == null ? 'Vui lòng chọn phòng' : null,
                    ),
                    const SizedBox(height: 14),

                    const Text('Mức độ ưu tiên / Khẩn cấp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                        DropdownMenuItem(value: 4, child: Text('Khẩn cấp (Cần khóa phòng ngay)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 2: Nội dung sự cố
              _buildSectionCard(
                title: '2. Chi tiết sự cố / Hư hỏng',
                subtitle: 'Mô tả rõ biểu hiện hư hại thiết bị (điều hòa, bóng đèn, vòi nước...).',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tiêu đề sự cố *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tóm tắt sự cố (ví dụ: Hỏng khóa từ cửa)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Vui lòng nhập tiêu đề sự cố' : null,
                    ),
                    const SizedBox(height: 14),

                    const Text('Mô tả chi tiết lỗi *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        hintText: 'Mô tả hiện trạng, vị trí hỏng và thiết bị cần thay thế...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      maxLines: 3,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Vui lòng mô tả chi tiết lỗi' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 3: Phân công & Khóa phòng (Chỉ Admin / Lễ tân được phân công)
              if (!isRoomStaff)
                _buildSectionCard(
                  title: '3. Phân công & Thời hạn xử lý',
                  subtitle: 'Giao cho nhân viên buồng phòng/kỹ thuật và thiết lập hạn xử lý.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Nhân viên xử lý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Room Staff (vai trò 3)', style: TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                        onChanged: (val) => setState(() => _assignedToAccountId = val),
                      ),
                      const SizedBox(height: 14),

                      const Text('Hạn hoàn thành', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selectDateTime(isDue: true, isBlockEnd: false),
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
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Tạo việc bảo trì', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
