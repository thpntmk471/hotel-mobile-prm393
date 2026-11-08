import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/sticky_bottom_action_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../hotel_service/domain/entities/hotel_service_item.dart';
import '../../../hotel_service/presentation/providers/hotel_service_provider.dart';
import '../../../room/domain/entities/room.dart';
import '../../../room/presentation/providers/room_provider.dart';
import '../../../task/presentation/providers/task_provider.dart';
import '../../domain/entities/stay.dart';
import '../providers/stay_provider.dart';

class StayDetailPage extends StatefulWidget {
  final Stay stay;
  final VoidCallback? onCheckOutSuccess;

  const StayDetailPage({
    super.key,
    required this.stay,
    this.onCheckOutSuccess,
  });

  @override
  State<StayDetailPage> createState() => _StayDetailPageState();
}

class _StayDetailPageState extends State<StayDetailPage> {
  late Stay _stay;
  bool _isLoadingDetail = false;
  bool _isProcessing = false;

  // Thanh toán
  int _paymentMethod = 1; // 1: Tiền mặt, 2: Chuyển khoản, 3: Thẻ
  final _paymentNotesController = TextEditingController();
  final _checkoutNotesController = TextEditingController(text: 'Khách đã thanh toán đủ và trả phòng');

  @override
  void initState() {
    super.initState();
    _stay = widget.stay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStayDetail();
      context.read<HotelServiceProvider>().fetchServices();
    });
  }

  @override
  void dispose() {
    _paymentNotesController.dispose();
    _checkoutNotesController.dispose();
    super.dispose();
  }

  int _getAccountId() {
    final auth = context.read<AuthProvider>();
    return auth.currentUserId;
  }

  Future<void> _loadStayDetail() async {
    setState(() => _isLoadingDetail = true);
    try {
      final detail = await context.read<StayProvider>().getStayById(_stay.id);
      if (detail != null && mounted) {
        setState(() => _stay = detail);
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingDetail = false);
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} • ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  // --- ACTIONS ---

  void _showAddServiceDialog() {
    final hotelServiceProv = context.read<HotelServiceProvider>();
    final services = hotelServiceProv.services;
    HotelServiceItem? selectedService = services.isNotEmpty ? services.first : null;
    int quantity = 1;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final currentServices = context.watch<HotelServiceProvider>().services;
            if (selectedService == null && currentServices.isNotEmpty) {
              selectedService = currentServices.first;
            }

            final unitPrice = selectedService?.price ?? 0;
            final totalPrice = unitPrice * quantity;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thêm dịch vụ phòng',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Chọn dịch vụ *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<HotelServiceItem>(
                    initialValue: selectedService,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: currentServices.map((svc) {
                      return DropdownMenuItem<HotelServiceItem>(
                        value: svc,
                        child: Text(
                          '${svc.name} (${_formatCurrency(svc.price)} / ${svc.unit})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedService = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số lượng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: quantity > 1
                                  ? () => setDialogState(() => quantity--)
                                  : null,
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => setDialogState(() => quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Thành tiền dịch vụ:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          _formatCurrency(totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ghi chú (tùy chọn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập ghi chú...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Ghi nhận dịch vụ',
                    isLoading: _isProcessing,
                    onPressed: selectedService == null
                        ? null
                        : () async {
                            Navigator.pop(ctx);
                            final accountId = _getAccountId();
                            setState(() => _isProcessing = true);
                            try {
                              final ok = await context.read<StayProvider>().addServiceUsage(
                                stayId: _stay.id,
                                hotelServiceId: selectedService!.id,
                                quantity: quantity.toDouble(),
                                accountId: accountId,
                                notes: notesController.text.trim(),
                              );
                              if (ok) {
                                await _loadStayDetail();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã ghi nhận dịch vụ "${selectedService!.name}" x$quantity thành công!'),
                                      backgroundColor: AppColors.statusActiveText,
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.read<StayProvider>().errorMessage ?? 'Không thể thêm dịch vụ.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isProcessing = false);
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

  Future<void> _handleDraftInvoice() async {
    final accountId = _getAccountId();
    setState(() => _isProcessing = true);
    try {
      final res = await context.read<StayProvider>().draftInvoice(_stay.id, accountId);
      if (res != null) {
        await _loadStayDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã lập / tính lại hóa đơn nháp thành công!'),
              backgroundColor: AppColors.statusActiveText,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<StayProvider>().errorMessage ?? 'Lỗi khi lập hóa đơn nháp.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleFinalizeInvoice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chốt hóa đơn'),
        content: const Text(
          'Sau khi chốt hóa đơn, bạn sẽ không thể thêm dịch vụ hoặc tính lại hóa đơn nữa. Bạn có chắc chắn muốn chốt hóa đơn này?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusOccupiedText),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Chốt hóa đơn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final accountId = _getAccountId();
    setState(() => _isProcessing = true);
    try {
      final ok = await context.read<StayProvider>().finalizeInvoice(_stay.id, accountId);
      if (ok) {
        await _loadStayDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã chốt hóa đơn thành công! Bây giờ bạn có thể ghi nhận thanh toán.'),
              backgroundColor: AppColors.statusActiveText,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<StayProvider>().errorMessage ?? 'Không thể chốt hóa đơn.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRecordPayment() async {
    if (_stay.invoiceId == null) return;

    final accountId = _getAccountId();
    final amountToPay = _stay.remainingAmount > 0 ? _stay.remainingAmount : _stay.grandTotal;

    setState(() => _isProcessing = true);
    try {
      final ok = await context.read<StayProvider>().recordPayment(
        invoiceId: _stay.invoiceId!,
        amount: amountToPay,
        method: _paymentMethod,
        accountId: accountId,
        notes: _paymentNotesController.text.trim().isEmpty ? 'Thanh toán tại quầy qua Mobile' : _paymentNotesController.text.trim(),
      );

      if (ok) {
        await _loadStayDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã ghi nhận thanh toán ${_formatCurrency(amountToPay)} thành công!'),
              backgroundColor: AppColors.statusActiveText,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<StayProvider>().errorMessage ?? 'Lỗi ghi nhận thanh toán.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCheckOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận trả phòng'),
        content: Text(
          'Xác nhận khách ${_stay.guestName} trả phòng ${_stay.roomNumber}?\n\n'
          'Hệ thống sẽ cập nhật lượt lưu trú sang "Đã trả phòng", phòng chuyển sang "Cần dọn" và tự động sinh task dọn dẹp cho bộ phận buồng phòng.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Để sau')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận trả phòng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final accountId = _getAccountId();
    final roomProvider = context.read<RoomProvider>();
    final taskProvider = context.read<TaskProvider>();
    final stayProvider = context.read<StayProvider>();

    setState(() => _isProcessing = true);
    try {
      final ok = await stayProvider.checkOut(
        _stay.id,
        accountId,
        notes: _checkoutNotesController.text.trim(),
      );

      if (ok) {
        // Cập nhật trạng thái phòng sang "Cần dọn"
        final room = roomProvider.rooms.firstWhere(
          (r) => r.roomNumber == _stay.roomNumber,
          orElse: () => Room(
            id: 1,
            roomNumber: _stay.roomNumber,
            floor: 1,
            roomTypeId: 1,
            roomTypeName: _stay.roomTypeName,
            pricePerNight: 450000,
            operationalStatus: 'Hoạt động',
            housekeepingStatus: 'Sạch',
          ),
        );

        if (room.id > 0) {
          await roomProvider.setHousekeepingStatus(room.id, 'Cần dọn');
        }

        // Tạo task buồng phòng
        await taskProvider.createCleaningTask(
          roomId: room.id,
          roomNumber: _stay.roomNumber,
          floor: room.floor,
          roomTypeName: _stay.roomTypeName,
          taskType: 'Dọn phòng sau check-out',
          priority: 'Cao',
        );

        await _loadStayDetail();
        widget.onCheckOutSuccess?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Trả phòng thành công! Phòng ${_stay.roomNumber} đã chuyển sang trạng thái "Cần dọn" và kích hoạt Task buồng phòng.',
              ),
              backgroundColor: AppColors.statusActiveText,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<StayProvider>().errorMessage ?? 'Không thể trả phòng.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Tiện ích: Thanh toán nhanh toàn bộ quy trình nếu lễ tân muốn làm 1 chạm
  Future<void> _handleQuickCheckOut() async {
    final accountId = _getAccountId();
    final stayProvider = context.read<StayProvider>();
    setState(() => _isProcessing = true);
    try {
      // 1. Nếu chưa có invoice -> tạo nháp
      if (_stay.invoiceId == null) {
        await stayProvider.draftInvoice(_stay.id, accountId);
        if (!mounted) return;
        await _loadStayDetail();
      }

      // 2. Nếu chưa chốt invoice -> chốt
      if (_stay.invoiceStatus != 2) {
        await stayProvider.finalizeInvoice(_stay.id, accountId);
        if (!mounted) return;
        await _loadStayDetail();
      }

      // 3. Nếu chưa thanh toán đủ -> ghi nhận thanh toán
      if (_stay.remainingAmount > 0 && _stay.invoiceId != null) {
        await stayProvider.recordPayment(
          invoiceId: _stay.invoiceId!,
          amount: _stay.remainingAmount,
          method: _paymentMethod,
          accountId: accountId,
        );
        if (!mounted) return;
        await _loadStayDetail();
      }

      if (!mounted) return;
      // 4. Check out
      await _handleCheckOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi quy trình nhanh: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Lưu trú • ${_stay.stayCode}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _loadStayDetail,
          ),
        ],
      ),
      body: _isLoadingDetail && _stay.invoiceLines.isEmpty && _stay.serviceUsages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStayDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CARD 1: THÔNG TIN LƯU TRÚ ---
                    _buildOverviewCard(),
                    const SizedBox(height: 16),

                    // --- CARD 2: DỊCH VỤ SỬ DỤNG ---
                    _buildServicesCard(),
                    const SizedBox(height: 16),

                    // --- CARD 3: HÓA ĐƠN LƯU TRÚ (INVOICE) ---
                    _buildInvoiceCard(),
                    const SizedBox(height: 16),

                    // --- CARD 4: GHI NHẬN THANH TOÁN (KHI ĐÃ CHỐT VÀ CÒN THIẾU TIỀN) ---
                    if (_stay.isActive && _stay.invoiceStatus == 2 && _stay.remainingAmount > 0) ...[
                      _buildPaymentCard(),
                      const SizedBox(height: 16),
                    ],

                    // --- CARD 5: XÁC NHẬN TRẢ PHÒNG (KHI ĐÃ THANH TOÁN ĐỦ) ---
                    if (_stay.isActive && _stay.invoiceStatus == 2 && (_stay.remainingAmount <= 0 || _stay.isPaid)) ...[
                      _buildCheckOutCard(),
                      const SizedBox(height: 16),
                    ],

                    // THÔNG BÁO HOÀN TẤT NẾU ĐÃ CHECK-OUT
                    if (!_stay.isActive)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.statusActiveBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.statusActiveText.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.statusActiveText),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lượt lưu trú này đã hoàn tất trả phòng lúc ${_stay.checkOutTime != null ? _formatDateTime(_stay.checkOutTime!) : "trước đó"}.',
                                style: const TextStyle(
                                  color: AppColors.statusActiveText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _stay.isActive ? _buildBottomBar() : null,
    );
  }

  // --- WIDGET CARDS ---

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phòng ${_stay.roomNumber}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _stay.isActive ? AppColors.statusActiveBg : AppColors.statusGrayBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _stay.status,
                  style: TextStyle(
                    color: _stay.isActive ? AppColors.statusActiveText : AppColors.statusGrayText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _stay.roomTypeName,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Khách: ${_stay.guestName} ${_stay.guestPhone.isNotEmpty ? "• ${_stay.guestPhone}" : ""}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.login, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Nhận phòng lúc: ${_formatDateTime(_stay.checkInTime)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (_stay.checkOutTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.logout, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Trả phòng lúc: ${_formatDateTime(_stay.checkOutTime!)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.statusActiveText),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesCard() {
    final usages = _stay.serviceUsages;
    final canAdd = _stay.isActive && _stay.invoiceStatus != 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.room_service_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Dịch vụ đã sử dụng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (usages.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${usages.length}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
              if (canAdd)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _showAddServiceDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm dịch vụ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (usages.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text(
                'Chưa ghi nhận dịch vụ nào cho lượt lưu trú này.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: usages.length,
              separatorBuilder: (_, __) => const Divider(height: 14, color: AppColors.border),
              itemBuilder: (context, idx) {
                final u = usages[idx];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.serviceName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(
                            '${u.quantity.toInt()} ${u.unit.isNotEmpty ? u.unit : "suất"} x ${_formatCurrency(u.unitPrice)} • ${_formatDateTime(u.usedAt)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatCurrency(u.totalPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard() {
    final hasInvoice = _stay.invoiceId != null;
    final isFinalized = _stay.invoiceStatus == 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    hasInvoice ? 'Hóa đơn #${_stay.invoiceId}' : 'Hóa đơn lưu trú',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isFinalized
                      ? AppColors.statusActiveBg
                      : (hasInvoice ? AppColors.statusPendingBg : AppColors.statusGrayBg),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isFinalized ? 'Đã chốt' : (hasInvoice ? 'Bản nháp' : 'Chưa lập'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isFinalized
                        ? AppColors.statusActiveText
                        : (hasInvoice ? AppColors.statusPendingText : AppColors.statusGrayText),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!hasInvoice) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Kiểm tra đầy đủ dịch vụ trước khi lập hóa đơn. Sau khi chốt hóa đơn sẽ không thể thêm dịch vụ mới.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 14),
            if (_stay.isActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isProcessing ? null : _handleDraftInvoice,
                  icon: const Icon(Icons.post_add),
                  label: const Text('Lập hóa đơn nháp', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ] else ...[
            // Danh sách các dòng hóa đơn (Lines)
            if (_stay.invoiceLines.isNotEmpty) ...[
              const Text('Chi tiết các khoản mục:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              ..._stay.invoiceLines.map((line) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${line.description} (x${line.quantity})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        _formatCurrency(line.lineTotal),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 16, color: AppColors.border),
            ],

            // Bảng tổng hợp số tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tiền phòng:', style: TextStyle(color: AppColors.textSecondary)),
                Text(_formatCurrency(_stay.roomTotal), style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tiền dịch vụ:', style: TextStyle(color: AppColors.textSecondary)),
                Text(_formatCurrency(_stay.serviceTotal), style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng hóa đơn:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  _formatCurrency(_stay.grandTotal),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Đã thanh toán:', style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  _formatCurrency(_stay.paidAmount),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.statusActiveText),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Còn lại cần thu:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _formatCurrency(_stay.remainingAmount),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _stay.remainingAmount > 0 ? AppColors.error : AppColors.statusActiveText,
                  ),
                ),
              ],
            ),

            // Nút thao tác nháp (Tính lại / Chốt hóa đơn)
            if (_stay.isActive && !isFinalized) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      onPressed: _isProcessing ? null : _handleDraftInvoice,
                      child: const Text('Tính lại hóa đơn', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusPendingText,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      onPressed: _isProcessing ? null : _handleFinalizeInvoice,
                      child: const Text('Chốt hóa đơn', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Ghi nhận thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hóa đơn đã chốt. Số tiền còn lại cần thanh toán: ${_formatCurrency(_stay.remainingAmount)}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Text('Phương thức thanh toán:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildPaymentChoiceChip(1, 'Tiền mặt', Icons.money),
              const SizedBox(width: 8),
              _buildPaymentChoiceChip(2, 'Chuyển khoản', Icons.account_balance),
              const SizedBox(width: 8),
              _buildPaymentChoiceChip(3, 'Thẻ', Icons.credit_card),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paymentNotesController,
            decoration: const InputDecoration(
              hintText: 'Ghi chú thanh toán (Mã GD, số hóa đơn...)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _isProcessing ? null : _handleRecordPayment,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                'Xác nhận thanh toán ${_formatCurrency(_stay.remainingAmount)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChoiceChip(int value, String label, IconData icon) {
    final isSelected = _paymentMethod == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.background,
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckOutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.statusActiveText.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: AppColors.statusActiveText),
              SizedBox(width: 8),
              Text(
                'Sẵn sàng trả phòng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.statusActiveText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Hóa đơn đã được thanh toán đủ. Bạn có thể tiến hành hoàn tất thủ tục trả phòng cho khách.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _checkoutNotesController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú trả phòng',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _isProcessing ? null : _handleCheckOut,
              icon: const Icon(Icons.logout),
              label: const Text('Xác nhận trả phòng', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    // Tự động quyết định nhãn nút và hành động phù hợp nhất với trạng thái hiện tại
    String buttonText = 'Thanh toán & Trả phòng';
    VoidCallback? action = _handleQuickCheckOut;

    if (_stay.invoiceId == null) {
      buttonText = 'Lập hóa đơn nháp';
      action = _handleDraftInvoice;
    } else if (_stay.invoiceStatus != 2) {
      buttonText = 'Chốt hóa đơn';
      action = _handleFinalizeInvoice;
    } else if (_stay.invoiceStatus == 2 && _stay.remainingAmount > 0) {
      buttonText = 'Ghi nhận thanh toán';
      action = _handleRecordPayment;
    } else if (_stay.invoiceStatus == 2 && (_stay.remainingAmount <= 0 || _stay.isPaid)) {
      buttonText = 'Xác nhận trả phòng';
      action = _handleCheckOut;
    }

    return StickyBottomActionBar(
      leading: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng thanh toán',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          Text(
            _formatCurrency(_stay.grandTotal),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      buttonText: buttonText,
      onPressed: _isProcessing ? null : action,
    );
  }
}
