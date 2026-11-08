import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../guest/presentation/pages/guest_list_page.dart';
import '../../../stay/presentation/providers/stay_provider.dart';
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
    'Đã hủy',
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuestListPage()),
                );
              },
              icon: const Icon(Icons.people_alt, size: 16),
              label: const Text('Khách hàng', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            ),
          ),
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
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xác nhận nhận phòng'),
                              content: Text(
                                'Xác nhận khách ${res.guestName} nhận phòng ${res.roomNumber}?\n\n'
                                'Hệ thống sẽ cập nhật trạng thái đơn sang "Đã nhận phòng", đồng thời kích hoạt lượt lưu trú tại phòng.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Để sau'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    try {
                                      final auth = context.read<AuthProvider>();
                                      final accountId = auth.currentUserId;
                                      final stayProv = context.read<StayProvider>();
                                      final resProv = context.read<ReservationProvider>();
                                      final success = await stayProv.checkIn(
                                        reservationId: res.numericId,
                                        accountId: accountId,
                                        notes: 'Nhận phòng tại quầy cho ${res.guestName}',
                                      );

                                      if (context.mounted) {
                                        if (success) {
                                          await resProv.fetchReservations();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Nhận phòng thành công cho khách ${res.guestName} (phòng ${res.roomNumber})!'),
                                                backgroundColor: AppColors.statusActiveText,
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(stayProv.errorMessage ?? 'Không thể nhận phòng.'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Lỗi nhận phòng: $e'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Nhận phòng ngay', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        onCheckOut: () async {
                          try {
                            await context
                                .read<ReservationProvider>()
                                .updateStatus(res.id, 'Đã trả phòng', rowVersion: res.rowVersion);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã hoàn tất trả phòng cho đơn ${res.id}'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi trả phòng: $e'),
                                  backgroundColor: AppColors.statusOccupiedText,
                                ),
                              );
                            }
                          }
                        },
                        onCancel: () {
                          final reasonController = TextEditingController(text: 'Khách yêu cầu hủy');
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xác nhận hủy đặt phòng'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bạn có chắc muốn hủy đơn đặt phòng #${res.id} của khách ${res.guestName}?'),
                                  const SizedBox(height: 12),
                                  const Text('Lý do hủy đơn *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: reasonController,
                                    decoration: const InputDecoration(
                                      hintText: 'Nhập lý do hủy...',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Quay lại'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusOccupiedText),
                                  onPressed: () async {
                                    final reason = reasonController.text.trim();
                                    if (reason.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Vui lòng nhập lý do hủy đặt phòng'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.pop(ctx);
                                    try {
                                      await context.read<ReservationProvider>().updateStatus(
                                            res.numericId.toString(),
                                            'Đã hủy',
                                            rowVersion: res.rowVersion,
                                            reason: reason,
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Đã hủy thành công đơn đặt phòng #${res.id}!'),
                                            backgroundColor: AppColors.statusOccupiedText,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Lỗi hủy phòng: $e'),
                                            backgroundColor: AppColors.statusOccupiedText,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Hủy đơn', style: TextStyle(color: Colors.white)),
                                ),
                              ],
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
