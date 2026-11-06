import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../hotel_service/presentation/pages/service_catalog_page.dart';
import '../../../reservation/presentation/pages/reservation_list_page.dart';
import '../../../room/presentation/pages/room_list_page.dart';
import '../../../stay/presentation/pages/stay_list_page.dart';
import '../../../task/presentation/pages/task_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>().session;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tổng quan hệ thống'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppColors.primary),
            tooltip: 'Hồ sơ & Cài đặt',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Đăng xuất',
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Lời chào và Badge chức danh (đồng bộ hình Web)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TỔNG QUAN HỆ THỐNG',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.statusActiveBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '● ${session?.role ?? "Receptionist"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusActiveText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Xin chào, ${session?.fullName ?? "Lễ tân Demo"}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Truy cập các chức năng quản lý và vận hành khách sạn từ không gian làm việc thống nhất.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'KHÔNG GIAN LÀM VIỆC',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              icon: Icons.hotel,
              title: 'Vận hành phòng',
              subtitle: 'Theo dõi danh sách phòng, tình trạng buồng phòng sạch/cần dọn.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RoomListPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              icon: Icons.calendar_month,
              title: 'Đặt phòng',
              subtitle: 'Theo dõi và xử lý các đơn đặt phòng của khách hàng.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReservationListPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              icon: Icons.assignment,
              title: 'Lễ tân & Lưu trú',
              subtitle: 'Theo dõi hoạt động check-in, chi tiết hóa đơn và check-out trả phòng.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StayListPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              icon: Icons.room_service,
              title: 'Dịch vụ khách sạn',
              subtitle: 'Menu F&B buffet, giặt ủi, spa massage và gọi phục vụ tận phòng.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ServiceCatalogPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              icon: Icons.cleaning_services,
              title: 'Quản lý công việc',
              subtitle: 'Phân công và ghi nhận hoàn thành nhiệm vụ dọn buồng phòng.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TaskListPage()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              icon: Icons.person_outline,
              title: 'Hồ sơ & Cài đặt',
              subtitle: 'Thông tin tài khoản, chuyển đổi Dark/Light mode, phiên bản app.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

