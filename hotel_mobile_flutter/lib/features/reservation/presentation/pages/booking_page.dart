import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/sticky_bottom_action_bar.dart';
import '../../../guest/domain/entities/guest.dart';
import '../../../guest/presentation/providers/guest_provider.dart';
import '../../../room/domain/entities/room.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../domain/entities/reservation.dart';
import '../providers/reservation_provider.dart';

class BookingPage extends StatefulWidget {
  final Room? initialRoom;

  const BookingPage({super.key, this.initialRoom});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idCardController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  int? _selectedGuestId;
  Guest? _selectedGuest;

  // 1. Tiêu chí lọc ngày
  late DateTime _checkInDate;
  late DateTime _checkOutDate;

  // 2. Tiêu chí lọc số người
  int _numberOfGuests = 1;

  // 3. Tiêu chí lọc loại phòng
  String _filterRoomType = 'Tất cả';

  // 4. Tiêu chí lọc tầng (0 = Tất cả tầng)
  int _filterFloor = 0;

  // 5. Tùy chọn chỉ hiện phòng trống trong khoảng ngày đã chọn
  bool _onlyAvailableDates = true;

  // Phòng đang chọn (Dynamic)
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _checkInDate = DateTime(now.year, now.month, now.day);
    _checkOutDate = _checkInDate.add(const Duration(days: 1));

    if (widget.initialRoom != null) {
      _selectedRoom = widget.initialRoom;
      _filterRoomType = widget.initialRoom!.roomTypeName;
      _filterFloor = widget.initialRoom!.floor;
    }

