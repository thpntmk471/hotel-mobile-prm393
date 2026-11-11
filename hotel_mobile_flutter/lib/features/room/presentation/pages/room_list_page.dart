import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../reservation/presentation/pages/booking_page.dart';
import '../../../room_type/presentation/pages/room_type_list_page.dart';
import '../../../task/presentation/pages/task_list_page.dart';
import '../../domain/entities/room.dart';
import '../providers/room_provider.dart';
import '../widgets/room_card.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final _searchController = TextEditingController();

  final List<String> _roomTypes = ['Tất cả', 'Phòng Standard', 'Phòng Deluxe', 'Phòng Family', 'Phòng VIP Suite'];
  final List<String> _housekeepingStatuses = [
    'Tất cả',
    'Sạch',
    'Cần dọn',
    'Đang dọn',
    'Đã kiểm tra',
  ];

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

  void _showAddEditRoomDialog([Room? room]) {
    final isEdit = room != null;
    final codeCtrl = TextEditingController(text: room?.roomNumber ?? '');
    final floorCtrl = TextEditingController(text: room?.floor.toString() ?? '1');
    final descCtrl = TextEditingController();
    int selectedRoomTypeId = room?.roomTypeId ?? 1;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: Text(
            isEdit ? 'Sửa thông tin phòng' : 'Thêm phòng mới',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Mã phòng (ví dụ: DEV-104)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mã phòng' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: selectedRoomTypeId,
                      decoration: InputDecoration(
                        labelText: 'Loại phòng',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Phòng Standard (1)')),
                        DropdownMenuItem(value: 2, child: Text('Phòng Deluxe (2)')),
                        DropdownMenuItem(value: 3, child: Text('Phòng Family (3)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRoomTypeId = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: floorCtrl,
                      decoration: InputDecoration(
                        labelText: 'Số tầng (1, 2, 3...)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => (int.tryParse(v ?? '') == null) ? 'Số tầng không hợp lệ' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: 'Mô tả thêm',
                        hintText: 'Nhập mô tả thêm về phòng...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final provider = context.read<RoomProvider>();
                  final messenger = ScaffoldMessenger.of(context);
                  bool ok;
                  if (isEdit) {
                    ok = await provider.updateRoom(
                      roomId: room.id,
                      roomCode: codeCtrl.text.trim(),
                      roomTypeId: selectedRoomTypeId,
                      floorNumber: int.parse(floorCtrl.text.trim()),
                      description: descCtrl.text.trim(),
                      rowVersion: room.rowVersion,
                    );
                  } else {
                    ok = await provider.createRoom(
                      roomCode: codeCtrl.text.trim(),
                      roomTypeId: selectedRoomTypeId,
                      floorNumber: int.parse(floorCtrl.text.trim()),
                      description: descCtrl.text.trim(),
                    );
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    if (ok) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(isEdit ? 'Cập nhật phòng thành công!' : 'Thêm phòng mới thành công!'),
                          backgroundColor: AppColors.statusActiveText,
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage ?? 'Thao tác thất bại!'),
                          backgroundColor: AppColors.statusOccupiedText,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(isEdit ? 'Lưu' : 'Thêm mới', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteRoomDialog(Room room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa phòng'),
        content: Text('Bạn có chắc chắn muốn xóa phòng ${room.roomNumber} khỏi hệ thống không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusOccupiedText),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<RoomProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.deleteRoom(room.id);
              if (mounted) {
                if (ok) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa phòng ${room.roomNumber}!'),
                      backgroundColor: AppColors.statusOccupiedText,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Xóa phòng thất bại!'),
                      backgroundColor: AppColors.statusOccupiedText,
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vận hành phòng'),
        actions: [
          IconButton(
            tooltip: 'Nhiệm vụ buồng phòng',
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskListPage()),
              );
            },
          ),
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
                  MaterialPageRoute(builder: (_) => const RoomTypeListPage()),
                );
              },
              icon: const Icon(Icons.category, size: 16),
              label: const Text('Loại phòng', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RoomProvider>().fetchRooms(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm phòng', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditRoomDialog(),
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
                  return const EmptyStateWidget(
                    icon: Icons.meeting_room_outlined,
                    title: 'Không tìm thấy phòng phù hợp',
                    subtitle:
                        'Vui lòng thử tìm kiếm bằng mã phòng khác hoặc thiết lập lại bộ lọc.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<RoomProvider>().fetchRooms(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: roomProvider.rooms.length,
                    itemBuilder: (context, index) {
                      final room = roomProvider.rooms[index];
                      return RoomCard(
                        room: room,
                        onToggleHousekeeping: () async {
                          try {
                            final nextStatus = room.housekeepingStatus == 'Sạch' ? 'Cần dọn' : 'Sạch';
                            await context.read<RoomProvider>().toggleHousekeepingStatus(room);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã cập nhật phòng ${room.roomNumber} sang: $nextStatus',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: AppColors.statusActiveText,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi cập nhật phòng: $e'),
                                  backgroundColor: AppColors.statusOccupiedText,
                                ),
                              );
                            }
                          }
                        },
                        onBookNow: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingPage(initialRoom: room),
                            ),
                          );
                        },
                        onEdit: () => _showAddEditRoomDialog(room),
                        onDelete: () => _showDeleteRoomDialog(room),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

