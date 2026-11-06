import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reservation/presentation/pages/booking_page.dart';
import '../providers/room_provider.dart';
import '../widgets/room_card.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final _searchController = TextEditingController();

  final List<String> _roomTypes = ['Tất cả', 'Phòng Standard', 'Phòng Deluxe', 'Phòng VIP Suite'];
  final List<String> _housekeepingStatuses = ['Tất cả', 'Sạch', 'Cần dọn'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().fetchRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vận hành phòng'),
      ),
      body: Column(
        children: [
          // Khối Tìm kiếm & Bộ lọc
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Ô tìm kiếm mã phòng
                TextField(
                  controller: _searchController,
                  onChanged: (val) => context.read<RoomProvider>().setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm mã phòng (ví dụ: DEV-101)...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context.read<RoomProvider>().setSearchQuery('');
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
                const SizedBox(height: 12),

                // Bộ lọc ngang theo Loại phòng
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roomTypes.map((type) {
                      final isSelected = roomProvider.selectedRoomType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (_) =>
                              context.read<RoomProvider>().setRoomTypeFilter(type),
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
                const SizedBox(height: 8),

                // Bộ lọc nhanh theo Tình trạng Buồng phòng
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _housekeepingStatuses.map((status) {
                      final isSelected = roomProvider.selectedHousekeeping == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('Buồng: $status'),
                          selected: isSelected,
                          onSelected: (_) =>
                              context.read<RoomProvider>().setHousekeepingFilter(status),
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

          // Header đếm số phòng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách phòng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tổng cộng ${roomProvider.rooms.length} phòng',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Danh sách hiển thị phòng
          Expanded(
            child: Builder(
              builder: (context) {
                if (roomProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (roomProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(roomProvider.errorMessage!),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context.read<RoomProvider>().fetchRooms(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                if (roomProvider.rooms.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy phòng phù hợp.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: roomProvider.rooms.length,
                  itemBuilder: (context, index) {
                    final room = roomProvider.rooms[index];
                    return RoomCard(
                      room: room,
                      onToggleHousekeeping: () {
                        context.read<RoomProvider>().toggleHousekeepingStatus(room);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã cập nhật phòng ${room.roomNumber} sang: ${room.housekeepingStatus == 'Sạch' ? 'Cần dọn' : 'Sạch'}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onBookNow: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingPage(initialRoom: room),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

