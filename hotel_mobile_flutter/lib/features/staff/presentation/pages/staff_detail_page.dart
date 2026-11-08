import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/staff_member.dart';
import '../providers/staff_provider.dart';

class StaffDetailPage extends StatefulWidget {
  final StaffMember initialStaff;

  const StaffDetailPage({super.key, required this.initialStaff});

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  late StaffMember _staff;
  late int _selectedRole;

  @override
  void initState() {
    super.initState();
    _staff = widget.initialStaff;
    _selectedRole = _staff.role;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadStaff();
    });
  }

  Future<void> _reloadStaff() async {
    final updated = await context.read<StaffProvider>().fetchStaffDetail(_staff.id);
    if (updated != null && mounted) {
      setState(() {
        _staff = updated;
        _selectedRole = updated.role;
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  Color _getRoleColor(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('admin')) return const Color(0xFF7C3AED);
    if (lower.contains('reception')) return AppColors.primary;
    return const Color(0xFFD97706); // Staff Room
  }

  Color _getRoleBgColor(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('admin')) return const Color(0xFFF3E8FF);
    if (lower.contains('reception')) return AppColors.primaryLight;
    return const Color(0xFFFEF3C7);
  }

  void _showEditInfoDialog() {
    final nameCtrl = TextEditingController(text: _staff.fullName);
    final phoneCtrl = TextEditingController(text: _staff.phoneNumber ?? '');
    final emailCtrl = TextEditingController(text: _staff.email ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật thông tin nhân viên'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email liên hệ',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
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
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx);
                final provider = context.read<StaffProvider>();
                final ok = await provider.updateStaff(
                  id: _staff.id,
                  fullName: nameCtrl.text.trim(),
                  phoneNumber: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                );

                if (!mounted) return;
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật thông tin nhân viên thành công!'),
                      backgroundColor: AppColors.statusActiveText,
                    ),
                  );
                  _reloadStaff();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Không thể cập nhật nhân viên.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Lưu thông tin', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showConfirmToggleStatus() {
    final nextStatus = !_staff.isActive;
    final actionText = nextStatus ? 'Kích hoạt tài khoản' : 'Vô hiệu hóa tài khoản';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận $actionText'),
        content: Text(
          'Bạn có chắc chắn muốn $actionText của nhân viên "${_staff.fullName}" (${_staff.username})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: nextStatus ? AppColors.primary : AppColors.statusOccupiedText,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<StaffProvider>();
              final ok = await provider.toggleStatus(_staff);

              if (!mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã $actionText thành công!'),
                    backgroundColor: AppColors.statusActiveText,
                  ),
                );
                _reloadStaff();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Thao tác thất bại.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(actionText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết nhân viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _reloadStaff,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Sửa thông tin',
            onPressed: _showEditInfoDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ Header Tóm Tắt
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getRoleBgColor(_staff.displayRole),
                    child: Text(
                      _staff.fullName.isNotEmpty
                          ? _staff.fullName[0].toUpperCase()
                          : _staff.username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(_staff.displayRole),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _staff.fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${_staff.username}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRoleBgColor(_staff.displayRole),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _staff.displayRole,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getRoleColor(_staff.displayRole),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _staff.isActive ? AppColors.statusActiveBg : AppColors.statusOccupiedBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _staff.isActive ? 'Đang hoạt động' : 'Vô hiệu hóa',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _staff.isActive ? AppColors.statusActiveText : AppColors.statusOccupiedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mục: Thông tin nhân viên
            _buildSectionCard(
              title: 'THÔNG TIN NHÂN VIÊN',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow('Mã tài khoản', '#${_staff.id}'),
                _buildInfoRow('Tên đăng nhập', _staff.username),
                _buildInfoRow('Họ và tên', _staff.fullName),
                _buildInfoRow('Số điện thoại', _staff.phoneNumber ?? 'Chưa cập nhật'),
                _buildInfoRow('Email liên hệ', _staff.email ?? 'Chưa cập nhật'),
                _buildInfoRow('Vai trò', _staff.displayRole),
                _buildInfoRow('Trạng thái', _staff.isActive ? 'Đang hoạt động' : 'Vô hiệu hóa'),
              ],
            ),
            const SizedBox(height: 16),

            // Mục: Lịch sử tài khoản
            _buildSectionCard(
              title: 'LỊCH SỬ TÀI KHOẢN',
              icon: Icons.history,
              children: [
                _buildInfoRow('Ngày tạo', _formatDateTime(_staff.createdAt)),
                _buildInfoRow(
                  'Cập nhật lần cuối',
                  _staff.updatedAt != null ? _formatDateTime(_staff.updatedAt!) : 'Chưa cập nhật',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mục: Quản trị tài khoản
            _buildSectionCard(
              title: 'QUẢN TRỊ TÀI KHOẢN',
              icon: Icons.admin_panel_settings_outlined,
              children: [
                const Text(
                  'Thay đổi vai trò nhân viên',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Admin (Quản trị viên)')),
                          DropdownMenuItem(value: 2, child: Text('Receptionist (Lễ tân)')),
                          DropdownMenuItem(value: 3, child: Text('Staff Room (Buồng phòng)')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedRole = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onPressed: _selectedRole == _staff.role
                          ? null
                          : () async {
                              final provider = context.read<StaffProvider>();
                              final messenger = ScaffoldMessenger.of(context);
                              final ok = await provider.changeRole(id: _staff.id, role: _selectedRole);
                              if (!mounted) return;
                              if (ok) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã cập nhật vai trò mới thành công!'),
                                    backgroundColor: AppColors.statusActiveText,
                                  ),
                                );
                                _reloadStaff();
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(provider.errorMessage ?? 'Không thể đổi vai trò.'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                      child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trạng thái tài khoản',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          _staff.isActive
                              ? 'Tài khoản đang hoạt động bình thường'
                              : 'Tài khoản đang bị tạm ngưng / vô hiệu hóa',
                          style: TextStyle(
                            fontSize: 12,
                            color: _staff.isActive ? AppColors.textSecondary : AppColors.statusOccupiedText,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _staff.isActive ? AppColors.statusOccupiedText : AppColors.primary,
                        ),
                      ),
                      onPressed: _showConfirmToggleStatus,
                      child: Text(
                        _staff.isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
                        style: TextStyle(
                          color: _staff.isActive ? AppColors.statusOccupiedText : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
