import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/sticky_bottom_action_bar.dart';
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
  String _selectedPaymentMethod = 'Tiền mặt';
  bool _isProcessing = false;

  Widget _buildPaymentRadio(String title, StateSetter setModalState) {
    final isSelected = _selectedPaymentMethod == title;
    return InkWell(
      onTap: () => setModalState(() => _selectedPaymentMethod = title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} • ${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _handleCheckOut(BuildContext modalCtx) async {
    final stayProvider = context.read<StayProvider>();
    final roomProvider = context.read<RoomProvider>();
    final taskProvider = context.read<TaskProvider>();

    setState(() => _isProcessing = true);
    try {
      // 1. Thực hiện Check-out & thanh toán trong StayProvider
      await stayProvider.checkOutAndPay(
        widget.stay.id,
        _selectedPaymentMethod,
      );

      // 2. Chuyển trạng thái phòng sang "Cần dọn" (Dirty)
      final room = roomProvider.rooms.firstWhere(
        (r) => r.roomNumber == widget.stay.roomNumber,
        orElse: () => Room(
          id: 1,
          roomNumber: widget.stay.roomNumber,
          floor: 1,
          roomTypeId: 1,
          roomTypeName: widget.stay.roomTypeName,
          pricePerNight: 450000,
          operationalStatus: 'Hoạt động',
          housekeepingStatus: 'Sạch',
        ),
      );

      if (room.id > 0) {
        await roomProvider.setHousekeepingStatus(room.id, 'Cần dọn');
      }

      // 3. Tự động sinh Task dọn phòng mới cho đội ngũ Housekeeping
      await taskProvider.createCleaningTask(
        roomId: room.id,
        roomNumber: widget.stay.roomNumber,
        floor: room.floor,
        roomTypeName: widget.stay.roomTypeName,
        taskType: 'Dọn phòng sau check-out',
        priority: 'Cao',
      );

      if (mounted) {
        Navigator.of(context).pop(); // Đóng modal thanh toán
        widget.onCheckOutSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanh toán thành công! Phòng ${widget.stay.roomNumber} đã chuyển sang trạng thái "Cần dọn" và kích hoạt Task buồng phòng.',
            ),
            backgroundColor: AppColors.statusActiveText,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(); // Quay về danh sách lưu trú
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thanh toán: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showPaymentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Xác nhận thanh toán & Trả phòng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text('Khách hàng: ${widget.stay.guestName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Phòng: ${widget.stay.roomNumber} (${widget.stay.roomTypeName})'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng thanh toán:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          _formatCurrency(widget.stay.grandTotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Chọn phương thức thanh toán:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildPaymentRadio('Tiền mặt', setModalState),
                  _buildPaymentRadio('Chuyển khoản / VNPay', setModalState),
                  _buildPaymentRadio('Thẻ tín dụng', setModalState),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Xác nhận thanh toán & Hoàn tất Check-out',
                    isLoading: _isProcessing,
                    onPressed: _isProcessing ? null : () => _handleCheckOut(ctx),
                  ),
                  const SizedBox(height: 10),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hóa đơn lưu trú • ${widget.stay.stayCode}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin cơ bản
            Container(
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
                        'Phòng ${widget.stay.roomNumber}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.stay.isActive ? AppColors.statusActiveBg : AppColors.statusGrayBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.stay.status,
                          style: TextStyle(
                            color: widget.stay.isActive ? AppColors.statusActiveText : AppColors.statusGrayText,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.stay.roomTypeName,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Khách hàng: ${widget.stay.guestName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Nhận phòng lúc: ${_formatDateTime(widget.stay.checkInTime)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (widget.stay.checkOutTime != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.logout, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Trả phòng lúc: ${_formatDateTime(widget.stay.checkOutTime!)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.statusActiveText),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chi tiết bảng kê dịch vụ & tiền phòng (Folio)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bảng kê chi phí (Hotel Folio)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ...widget.stay.invoiceLines.map((line) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(line.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  '${line.quantity} x ${_formatCurrency(line.unitPrice)}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(line.lineTotal),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 20, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tiền phòng:', style: TextStyle(color: AppColors.textSecondary)),
                      Text(_formatCurrency(widget.stay.roomTotal), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phụ phí dịch vụ:', style: TextStyle(color: AppColors.textSecondary)),
                      Text(_formatCurrency(widget.stay.serviceTotal), style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng hóa đơn:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatCurrency(widget.stay.grandTotal),
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
            const SizedBox(height: 16),

            // Trạng thái thanh toán
            if (widget.stay.isPaid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusActiveBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.statusActiveText.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '✓ Hóa đơn này đã được thanh toán và hoàn tất trả phòng',
                  style: TextStyle(
                    color: AppColors.statusActiveText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: widget.stay.isActive
          ? StickyBottomActionBar(
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng tiền hóa đơn',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Text(
                    _formatCurrency(widget.stay.grandTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              buttonText: 'Thanh toán & Trả phòng',
              onPressed: () => _showPaymentDialog(context),
            )
          : null,
    );
  }
}
