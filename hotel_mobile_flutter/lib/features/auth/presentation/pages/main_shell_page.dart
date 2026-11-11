import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../reservation/presentation/pages/reservation_list_page.dart';
import '../../../room/presentation/pages/room_list_page.dart';
import '../../../stay/presentation/pages/stay_list_page.dart';
import '../../../task/presentation/pages/task_list_page.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart';

class MainShellPage extends StatefulWidget {
  final int initialIndex;

  const MainShellPage({super.key, this.initialIndex = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>().session;
    final role = session?.role.toLowerCase() ?? 'receptionist';
    final isHousekeeping = role.contains('house') || role.contains('room') || role.contains('buồng');

    // Cấu hình giao diện và thanh điều hướng động theo vai trò (Role-Based Navigation)
    final List<Widget> pages;
    final List<NavigationDestination> destinations;

    if (isHousekeeping) {
      // Giao diện chuyên biệt cho Nhân viên Buồng phòng
      pages = [
        const TaskListPage(),
        const RoomListPage(),
        HomePage(onNavigateTab: _onTabSelected),
        const ProfilePage(),
      ];

      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.cleaning_services_outlined),
          selectedIcon: Icon(Icons.cleaning_services, color: AppColors.primary),
          label: 'Nhiệm vụ',
        ),
        NavigationDestination(
          icon: Icon(Icons.hotel_outlined),
          selectedIcon: Icon(Icons.hotel, color: AppColors.primary),
          label: 'Phòng',
        ),
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
          label: 'Tổng quan',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Hồ sơ',
        ),
      ];
    } else {
      // Giao diện cho Lễ tân & Quản trị viên
      pages = [
        HomePage(onNavigateTab: _onTabSelected),
        const RoomListPage(),
        const ReservationListPage(),
        const StayListPage(),
        const ProfilePage(),
      ];

      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
          label: 'Tổng quan',
        ),
        NavigationDestination(
          icon: Icon(Icons.hotel_outlined),
          selectedIcon: Icon(Icons.hotel, color: AppColors.primary),
          label: 'Phòng',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
          label: 'Đặt phòng',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment, color: AppColors.primary),
          label: 'Lưu trú',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Hồ sơ',
        ),
      ];
    }

    final safeIndex = _currentIndex < pages.length ? _currentIndex : 0;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      // Khi xoay ngang màn hình (Landscape), chuyển sang NavigationRail bên trái
      // giúp tối đa hóa chiều dọc hiển thị dữ liệu và không bị tràn giao diện
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: safeIndex,
              onDestinationSelected: _onTabSelected,
              backgroundColor: Theme.of(context).cardColor,
              indicatorColor: AppColors.primaryLight,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(Icons.hotel_class, color: AppColors.primary, size: 28),
              ),
              destinations: destinations.map((d) {
                return NavigationRailDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon ?? d.icon,
                  label: Text(d.label, style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 0.8, width: 1, color: AppColors.border),
            Expanded(
              child: IndexedStack(
                index: safeIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(alpha: 0.8),
              width: 0.8,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: Theme.of(context).cardColor,
          indicatorColor: AppColors.primaryLight,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: destinations,
        ),
      ),
    );
  }
}
