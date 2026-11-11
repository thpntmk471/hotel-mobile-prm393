import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/stat_metric_card.dart';
import '../../../guest/presentation/pages/guest_list_page.dart';
import '../../../hotel_service/presentation/pages/service_catalog_page.dart';
import '../../../reservation/presentation/pages/booking_page.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../../room_type/presentation/pages/room_type_list_page.dart';
import '../../../staff/presentation/pages/staff_list_page.dart';
import '../../../stay/presentation/pages/stay_detail_page.dart';
import '../../../stay/presentation/providers/stay_provider.dart';
import '../../../task/presentation/pages/task_list_page.dart';
import '../../../task/presentation/providers/task_provider.dart';
import '../../../audit_log/presentation/pages/audit_log_list_page.dart';
import '../../../report/presentation/pages/report_overview_page.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  final void Function(int index)? onNavigateTab;

  const HomePage({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>().session;
    final role = session?.role.toLowerCase() ?? 'receptionist';
    final isAdmin = role.contains('admin');
    final isHousekeeping = role.contains('house') || role.contains('room') || role.contains('buồng');

    final roomProvider = context.watch<RoomProvider>();
    final reservationProvider = context.watch<ReservationProvider>();
    final stayProvider = context.watch<StayProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final totalRooms = roomProvider.rooms.length;
    final cleanRooms = roomProvider.rooms.where((r) => r.isClean).length;
    final dirtyRooms = roomProvider.rooms.where((r) => r.isDirty).length;
    final activeStaysCount = stayProvider.stays.where((s) => s.isActive).length;
    final occupancyRate = totalRooms > 0
        ? ((activeStaysCount / totalRooms) * 100).toStringAsFixed(0)
        : '0';

    final confirmedBookingsCount = reservationProvider.reservations
        .where((r) => r.isConfirmed)
        .length;

    final pendingTasksCount = taskProvider.tasks
        .where((t) => t.isPending)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            roomProvider.fetchRooms(),
            reservationProvider.fetchReservations(),
            stayProvider.fetchStays(),
            taskProvider.fetchTasks(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Đẳng Cấp 5 Sao với Emerald Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 16,
                  16,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text(
                              '★★★★★',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 13,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'PRM GRAND HOTEL & RESORTS',
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            '● ${session?.role ?? (isHousekeeping ? "Buồng phòng" : "Lễ tân")}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4AF37),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: Text(
                              (session?.fullName.isNotEmpty == true ? session!.fullName : (isHousekeeping ? 'B' : 'L'))
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào, ${session?.fullName ?? (isHousekeeping ? "Nhân viên Buồng phòng" : "Lễ tân Demo")}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isHousekeeping
                                    ? 'Hôm nay • Ca trực Buồng phòng & Vệ sinh'
                                    : 'Hôm nay, Thứ Sáu • Ca Sáng (07:00 - 15:00)',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Nội dung phần thân
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lưới 4 Thẻ KPI Vận hành (tự co giãn 4 cột khi xoay ngang)
                    Builder(
                      builder: (ctx) {
                        final isLandscape = MediaQuery.of(ctx).orientation == Orientation.landscape;
                        return GridView.count(
                          crossAxisCount: isLandscape ? 4 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: isLandscape ? 1.45 : 1.35,
                          children: [
                            StatMetricCard(
                              icon: Icons.hotel_outlined,
                              title: 'Phòng sạch sẵn sàng',
                              value: '$cleanRooms/$totalRooms',
                              subtitle: 'Phòng',
                              iconColor: AppColors.statusActiveText,
                              iconBgColor: AppColors.statusActiveBg,
                              onTap: () => onNavigateTab?.call(1),
                            ),
                            StatMetricCard(
                              icon: Icons.pie_chart_outline,
                              title: 'Tỷ lệ lấp đầy',
                              value: '$occupancyRate%',
                              subtitle: '$activeStaysCount phòng ở',
                              iconColor: const Color(0xFF2563EB),
                              iconBgColor: const Color(0xFFDBEAFE),
                              onTap: () => onNavigateTab?.call(3),
                            ),
                            StatMetricCard(
                              icon: Icons.calendar_today_outlined,
                              title: 'Đơn chờ check-in',
                              value: '$confirmedBookingsCount đơn',
                              subtitle: 'Hôm nay',
                              iconColor: const Color(0xFFD97706),
                              iconBgColor: const Color(0xFFFEF3C7),
                              onTap: () => onNavigateTab?.call(2),
                            ),
                            StatMetricCard(
                              icon: Icons.cleaning_services_outlined,
                              title: 'Cần dọn phòng',
                              value: '$dirtyRooms phòng',
                              subtitle: '$pendingTasksCount việc chờ',
                              iconColor: const Color(0xFFDC2626),
                              iconBgColor: const Color(0xFFFEE2E2),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const TaskListPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phím tắt thao tác nhanh
                    const Text(
                      'THAO TÁC NHANH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: isHousekeeping
                          ? [
                              _buildQuickAction(
                                context,
                                icon: Icons.cleaning_services,
                                label: 'Nhiệm vụ dọn',
                                color: AppColors.primary,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const TaskListPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickAction(
                                context,
                                icon: Icons.hotel_outlined,
                                label: 'Phòng bẩn',
                                color: const Color(0xFFD97706),
                                onTap: () => onNavigateTab?.call(1),
                              ),
                              _buildQuickAction(
                                context,
                                icon: Icons.room_service_outlined,
                                label: 'Dịch vụ',
                                color: const Color(0xFF7C3AED),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ServiceCatalogPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickAction(
                                context,
                                icon: Icons.task_alt,
                                label: 'Nghiệm thu',
                                color: const Color(0xFF059669),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const TaskListPage(),
                                    ),
                                  );
                                },
                              ),
                            ]
                          : [
                              _buildQuickAction(
                                context,
                                icon: Icons.add_circle,
                                label: 'Đặt phòng',
                                color: AppColors.primary,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const BookingPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickAction(
                                context,
                                icon: Icons.login_rounded,
                                label: 'Nhận phòng',
                                color: const Color(0xFF2563EB),
                                onTap: () => onNavigateTab?.call(2),
                              ),
                              _buildQuickAction(
                                context,
                                icon: Icons.room_service_outlined,
                                label: 'Dịch vụ',
                                color: const Color(0xFF7C3AED),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ServiceCatalogPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickAction(
                                context,
                                icon: Icons.cleaning_services_outlined,
                                label: 'Dọn phòng',
                                color: const Color(0xFF059669),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const TaskListPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                    ),
                    const SizedBox(height: 18),

                    // Phím tắt quản trị nghiệp vụ
                    const Text(
                      'QUẢN TRỊ NGHIỆP VỤ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAction(
                          context,
                          icon: Icons.category,
                          label: 'Loại phòng',
                          color: const Color(0xFFD97706),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RoomTypeListPage(),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.people_alt,
                          label: 'Khách hàng',
                          color: const Color(0xFF0284C7),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GuestListPage(),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.badge_outlined,
                          label: 'Nhân viên',
                          color: const Color(0xFF6366F1),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StaffListPage(),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.room_service_outlined,
                          label: 'Dịch vụ',
                          color: const Color(0xFF7C3AED),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ServiceCatalogPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'QUẢN TRỊ HỆ THỐNG',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAdminBannerCard(
                              context,
                              icon: Icons.analytics_outlined,
                              title: 'Báo cáo tổng hợp',
                              subtitle: 'Doanh thu & công suất',
                              color: const Color(0xFF176B62),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ReportOverviewPage()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildAdminBannerCard(
                              context,
                              icon: Icons.history_edu_outlined,
                              title: 'Nhật ký hoạt động',
                              subtitle: 'Audit log hệ thống',
                              color: const Color(0xFF2563EB),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AuditLogListPage()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Mục: Khách đang lưu trú
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PHÒNG ĐANG LƯU TRÚ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onNavigateTab?.call(3),
                          child: const Text(
                            'Xem tất cả →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (stayProvider.stays.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text(
                            'Hiện tại chưa có khách lưu trú.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ...stayProvider.stays.take(3).map((stay) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Theme.of(context).cardColor,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StayDetailPage(
                                      stay: stay,
                                      onCheckOutSuccess: () {
                                        stayProvider.checkOutAndPay(
                                          stay.id,
                                          'Tiền mặt',
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          stay.roomNumber.replaceAll('DEV-', ''),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stay.guestName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${stay.roomTypeName} • ${stay.stayCode}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.statusActiveBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        stay.status,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.statusActiveText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 20),

                    // Mục: Tác vụ buồng phòng gần nhất
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'NHIỆM VỤ BUỒNG PHÒNG',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TaskListPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Quản lý việc →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (taskProvider.tasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text(
                            'Tất cả phòng đã được dọn sạch!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ...taskProvider.tasks.take(2).map((t) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Theme.of(context).cardColor,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    t.isDone
                                        ? Icons.check_circle_outline
                                        : t.isInProgress
                                            ? Icons.hourglass_top
                                            : Icons.pending_actions,
                                        color: t.isDone
                                            ? AppColors.statusActiveText
                                            : AppColors.statusWarningText,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${t.roomNumber} - ${t.taskType}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Ưu tiên: ${t.priority} • ${t.assignedStaff ?? "Chưa phân công"}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    t.displayStatusName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: t.isDone
                                          ? AppColors.statusActiveText
                                          : AppColors.statusWarningText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBannerCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
