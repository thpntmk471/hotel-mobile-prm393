import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../../stay/presentation/providers/stay_provider.dart';
import '../../domain/entities/hotel_service_item.dart';
import '../providers/hotel_service_provider.dart';

class ServiceCatalogPage extends StatefulWidget {
  const ServiceCatalogPage({super.key});

  @override
  State<ServiceCatalogPage> createState() => _ServiceCatalogPageState();
}

class _ServiceCatalogPageState extends State<ServiceCatalogPage> {
  final _searchController = TextEditingController();
  final List<String> _statusFilters = ['Tất cả', 'Đang phục vụ', 'Tạm ngưng'];
  String _selectedStatusFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelServiceProvider>().fetchServices();
      final stayP = context.read<StayProvider>();
      if (stayP.stays.isEmpty) stayP.fetchStays();
      final roomP = context.read<RoomProvider>();
      if (roomP.rooms.isEmpty) roomP.fetchRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';
  }

  IconData _getServiceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('sáng') || lower.contains('buffet') || lower.contains('ăn') || lower.contains('uống') || lower.contains('cơm') || lower.contains('nước')) {
      return Icons.restaurant;
    }
    if (lower.contains('giặt') || lower.contains('ủi') || lower.contains('laundry')) {
      return Icons.local_laundry_service;
    }
    if (lower.contains('spa') || lower.contains('massage') || lower.contains('thư giãn')) {
      return Icons.spa;
    }
    if (lower.contains('xe') || lower.contains('đón') || lower.contains('tiễn') || lower.contains('transport')) {
      return Icons.directions_car;
    }
    if (lower.contains('dọn') || lower.contains('vệ sinh')) {
      return Icons.cleaning_services;
    }
    return Icons.room_service;
  }

  // --- CRUD: THÊM / SỬA DỊCH VỤ ---
  void _showAddEditServiceDialog([HotelServiceItem? service]) {
    final isEdit = service != null;
    final codeCtrl = TextEditingController(text: service?.serviceCode ?? '');
    final nameCtrl = TextEditingController(text: service?.name ?? '');
    final unitCtrl = TextEditingController(text: service?.unit ?? 'Suất');
    final priceCtrl = TextEditingController(text: service != null ? service.price.toInt().toString() : '50000');
    final descCtrl = TextEditingController(text: service?.description ?? '');
    bool isActive = service?.isAvailable ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Cập nhật dịch vụ' : 'Thêm dịch vụ mới'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mã dịch vụ (ví dụ: DEV-BF, SPA-01) *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mã dịch vụ';
                        if (v.trim().length < 2) return 'Mã dịch vụ tối thiểu 2 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên dịch vụ (ví dụ: Ăn sáng Buffet) *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên dịch vụ' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: unitCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Đơn vị tính *',
                              hintText: 'Suất, Lượt, Chai...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập đơn vị' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: priceCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Đơn giá (VNĐ) *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final p = double.tryParse(v ?? '');
                              if (p == null || p < 0) return 'Đơn giá >= 0';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả chi tiết',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Trạng thái hoạt động', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(
                        isActive ? 'Đang phục vụ khách' : 'Tạm ngưng phục vụ',
                        style: TextStyle(
                          color: isActive ? AppColors.statusActiveText : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      value: isActive,
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    final provider = context.read<HotelServiceProvider>();
                    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                    final code = codeCtrl.text.trim().toUpperCase();
                    final name = nameCtrl.text.trim();
                    final unit = unitCtrl.text.trim();
                    final desc = descCtrl.text.trim();

                    Navigator.pop(ctx);
                    bool success;
                    if (isEdit) {
                      success = await provider.updateService(
                        id: service.id,
                        serviceCode: code,
                        name: name,
                        unit: unit,
                        price: price,
                        rowVersion: service.rowVersion,
                        description: desc,
                        isActive: isActive,
                      );
                    } else {
                      success = await provider.createService(
                        serviceCode: code,
                        name: name,
                        unit: unit,
                        price: price,
                        description: desc,
                        isActive: isActive,
                      );
                    }

                    if (!mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEdit ? 'Đã cập nhật dịch vụ $name!' : 'Đã thêm mới dịch vụ $name!'),
                          backgroundColor: AppColors.statusActiveText,
                        ),
                      );
                    } else {
                      final err = provider.errorMessage ?? 'Thao tác dịch vụ thất bại!';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err), backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
                child: Text(isEdit ? 'Lưu cập nhật' : 'Thêm dịch vụ', style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CRUD: BẬT / TẮT TRẠNG THÁI HOẶC TẠM DỪNG DỊCH VỤ ---
  void _showToggleStatusDialog(HotelServiceItem service) {
    final nextStatus = !service.isAvailable;
    final actionText = nextStatus ? 'Kích hoạt lại' : 'Tạm ngưng phục vụ';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận $actionText'),
        content: Text(
          'Bạn có chắc chắn muốn $actionText cho dịch vụ "${service.name}" (${service.serviceCode})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: nextStatus ? AppColors.primary : AppColors.statusOccupiedText,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<HotelServiceProvider>();
              final success = await provider.toggleServiceStatus(service);

              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã cập nhật trạng thái dịch vụ "${service.name}"!'),
                    backgroundColor: AppColors.statusActiveText,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Không thể cập nhật trạng thái dịch vụ.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(actionText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- GỌI MÓN PHỤC VỤ PHÒNG (ROOM ORDER) ---
  void _showOrderDialog(BuildContext context, HotelServiceItem service) {
    int quantity = 1;
    final stayProvider = context.read<StayProvider>();
    final activeStays = stayProvider.stays.where((s) => s.isActive).toList();
    final roomProvider = context.read<RoomProvider>();
    final allRooms = roomProvider.rooms;

    int selectedStayId = activeStays.isNotEmpty ? activeStays.first.id : 1;
    String selectedRoomNumber = activeStays.isNotEmpty
        ? activeStays.first.roomNumber
        : (allRooms.isNotEmpty ? allRooms.first.roomNumber : 'DEV-101');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final total = service.price * quantity;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gọi dịch vụ: ${service.name}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Đơn giá: ${_formatCurrency(service.price)} / ${service.unit}'),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Chọn phòng phục vụ:', style: TextStyle(fontWeight: FontWeight.w600)),
                      if (activeStays.isNotEmpty)
                        DropdownButton<int>(
                          value: selectedStayId,
                          items: activeStays.map((s) {
                            return DropdownMenuItem<int>(
                              value: s.id,
                              child: Text('Phòng ${s.roomNumber} (${s.guestName})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final matched = activeStays.firstWhere((s) => s.id == val);
                              setModalState(() {
                                selectedStayId = val;
                                selectedRoomNumber = matched.roomNumber;
                              });
                            }
                          },
                        )
                      else if (allRooms.isNotEmpty)
                        DropdownButton<String>(
                          value: selectedRoomNumber,
                          items: allRooms.map((r) {
                            return DropdownMenuItem<String>(
                              value: r.roomNumber,
                              child: Text('Phòng ${r.roomNumber}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedRoomNumber = val);
                            }
                          },
                        )
                      else
                        Text(selectedRoomNumber),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số lượng:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: quantity > 1 ? () => setModalState(() => quantity--) : null,
                          ),
                          Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: quantity < 50 ? () => setModalState(() => quantity++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền dịch vụ:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        _formatCurrency(total),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Gửi yêu cầu phục vụ tận phòng',
                    onPressed: () async {
                      final success = await context.read<HotelServiceProvider>().orderService(
                            stayId: selectedStayId,
                            roomNumber: selectedRoomNumber,
                            service: service,
                            quantity: quantity,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã gửi yêu cầu ${service.name} tới phòng $selectedRoomNumber!'),
                              backgroundColor: AppColors.statusActiveText,
                            ),
                          );
                        } else {
                          final err = context.read<HotelServiceProvider>().errorMessage ?? 'Gọi dịch vụ thất bại!';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: AppColors.statusOccupiedText,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelServiceProvider>();

    // Lọc theo trạng thái
    final filteredServices = provider.services.where((s) {
      if (_selectedStatusFilter == 'Đang phục vụ') return s.isAvailable;
      if (_selectedStatusFilter == 'Tạm ngưng') return !s.isAvailable;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Dịch Vụ Khách Sạn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => context.read<HotelServiceProvider>().fetchServices(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm dịch vụ', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditServiceDialog(),
      ),
      body: Column(
        children: [
          // Tìm kiếm & Bộ lọc
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => context.read<HotelServiceProvider>().setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo mã hoặc tên dịch vụ (Buffet, Spa...)...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
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
                Row(
                  children: _statusFilters.map((st) {
                    final isSelected = _selectedStatusFilter == st;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(st),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedStatusFilter = st;
                          });
                        },
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
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách dịch vụ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Có ${filteredServices.length} dịch vụ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                }
                if (filteredServices.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.room_service_outlined,
                    title: 'Chưa có dịch vụ nào',
                    subtitle: 'Nhấn nút "Thêm dịch vụ" bên dưới để tạo các dịch vụ phục vụ khách lưu trú.',
                    buttonText: 'Thêm dịch vụ mới',
                    onButtonPressed: () => _showAddEditServiceDialog(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<HotelServiceProvider>().fetchServices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final s = filteredServices[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: s.isAvailable ? AppColors.primaryLight : AppColors.statusGrayBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getServiceIcon(s.name),
                                      color: s.isAvailable ? AppColors.primary : AppColors.statusGrayText,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                s.serviceCode,
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: s.isAvailable ? AppColors.statusActiveBg : AppColors.statusGrayBg,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                s.isAvailable ? 'Đang phục vụ' : 'Tạm ngưng',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: s.isAvailable ? AppColors.statusActiveText : AppColors.statusGrayText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          s.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        if (s.description.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            s.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Nút Sửa & Bật/Tắt
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                                        tooltip: 'Sửa dịch vụ',
                                        onPressed: () => _showAddEditServiceDialog(s),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          s.isAvailable ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                          size: 20,
                                          color: s.isAvailable ? AppColors.statusOccupiedText : AppColors.statusActiveText,
                                        ),
                                        tooltip: s.isAvailable ? 'Tạm ngưng phục vụ' : 'Kích hoạt lại',
                                        onPressed: () => _showToggleStatusDialog(s),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 20, color: AppColors.border),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Đơn giá niêm yết:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      Text(
                                        '${_formatCurrency(s.price)} / ${s.unit}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: s.isAvailable ? () => _showOrderDialog(context, s) : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.room_service, size: 15),
                                    label: const Text('Phục vụ phòng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
