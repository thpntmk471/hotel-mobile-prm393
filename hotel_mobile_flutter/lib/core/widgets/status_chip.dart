import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String label;

  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.statusGrayBg;
    Color text = AppColors.statusGrayText;

    final lower = label.toLowerCase();
    if (lower.contains('hoạt động') || lower.contains('sạch') || lower.contains('nhận phòng') || lower == 'available') {
      bg = AppColors.statusActiveBg;
      text = AppColors.statusActiveText;
    } else if (lower.contains('cần dọn') || lower.contains('chờ') || lower.contains('cleaning')) {
      bg = AppColors.statusWarningBg;
      text = AppColors.statusWarningText;
    } else if (lower.contains('xác nhận') || lower.contains('confirmed')) {
      bg = AppColors.statusBlueBg;
      text = AppColors.statusBlueText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: text,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

