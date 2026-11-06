import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reservation/presentation/pages/reservation_list_page.dart';
import '../../../room/presentation/pages/room_list_page.dart';
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
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
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
              icon: Icons.cleaning_services,
              title: 'Quản lý công việc',
              subtitle: 'Phân công và ghi nhận hoàn thành nhiệm vụ dọn buồng phòng.',
              onTap: () {},
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

