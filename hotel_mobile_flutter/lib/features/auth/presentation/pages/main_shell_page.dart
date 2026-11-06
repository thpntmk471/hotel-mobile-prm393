import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../reservation/presentation/pages/reservation_list_page.dart';
import '../../../room/presentation/pages/room_list_page.dart';
import '../../../stay/presentation/pages/stay_list_page.dart';
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
    final List<Widget> pages = [
      HomePage(onNavigateTab: _onTabSelected),
      const RoomListPage(),
      const ReservationListPage(),
      const StayListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
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
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: Theme.of(context).cardColor,
          indicatorColor: AppColors.primaryLight,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
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
          ],
        ),
      ),
    );
  }
}

