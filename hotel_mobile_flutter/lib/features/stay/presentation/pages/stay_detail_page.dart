import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/stay.dart';

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
  final bool _isProcessing = false;

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
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onCheckOutSuccess?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thanh toán thành công! Phòng đã được chuyển sang trạng thái Cần dọn.'),
                          backgroundColor: AppColors.statusActiveText,
                        ),
                      );
                      Navigator.pop(context);
                    },
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
                  const SizedBox(height: 6),
                  Text('Loại phòng: ${widget.stay.roomTypeName}', style: const TextStyle(color: AppColors.textSecondary)),
                  Text('Khách hàng: ${widget.stay.guestName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Mã đặt phòng: ${widget.stay.reservationId}', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.login, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Check-in: ${_formatDateTime(widget.stay.checkInTime)}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  if (widget.stay.checkOutTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.logout, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('Check-out: ${_formatDateTime(widget.stay.checkOutTime!)}', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bảng kê chi tiết Hóa đơn (Invoice Lines)
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
                    'Chi tiết các khoản mục (Invoice)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...widget.stay.invoiceLines.map((line) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text('${line.quantity} x ${_formatCurrency(line.unitPrice)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Text(_formatCurrency(line.lineTotal),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tiền phòng:', style: TextStyle(color: AppColors.textSecondary)),
                      Text(_formatCurrency(widget.stay.roomTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dịch vụ phòng (F&B / Spa):', style: TextStyle(color: AppColors.textSecondary)),
                      Text(_formatCurrency(widget.stay.serviceTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TỔNG THANH TOÁN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 24),

            if (widget.stay.isActive) ...[
              CustomButton(
                text: 'Thanh toán & Trả phòng',
                onPressed: () => _showPaymentDialog(context),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.statusActiveBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '✓ Hóa đơn này đã được thanh toán hoàn tất',
                  style: TextStyle(color: AppColors.statusActiveText, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
