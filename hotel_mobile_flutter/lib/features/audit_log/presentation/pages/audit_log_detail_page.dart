import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/audit_log_item.dart';

class AuditLogDetailPage extends StatelessWidget {
  final AuditLogItem item;

  const AuditLogDetailPage({super.key, required this.item});

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt.toLocal());
  }

  String _prettyJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '(Không có dữ liệu)';
    try {
      final parsed = jsonDecode(raw);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (_) {
      return raw;
    }
  }

  Color _getActionColor(String action) {
    final a = action.toUpperCase();
    if (a.contains('DELETE') || a.contains('CANCEL') || a.contains('FAILED') || a.contains('LOCK')) {
      return AppColors.error;
    }
    if (a.contains('CREATE') || a.contains('SUCCESS') || a.contains('COMPLETED')) {
      return AppColors.success;
    }
    if (a.contains('UPDATE') || a.contains('STATUS') || a.contains('CHECK_IN') || a.contains('CHECK_OUT')) {
      return AppColors.primary;
    }
    return const Color(0xFF6366F1);
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = _getActionColor(item.action);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      appBar: AppBar(
        title: const Text('Chi tiết nhật ký hoạt động'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow & Title
            const Text(
              'QUẢN TRỊ / GIÁM SÁT HỆ THỐNG',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chi tiết nhật ký hoạt động',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Bản ghi #${item.id} — ${_formatDateTime(item.occurredAt)}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Top Summary Card with Badges
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: actionColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: actionColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item.action,
                      style: TextStyle(
                        color: actionColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tài khoản thực hiện:',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          item.actorUsernameSnapshot ?? 'Hệ thống (System)',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Thông tin bản ghi
            _buildSectionCard(
              title: 'Thông tin bản ghi',
              subtitle: 'Các thông tin định danh của thao tác được hệ thống ghi nhận.',
              children: [
                _buildInfoRow('Mã nhật ký', '#${item.id}'),
                _buildInfoRow('Hành động', item.action, valueColor: actionColor),
                _buildInfoRow('Tài khoản thực hiện', item.actorUsernameSnapshot ?? 'Hệ thống'),
                _buildInfoRow('ID tài khoản', item.actorAccountId != null ? '${item.actorAccountId}' : '—'),
                _buildInfoRow('Loại đối tượng', item.entityType),
                _buildInfoRow('ID đối tượng', item.entityId),
                _buildInfoRow('Mã đối tượng', item.entityCodeSnapshot ?? '—'),
              ],
            ),
            const SizedBox(height: 16),

            // Card 2: Thông tin hệ thống
            _buildSectionCard(
              title: 'Thông tin hệ thống',
              subtitle: 'Thời gian và mã phục vụ việc tra vết nhật ký.',
              children: [
                _buildInfoRow('Thời gian', _formatDateTime(item.occurredAt)),
                _buildInfoRow('Correlation ID', item.correlationId ?? '—', isCode: true),
              ],
            ),
            const SizedBox(height: 16),

            // Card 3: Nội dung hoạt động
            _buildSectionCard(
              title: 'Nội dung hoạt động',
              subtitle: 'Tóm tắt thao tác được ghi nhận trong nhật ký.',
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    item.summary,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card 4: Dữ liệu thay đổi (Before / After JSON)
            _buildJsonDiffSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF0F172A),
                fontFamily: isCode ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonDiffSection(BuildContext context) {
    final hasOld = item.oldValuesJson != null && item.oldValuesJson!.trim().isNotEmpty;
    final hasNew = item.newValuesJson != null && item.newValuesJson!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
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
            'Dữ liệu thay đổi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Biến đổi trạng thái trước và sau khi thao tác diễn ra.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Divider(height: 24),

          // Dữ liệu trước thay đổi
          _buildJsonBlock(
            context,
            title: 'Dữ liệu trước thay đổi',
            badgeText: 'Before',
            badgeColor: const Color(0xFFF59E0B),
            jsonText: _prettyJson(item.oldValuesJson),
            isEmpty: !hasOld,
          ),
          const SizedBox(height: 16),

          // Dữ liệu sau thay đổi
          _buildJsonBlock(
            context,
            title: 'Dữ liệu sau thay đổi',
            badgeText: 'After',
            badgeColor: AppColors.success,
            jsonText: _prettyJson(item.newValuesJson),
            isEmpty: !hasNew,
          ),
        ],
      ),
    );
  }

  Widget _buildJsonBlock(
    BuildContext context, {
    required String title,
    required String badgeText,
    required Color badgeColor,
    required String jsonText,
    required bool isEmpty,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
              ),
            ),
            const Spacer(),
            if (!isEmpty)
              IconButton(
                icon: const Icon(Icons.copy, size: 16, color: AppColors.textSecondary),
                tooltip: 'Sao chép JSON',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã sao chép JSON vào clipboard')),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: SelectableText(
            jsonText,
            style: TextStyle(
              fontSize: 11.5,
              fontFamily: 'monospace',
              color: isEmpty ? AppColors.textSecondary : const Color(0xFF334155),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
