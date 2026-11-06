import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/reservation_provider.dart';
import '../widgets/reservation_card.dart';
import 'booking_page.dart';

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key});

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  final _searchController = TextEditingController();
  final List<String> _statuses = [
    'Tất cả',
    'Đã xác nhận',
    'Đã nhận phòng',
    'Đã trả phòng',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationProvider>().fetchReservations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Danh sách đặt phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () =>
                context.read<ReservationProvider>().fetchReservations(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Đặt phòng mới', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookingPage()),
          );
        },
      ),
      body: Column(
        children: [
          // Khối tìm kiếm & Lọc trạng thái
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {});
                    context.read<ReservationProvider>().setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm theo mã đơn (RSV...), tên khách...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              context.read<ReservationProvider>().setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statuses.map((status) {
                      final isSelected = reservationProvider.selectedStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (_) =>
                              context.read<ReservationProvider>().setStatusFilter(status),
                          selectedColor: AppColors.primaryLight,
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Header đếm số đơn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Đơn đặt phòng gần đây',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${reservationProvider.reservations.length} đơn',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Danh sách các đơn đặt
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<ReservationProvider>().fetchReservations(),
              child: Builder(
                builder: (context) {
                  if (reservationProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (reservationProvider.errorMessage != null) {
                    return Center(
                      child: Text(reservationProvider.errorMessage!),
                    );
                  }
                  if (reservationProvider.reservations.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.calendar_today_outlined,
                      title: 'Chưa có đơn đặt phòng nào',
                      subtitle:
                          'Tạo đơn đặt phòng mới để tiếp đón khách hàng chu đáo.',
                      buttonText: 'Tạo đơn đặt phòng',
                      onButtonPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BookingPage()),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: reservationProvider.reservations.length,
                    itemBuilder: (context, index) {
                      final res = reservationProvider.reservations[index];
                      return ReservationCard(
                        reservation: res,
                        onCheckIn: () {
                          context
                              .read<ReservationProvider>()
                              .updateStatus(res.id, 'Đã nhận phòng');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã check-in nhận phòng cho đơn ${res.id}'),
                              backgroundColor: AppColors.statusActiveText,
                            ),
                          );
                        },
                        onCheckOut: () {
                          context
                              .read<ReservationProvider>()
                              .updateStatus(res.id, 'Đã trả phòng');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã hoàn tất trả phòng cho đơn ${res.id}'),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
