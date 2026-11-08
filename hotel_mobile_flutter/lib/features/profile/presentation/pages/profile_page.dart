import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../guest/presentation/pages/guest_list_page.dart';
import '../../../room/presentation/pages/room_list_page.dart';
import '../../../room_type/presentation/pages/room_type_list_page.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();
    final session = authProvider.session;
    final profile = profileProvider.profile;

    final name = (session?.fullName != null && session!.fullName.isNotEmpty)
        ? session.fullName
        : (profile?.fullName ?? 'Nhân viên Khách sạn');
    final role = (session?.role != null && session!.role.isNotEmpty)
        ? session.role
        : (profile?.role ?? 'Receptionist');
    final username = session?.username ?? 'user';
    final email = (session?.email != null && session!.email!.isNotEmpty)
        ? session.email!
        : (profile?.email ?? '$username@hotelprm.com');
    final phone = (session?.phone != null && session!.phone!.isNotEmpty)
        ? session.phone!
        : (profile?.phone ?? '0901 234 567');

    String department = 'Bộ phận Lễ tân & Tiền sảnh';
    final lowerRole = role.toLowerCase();
    if (lowerRole.contains('admin')) {
      department = 'Ban Quản trị & Điều hành Khách sạn';
    } else if (lowerRole.contains('house') || lowerRole.contains('buồng') || lowerRole.contains('room')) {
      department = 'Bộ phận Quản lý Buồng phòng';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ & Cài đặt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Card Thông tin cá nhân Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    department,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '● Vai trò: $role',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Trạng thái ca trực
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Ca làm việc', value: 'Sáng (07:00 - 15:00)'),
                  SizedBox(height: 30, child: VerticalDivider()),
                  _StatItem(label: 'Trạng thái', value: 'Đang trực tuyến', isGreen: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mục: Cài đặt ứng dụng
            _buildSectionHeader('CÀI ĐẶT ỨNG DỤNG'),
            Material(
              color: Theme.of(context).cardColor,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Giao diện tối (Dark Mode)'),
                    subtitle: const Text('Bật chế độ màu tối bảo vệ mắt ban đêm'),
                    secondary: const Icon(Icons.dark_mode, color: AppColors.primary),
                    value: profileProvider.isDarkMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      profileProvider.toggleDarkMode(val);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Thông báo đẩy (Notification)'),
                    subtitle: const Text('Nhận cảnh báo khi có đơn đặt phòng hoặc yêu cầu dọn phòng'),
                    secondary: const Icon(Icons.notifications_active, color: AppColors.primary),
                    value: profile?.notificationsEnabled ?? true,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      profileProvider.toggleNotifications(val);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services, color: AppColors.primary),
                    title: const Text('Xóa bộ nhớ đệm (Cache)'),
                    subtitle: const Text('Giải phóng dữ liệu tạm trong máy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã dọn dẹp thành công 14.8 MB bộ nhớ đệm.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mục: Quản trị nghiệp vụ khách sạn
            _buildSectionHeader('QUẢN TRỊ NGHIỆP VỤ'),
            Material(
              color: Theme.of(context).cardColor,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.meeting_room, color: AppColors.primary),
                    title: const Text('Quản lý Phòng (Rooms)'),
                    subtitle: const Text('Thêm mới, sửa thông tin & vận hành buồng phòng'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoomListPage()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.category, color: AppColors.primary),
                    title: const Text('Quản lý Loại Phòng (Room Types)'),
                    subtitle: const Text('Cấu hình các hạng phòng, giá niêm yết, sức chứa'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoomTypeListPage()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.people, color: AppColors.primary),
                    title: const Text('Quản lý Khách Hàng (Guests)'),
                    subtitle: const Text('Danh sách hồ sơ khách lưu trú, CCCD, liên lạc'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GuestListPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mục: Thông tin liên hệ
            _buildSectionHeader('THÔNG TIN LIÊN HỆ'),
            Material(
              color: Theme.of(context).cardColor,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                    title: const Text('Email công việc'),
                    subtitle: Text(email),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                    title: const Text('Số điện thoại'),
                    subtitle: Text(phone),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit_note, color: AppColors.primary),
                    title: const Text('Cập nhật thông tin'),
                    subtitle: const Text('Sửa họ tên, email hoặc số điện thoại'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showEditProfileDialog(context, name, phone, email),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mục: Hệ thống & Đăng xuất
            _buildSectionHeader('HỆ THỐNG'),
            Material(
              color: Theme.of(context).cardColor,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
                    title: Text('Phiên bản ứng dụng'),
                    subtitle: Text('Hotel Management Mobile v1.0.0 (PRM393 Build 2026)'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.cloud_done_outlined, color: AppColors.textSecondary),
                    title: Text('Backend Architecture'),
                    subtitle: Text('PRN232 Micro-APIs (12 Services + SQL Server)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút Đăng xuất
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Đăng xuất khỏi hệ thống',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showLogoutConfirmDialog(context),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    String currentName,
    String currentPhone,
    String currentEmail,
  ) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final emailCtrl = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật thông tin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prov = context.read<ProfileProvider>();
              final success = await prov.updateProfile(
                fullName: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Đã cập nhật thông tin thành công!'
                          : 'Cập nhật thất bại!',
                    ),
                    backgroundColor:
                        success ? AppColors.primary : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi phiên làm việc hiện tại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ở lại'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isGreen;

  const _StatItem({
    required this.label,
    required this.value,
    this.isGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isGreen ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}
