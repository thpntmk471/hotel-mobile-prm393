import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/stat_metric_card.dart';
import '../../../hotel_service/presentation/pages/service_catalog_page.dart';
import '../../../reservation/presentation/pages/booking_page.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../../stay/presentation/pages/stay_detail_page.dart';
import '../../../stay/presentation/providers/stay_provider.dart';
import '../../../task/presentation/pages/task_list_page.dart';
import '../../../task/presentation/providers/task_provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  final void Function(int index)? onNavigateTab;

  const HomePage({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>().session;
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
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                (session?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session?.fullName ?? 'Lễ tân Demo',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'PRM Grand Luxury Hotel',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusActiveBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '● ${session?.role ?? "Receptionist"}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.statusActiveText,
              ),
            ),
          ),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Băng chuyền / Lưới chỉ số vận hành (KPI Metrics)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
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
                        MaterialPageRoute(builder: (_) => const TaskListPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dòng Phím tắt thao tác nhanh (Quick Actions)
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
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'Đặt phòng',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BookingPage()),
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
                    label: 'Gọi dịch vụ',
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
              const SizedBox(height: 24),

              // Mục: Khách đang lưu trú (Recent Active Stays)
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
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                                  stayProvider.checkOutAndPay(stay.id, 'Tiền mặt');
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        MaterialPageRoute(builder: (_) => const TaskListPage()),
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
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                              t.status,
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