    // Đảm bảo dữ liệu phòng và đặt phòng luôn được nạp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomP = context.read<RoomProvider>();
      if (roomP.rooms.isEmpty) {
        roomP.fetchRooms();
      }
      final resP = context.read<ReservationProvider>();
      if (resP.reservations.isEmpty) {
        resP.fetchReservations();
      }
      final guestP = context.read<GuestProvider>();
      if (guestP.guests.isEmpty) {
        guestP.fetchGuests();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  int get _nights {
    final diff = _checkOutDate.difference(_checkInDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get _totalPrice => (_selectedRoom?.pricePerNight ?? 0) * _nights;

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';
  }

  // Kiểm tra phòng có bị trùng lịch trong khoảng ngày đã chọn không
  bool _isRoomBookedInDateRange(Room room, List<Reservation> reservations) {
    for (final res in reservations) {
      if (res.roomId == room.id && res.status != 'Đã hủy') {
        if (_checkInDate.isBefore(res.checkOutDate) && _checkOutDate.isAfter(res.checkInDate)) {
          return true;
        }
      }
    }
    return false;
  }

  // Lọc danh sách phòng theo ĐẦY ĐỦ 4 TIÊU CHÍ: Ngày, Loại phòng, Tầng, Số người
  List<Room> _getFilteredRooms(List<Room> allRooms, List<Reservation> reservations) {
    return allRooms.where((room) {
      // 1. Lọc theo số người (Sức chứa tối đa của phòng phải >= số khách yêu cầu)
      if (room.maxGuests < _numberOfGuests) {
        return false;
      }

      // 2. Lọc theo loại phòng
      if (_filterRoomType != 'Tất cả' && room.roomTypeName != _filterRoomType) {
        return false;
      }

      // 3. Lọc theo tầng
      if (_filterFloor > 0 && room.floor != _filterFloor) {
        return false;
      }

      // 4. Lọc theo ngày (nếu bật tùy chọn chỉ hiện phòng còn trống)
      if (_onlyAvailableDates) {
        final isBooked = _isRoomBookedInDateRange(room, reservations);
        if (isBooked) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _selectDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final initial = isCheckIn ? _checkInDate : _checkOutDate;
    final first = isCheckIn ? today : _checkInDate.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Business Rule: Ngày Check-out bắt buộc sau ngày Check-in
          if (!_checkOutDate.isAfter(_checkInDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  // Hiển thị Modal Bottom Sheet chọn phòng đã được lọc
  void _showRoomSelectionModal(List<Room> filteredRooms, List<Reservation> reservations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Thanh tiêu đề modal
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chọn phòng phù hợp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tìm thấy ${filteredRooms.length} phòng theo bộ lọc hiện tại',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Danh sách phòng thỏa mãn bộ lọc
              Expanded(
                child: filteredRooms.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Không có phòng nào thỏa mãn bộ lọc',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Đang lọc: $_filterRoomType • Tầng ${_filterFloor == 0 ? "Tất cả" : _filterFloor} • Sức chứa >= $_numberOfGuests khách.\nHãy thử nới lỏng bộ lọc hoặc đổi ngày.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _filterRoomType = 'Tất cả';
                                    _filterFloor = 0;
                                    _onlyAvailableDates = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Đặt lại tất cả bộ lọc'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRooms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final room = filteredRooms[index];
                          final isSelected = _selectedRoom?.id == room.id;
                          final isBooked = _isRoomBookedInDateRange(room, reservations);

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedRoom = room;
                              });
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight.withValues(alpha: 0.4)
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.hotel,
                                      color: isSelected ? Colors.white : AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Phòng ${room.roomNumber}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: room.isClean
                                                    ? AppColors.statusActiveText
                                                        .withValues(alpha: 0.15)
                                                    : AppColors.statusWarningText
                                                        .withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                room.housekeepingStatus,
                                                style: TextStyle(
                                                  color: room.isClean
                                                      ? AppColors.statusActiveText
                                                      : AppColors.statusWarningText,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Text(
                                              '${room.roomTypeName} • Tầng ${room.floor}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.person_outline,
                                                  size: 13,
                                                  color: AppColors.primary,
                                                ),
                                                Text(
                                                  '${room.maxGuests}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (isBooked) ...[
                                          const SizedBox(height: 2),
                                          const Text(
                                            '⚠️ Đang có lịch đặt trùng ngày',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatCurrency(room.pricePerNight),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 20,
                                        )
                                      else
                                        const Text(
                                          'Chọn',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSelectGuestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final guestProvider = context.watch<GuestProvider>();
            final guests = guestProvider.guests;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chọn khách hàng đã có',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên, SĐT hoặc CCCD...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      context.read<GuestProvider>().fetchGuests(keyword: val.trim());
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: guestProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : guests.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    const Text('Không tìm thấy khách hàng nào'),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: guests.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (ctx, idx) {
                                  final g = guests[idx];
                                  final isSelected = g.id == _selectedGuestId;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected ? AppColors.primary : AppColors.primaryLight,
                                      child: Text(
                                        g.fullName.isNotEmpty ? g.fullName[0].toUpperCase() : 'G',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(g.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text('SĐT: ${g.phoneNumber} • CCCD: ${g.documentNumber}'),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                                        : const Icon(Icons.arrow_forward_ios, size: 14),
                                    onTap: () {
                                      setState(() {
                                        _selectedGuestId = g.id;
                                        _selectedGuest = g;
                                        _nameController.text = g.fullName;
                                        _phoneController.text = g.phoneNumber;
                                        _idCardController.text = g.documentNumber;
                                        _emailController.text = g.email;
                                        _addressController.text = g.address;
                                      });
                                      Navigator.pop(modalCtx);
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onSubmit() async {
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một phòng còn trống để đặt'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final resProvider = context.read<ReservationProvider>();
      final guestProvider = context.read<GuestProvider>();
      int? guestId = _selectedGuestId;

      // Nếu chưa chọn khách có sẵn (tức nhập khách mới), tự động lưu khách mới vào hệ thống GuestAPI
      if (guestId == null) {
        final name = _nameController.text.trim();
        final phone = _phoneController.text.trim();
        final docNum = _idCardController.text.trim();
        final email = _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null;
        final address = _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null;

        final newGuest = await guestProvider.createGuest(
          fullName: name,
          phoneNumber: phone,
          email: email,
          documentNumber: docNum,
          address: address,
          notes: 'Được tạo tự động khi đặt phòng',
        );

        if (newGuest != null) {
          guestId = newGuest.id;
        }
      }

      final success = await resProvider.createReservation(
            guestId: guestId,
            guestName: _nameController.text.trim(),
            guestPhone: _phoneController.text.trim(),
            guestIdCard: _idCardController.text.trim(),
            roomId: _selectedRoom!.id,
            roomNumber: _selectedRoom!.roomNumber,
            roomTypeName: _selectedRoom!.roomTypeName,
            pricePerNight: _selectedRoom!.pricePerNight,
            checkInDate: _checkInDate,
            checkOutDate: _checkOutDate,
            numberOfGuests: _numberOfGuests,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt phòng ${_selectedRoom!.roomNumber} thành công!'),
            backgroundColor: AppColors.statusActiveText,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        final err = context.read<ReservationProvider>().errorMessage ?? 'Đặt phòng thất bại. Vui lòng kiểm tra lại thông tin!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: AppColors.statusOccupiedText,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRooms = context.watch<RoomProvider>().rooms;
    final reservations = context.watch<ReservationProvider>().reservations;
    final isSubmitting = context.watch<ReservationProvider>().isLoading;

    // Danh sách phòng được lọc thời gian thực
    final filteredRooms = _getFilteredRooms(allRooms, reservations);

    // Đồng bộ: Nếu chưa chọn phòng hoặc phòng đang chọn không còn thỏa mãn bộ lọc,
    // tự động chuyển sang phòng đầu tiên thỏa mãn bộ lọc!
    if (filteredRooms.isNotEmpty) {
      if (_selectedRoom == null || !filteredRooms.any((r) => r.id == _selectedRoom!.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && filteredRooms.isNotEmpty) {
            setState(() {
              _selectedRoom = filteredRooms.first;
            });
          }
        });
      }
    } else if (filteredRooms.isEmpty && _selectedRoom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedRoom = null;
          });
        }
      });
    }

    // Danh sách các loại phòng có trong khách sạn để tạo chip
    final Set<String> roomTypeOptions = {'Tất cả'};
    for (final r in allRooms) {
      roomTypeOptions.add(r.roomTypeName);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đặt phòng khách sạn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // KHỐI 1: BỘ LỌC TÌM PHÒNG (THEO NGÀY, SỐ NGƯỜI, LOẠI PHÒNG, TẦNG)
              // ==========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tune, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'BỘ LỌC TÌM PHÒNG',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 1. Lọc theo ngày (Check-in & Check-out)
                    const Text(
                      '1. Thời gian lưu trú (Lọc theo ngày)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(isCheckIn: true),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nhận phòng',
                                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(_checkInDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(isCheckIn: false),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Trả phòng',
                                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(_checkOutDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổng thời gian: $_nights đêm',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Lọc theo số người (Capacity)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '2. Số lượng khách (Sức chứa)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lọc phòng chứa >= $_numberOfGuests người',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                iconSize: 18,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                                onPressed: _numberOfGuests > 1
                                    ? () => setState(() => _numberOfGuests--)
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '$_numberOfGuests',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                iconSize: 18,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                                onPressed: _numberOfGuests < 4
                                    ? () => setState(() => _numberOfGuests++)
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 3. Lọc theo loại phòng
                    const Text(
                      '3. Loại phòng',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: roomTypeOptions.map((type) {
                          final isSel = _filterRoomType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: isSel,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _filterRoomType = type;
                                  });
                                }
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Lọc theo tầng
                    const Text(
                      '4. Chọn tầng',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (final floor in [0, 1, 2, 3])
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(floor == 0 ? 'Tất cả tầng' : 'Tầng $floor'),
                              selected: _filterFloor == floor,
                              onSelected: (sel) {
                                if (sel) {
                                  setState(() {
                                    _filterFloor = floor;
                                  });
                                }
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: _filterFloor == floor ? Colors.white : AppColors.textPrimary,
                                fontWeight: _filterFloor == floor ? FontWeight.bold : FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // 5. Tùy chọn lọc phòng trống theo ngày
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _onlyAvailableDates = !_onlyAvailableDates;
                        });
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _onlyAvailableDates,
                              activeColor: AppColors.primary,
                              onChanged: (v) {
                                setState(() {
                                  _onlyAvailableDates = v ?? true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Chỉ hiển thị phòng còn trống trong ngày đã chọn',
                            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // KHỐI 2: Ô CHỌN PHÒNG ĐÃ LỌC (DYNAMIC ROOM SELECTOR)
              // ==========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedRoom != null ? AppColors.primary : AppColors.border,
                    width: _selectedRoom != null ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'PHÒNG ĐÃ CHỌN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${filteredRooms.length} phòng khả dụng',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _showRoomSelectionModal(filteredRooms, reservations),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Xem tất cả phòng',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Thẻ hiển thị phòng đang chọn
                    if (_selectedRoom != null)
                      InkWell(
                        onTap: () => _showRoomSelectionModal(filteredRooms, reservations),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.hotel, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Phòng ${_selectedRoom!.roomNumber}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _selectedRoom!.isClean
                                                ? AppColors.statusActiveText.withValues(alpha: 0.15)
                                                : AppColors.statusWarningText.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _selectedRoom!.housekeepingStatus,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _selectedRoom!.isClean
                                                  ? AppColors.statusActiveText
                                                  : AppColors.statusWarningText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${_selectedRoom!.roomTypeName} • Tầng ${_selectedRoom!.floor} • Sức chứa ${_selectedRoom!.maxGuests} khách',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_formatCurrency(_selectedRoom!.pricePerNight)}/đêm',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Không tìm thấy phòng phù hợp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Không có phòng nào thỏa mãn $_numberOfGuests người, tầng $_filterFloor hoặc loại $_filterRoomType. Hãy bấm nới lỏng bộ lọc ở trên.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Thanh chọn phòng nhanh (Quick Choice Chips)
                    if (filteredRooms.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Chạm để đổi phòng nhanh:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filteredRooms.map((r) {
                            final isSel = _selectedRoom?.id == r.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(r.roomNumber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${_formatCurrency(r.pricePerNight)})',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSel ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                selected: isSel,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _selectedRoom = r;
                                    });
                                  }
                                },
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // KHỐI 3: THÔNG TIN KHÁCH HÀNG
              // ==========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thông tin khách hàng',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => _showSelectGuestModal(context),
                          icon: const Icon(Icons.person_search, size: 18),
                          label: const Text('Chọn khách có sẵn', style: TextStyle(fontSize: 12.5)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedGuestId != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Đã liên kết hồ sơ: ${_selectedGuest?.fullName ?? _nameController.text} (ID: #$_selectedGuestId)',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedGuestId = null;
                                  _selectedGuest = null;
                                  _nameController.clear();
                                  _phoneController.clear();
                                  _idCardController.clear();
                                  _emailController.clear();
                                  _addressController.clear();
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.close, size: 16, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Họ và tên khách hàng *',
                      hintText: 'Nhập họ tên (ví dụ: Nguyễn Văn A)',
                      controller: _nameController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên khách';
                        if (v.trim().length < 2) return 'Họ tên quá ngắn';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Số điện thoại *',
                      hintText: 'Nhập số điện thoại (10 chữ số)',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
                        final reg = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
                        if (!reg.hasMatch(v.trim())) {
                          return 'Số điện thoại không hợp lệ (cần 10 chữ số)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Số CCCD / Hộ chiếu *',
                      hintText: 'Nhập số CCCD (12 chữ số) hoặc hộ chiếu',
                      controller: _idCardController,
                      keyboardType: TextInputType.text,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập số CCCD / Hộ chiếu (bắt buộc)';
                        }
                        if (v.trim().length < 8) {
                          return 'Số CCCD / Hộ chiếu quá ngắn (tối thiểu 8 ký tự)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Email (Tùy chọn)',
                      hintText: 'email@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // KHỐI 4: BẢNG TÍNH TỔNG TIỀN TỰ ĐỘNG
              // ==========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatCurrency(_selectedRoom?.pricePerNight ?? 0)} x $_nights đêm',
                        ),
                        Text(_formatCurrency(_totalPrice)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Phí dịch vụ & VAT (Đã bao gồm)',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          '0 VNĐ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền thanh toán',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatCurrency(_totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StickyBottomActionBar(
        leading: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_nights đêm • ${_selectedRoom?.roomNumber ?? "Chưa chọn"}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              _formatCurrency(_totalPrice),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        buttonText: 'Xác nhận đặt',
        isLoading: isSubmitting,
        onPressed: _selectedRoom == null ? null : _onSubmit,
      ),
    );
  }
}
