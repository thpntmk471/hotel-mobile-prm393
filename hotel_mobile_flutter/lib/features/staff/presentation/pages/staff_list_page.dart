import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/staff_member.dart';
import '../providers/staff_provider.dart';
import 'staff_detail_page.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final _searchController = TextEditingController();
  int? _selectedRole; // null = Tất cả, 1: Admin, 2: Receptionist, 3: Staff Room
  bool? _selectedStatus; // null = Tất cả, true: Hoạt động, false: Vô hiệu hóa

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStaffList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  Color _getRoleColor(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('admin')) return const Color(0xFF7C3AED);
    if (lower.contains('reception')) return AppColors.primary;
    return const Color(0xFFD97706);
  }

  Color _getRoleBgColor(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('admin')) return const Color(0xFFF3E8FF);
    if (lower.contains('reception')) return AppColors.primaryLight;
    return const Color(0xFFFEF3C7);
  }

  // --- CRUD: TẠO TÀI KHOẢN MỚI ---
  void _showCreateStaffDialog() {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    int role = 2; // Mặc định Lễ tân
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Tạo tài khoản nhân viên mới'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: userCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên đăng nhập *',
                        hintText: 'letan01, room_staff...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên đăng nhập';
                        if (v.trim().length < 3) return 'Tên đăng nhập tối thiểu 3 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu *',
                        hintText: 'Tối thiểu 6 ký tự',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mật khẩu';
                        if (v.trim().length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
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
                    DropdownButtonFormField<int>(
                      initialValue: role,
                      decoration: const InputDecoration(
                        labelText: 'Vai trò nhân viên *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Admin (Quản trị viên)')),
                        DropdownMenuItem(value: 2, child: Text('Receptionist (Lễ tân)')),
                        DropdownMenuItem(value: 3, child: Text('Staff Room (Buồng phòng)')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => role = v);
                      },
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
                    final ok = await provider.createStaff(
                      username: userCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                      fullName: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                      email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                      role: role,
                    );

                    if (!mounted) return;
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã tạo tài khoản cho ${nameCtrl.text.trim()}!'),
                          backgroundColor: AppColors.statusActiveText,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage ?? 'Không thể tạo tài khoản.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Tạo tài khoản', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CRUD: SỬA THÔNG TIN NHÂN VIÊN ---
  void _showEditStaffDialog(StaffMember staff) {
    final nameCtrl = TextEditingController(text: staff.fullName);
    final phoneCtrl = TextEditingController(text: staff.phoneNumber ?? '');
    final emailCtrl = TextEditingController(text: staff.email ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa thông tin: ${staff.username}'),
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
                  id: staff.id,
                  fullName: nameCtrl.text.trim(),
                  phoneNumber: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                );

                if (!mounted) return;
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã cập nhật thông tin nhân viên ${staff.username}!'),
                      backgroundColor: AppColors.statusActiveText,
                    ),
                  );
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
            child: const Text('Lưu cập nhật', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- CRUD: BẬT / VÔ HIỆU HÓA TÀI KHOẢN ---
  void _showConfirmToggleStatus(StaffMember staff) {
    final nextStatus = !staff.isActive;
    final actionText = nextStatus ? 'Kích hoạt tài khoản' : 'Vô hiệu hóa tài khoản';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận $actionText'),
        content: Text(
          'Bạn có chắc chắn muốn $actionText của "${staff.fullName}" (@${staff.username})?',
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
              final ok = await provider.toggleStatus(staff);

              if (!mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã $actionText thành công!'),
                    backgroundColor: AppColors.statusActiveText,
                  ),
                );
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
    final provider = context.watch<StaffProvider>();
    final items = provider.staffList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Nhân Viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => context.read<StaffProvider>().fetchStaffList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tạo tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showCreateStaffDialog,
      ),
      body: Column(
        children: [
          // Khối Tìm kiếm & Bộ lọc
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => context.read<StaffProvider>().setKeyword(val),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên đăng nhập hoặc họ tên...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context.read<StaffProvider>().setKeyword('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Lọc theo vai trò
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả vai trò', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 1, child: Text('Admin', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 2, child: Text('Receptionist', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 3, child: Text('Staff Room', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedRole = val);
                          context.read<StaffProvider>().setRoleFilter(val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Lọc theo trạng thái
                    Expanded(
                      child: DropdownButtonFormField<bool?>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả trạng thái', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: true, child: Text('Hoạt động', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: false, child: Text('Vô hiệu hóa', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedStatus = val);
                          context.read<StaffProvider>().setStatusFilter(val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách nhân viên', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Có ${items.length} tài khoản', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading && items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null && items.isEmpty) {
                  return Center(child: Text(provider.errorMessage!));
                }
                if (items.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'Chưa có nhân viên nào',
                    subtitle: 'Nhấn nút "Tạo tài khoản" để thêm nhân viên vào hệ thống.',
                    buttonText: 'Tạo tài khoản mới',
                    onButtonPressed: _showCreateStaffDialog,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<StaffProvider>().fetchStaffList(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final s = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StaffDetailPage(initialStaff: s),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: _getRoleBgColor(s.displayRole),
                                      child: Text(
                                        s.fullName.isNotEmpty
                                            ? s.fullName[0].toUpperCase()
                                            : s.username[0].toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _getRoleColor(s.displayRole),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  s.fullName,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppColors.background,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: AppColors.border),
                                                ),
                                                child: Text(
                                                  '#${s.id}',
                                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '@${s.username}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Nút Thao tác: Sửa & Bật/Vô hiệu hóa
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                          tooltip: 'Sửa thông tin',
                                          onPressed: () => _showEditStaffDialog(s),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            s.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                            size: 20,
                                            color: s.isActive ? AppColors.statusOccupiedText : AppColors.statusActiveText,
                                          ),
                                          tooltip: s.isActive ? 'Vô hiệu hóa tài khoản' : 'Kích hoạt lại',
                                          onPressed: () => _showConfirmToggleStatus(s),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getRoleBgColor(s.displayRole),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            s.displayRole,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getRoleColor(s.displayRole),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: s.isActive ? AppColors.statusActiveBg : AppColors.statusOccupiedBg,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            s.isActive ? 'Hoạt động' : 'Vô hiệu hóa',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: s.isActive ? AppColors.statusActiveText : AppColors.statusOccupiedText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _formatDateTime(s.createdAt),
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (s.phoneNumber != null || s.email != null) ...[
                                  const Divider(height: 16, color: AppColors.border),
                                  Row(
                                    children: [
                                      if (s.phoneNumber != null) ...[
                                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          s.phoneNumber!,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 14),
                                      ],
                                      if (s.email != null) ...[
                                        const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            s.email!,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
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
}
