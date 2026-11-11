import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/audit_log_item.dart';
import '../providers/audit_log_provider.dart';
import 'audit_log_detail_page.dart';

class AuditLogListPage extends StatefulWidget {
  const AuditLogListPage({super.key});

  @override
  State<AuditLogListPage> createState() => _AuditLogListPageState();
}

class _AuditLogListPageState extends State<AuditLogListPage> {
  final _keywordController = TextEditingController();
  final _entityIdController = TextEditingController();
  final _actorIdController = TextEditingController();
  bool _filterExpanded = true;

  final List<String> _commonActions = [
    'Tất cả',
    'TASK_CREATED',
    'TASK_STARTED',
    'TASK_COMPLETED',
    'ROOM_HOUSEKEEPING_STATUS_UPDATED',
    'LOGIN_SUCCESS',
    'LOGIN_FAILED',
    'RESERVATION_CHECKED_IN',
    'STAY_CHECKED_IN',
    'STAY_CHECKED_OUT',
    'INVOICE_DRAFTED',
    'PAYMENT_RECORDED',
  ];

  final List<String> _commonEntityTypes = [
    'Tất cả',
    'HotelTask',
    'Room',
    'Reservation',
    'Stay',
    'Invoice',
    'Payment',
    'Account',
    'AuthSession',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final role = auth.session?.role ?? '';
      final isAdmin = role.toLowerCase().contains('admin');
      if (isAdmin) {
        context.read<AuditLogProvider>().loadLogs(page: 1);
      }
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _entityIdController.dispose();
    _actorIdController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt.toLocal());
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

  Future<void> _pickDateRange(BuildContext context, AuditLogProvider provider) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: (provider.fromDate != null && provider.toDate != null)
          ? DateTimeRange(start: provider.fromDate!, end: provider.toDate!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );
    if (picked != null) {
      provider.setDateRange(picked.start, picked.end.add(const Duration(hours: 23, minutes: 59, seconds: 59)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.session?.role ?? '';
    final isAdmin = role.toLowerCase().contains('admin');

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nhật ký hoạt động')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gpp_bad_outlined, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                const Text(
                  'Quyền truy cập bị từ chối',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tính năng "Nhật ký hoạt động" (Audit Log) chỉ dành riêng cho Quản trị viên (Admin).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final provider = context.watch<AuditLogProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      appBar: AppBar(
        title: const Text('Nhật ký hoạt động'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => provider.loadLogs(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadLogs(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow & Title
              const Text(
                'QUẢN TRỊ HỆ THỐNG',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nhật ký hoạt động',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Tra cứu lịch sử thay đổi và các thao tác được ghi nhận trong hệ thống khách sạn.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              // Success Banner
              if (!provider.isLoading && provider.errorMessage == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AuditAPI HTTP 200; nhận ${provider.items.length} dòng; tổng ${provider.totalCount} bản ghi.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Error Banner
              if (provider.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Filter Card
              _buildFilterCard(context, provider),
              const SizedBox(height: 16),

              // Total count header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Danh sách nhật ký',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Tổng cộng ${provider.totalCount} bản ghi',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // List of Audit Log Items
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.history_toggle_off, size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text(
                        'Không có nhật ký hoạt động nào phù hợp.',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return _buildAuditLogCard(context, item);
                  },
                ),

              const SizedBox(height: 16),

              // Pagination Controls
              if (provider.totalPages > 1) _buildPaginationBar(context, provider),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context, AuditLogProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Tìm kiếm và bộ lọc nâng cao',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(_filterExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _filterExpanded = !_filterExpanded;
                });
              },
            ),
          ),
          if (_filterExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Keyword
                  TextField(
                    controller: _keywordController,
                    decoration: InputDecoration(
                      labelText: 'Từ khóa',
                      hintText: 'Tài khoản, mã, nội dung...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: (val) {
                      provider.setKeyword(val);
                      provider.loadLogs(page: 1);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Action Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: provider.action ?? 'Tất cả',
                    decoration: InputDecoration(
                      labelText: 'Hành động',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: _commonActions.map((a) {
                      return DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      provider.setAction(val == 'Tất cả' ? null : val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Entity Type Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: provider.entityType ?? 'Tất cả',
                    decoration: InputDecoration(
                      labelText: 'Loại đối tượng',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: _commonEntityTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      provider.setEntityType(val == 'Tất cả' ? null : val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date range picker button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      (provider.fromDate != null && provider.toDate != null)
                          ? '${DateFormat('dd/MM/yyyy').format(provider.fromDate!)} - ${DateFormat('dd/MM/yyyy').format(provider.toDate!)}'
                          : 'Chọn khoảng thời gian (Từ ngày - Đến ngày)',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _pickDateRange(context, provider),
                  ),
                  const SizedBox(height: 12),

                  // Page size
                  Row(
                    children: [
                      const Text('Số dòng mỗi trang: ', style: TextStyle(fontSize: 13)),
                      const Spacer(),
                      DropdownButton<int>(
                        value: provider.pageSize,
                        items: const [
                          DropdownMenuItem(value: 10, child: Text('10')),
                          DropdownMenuItem(value: 20, child: Text('20')),
                          DropdownMenuItem(value: 50, child: Text('50')),
                          DropdownMenuItem(value: 100, child: Text('100')),
                        ],
                        onChanged: (val) {
                          if (val != null) provider.setPageSize(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions row: Tìm kiếm & Đặt lại
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _keywordController.clear();
                            _entityIdController.clear();
                            _actorIdController.clear();
                            provider.resetFilters();
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Đặt lại'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('Tìm kiếm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            provider.setKeyword(_keywordController.text);
                            provider.loadLogs(page: 1);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditLogCard(BuildContext context, AuditLogItem item) {
    final actionColor = _getActionColor(item.action);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Time & Actor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(item.occurredAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${item.actorUsernameSnapshot ?? "system"}${item.actorAccountId != null ? " (ID: ${item.actorAccountId})" : ""}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Action badge & Entity
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.action,
                  style: TextStyle(
                    color: actionColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.entityType} ${item.entityCodeSnapshot ?? item.entityId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Summary / Content
          Text(
            item.summary,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Row 4: Chi tiết button
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuditLogDetailPage(item: item),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Chi tiết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(BuildContext context, AuditLogProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: provider.hasPreviousPage
                ? () => provider.loadLogs(page: provider.currentPage - 1)
                : null,
            child: const Text('Trước'),
          ),
          Text(
            'Trang ${provider.currentPage} / ${provider.totalPages}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          OutlinedButton(
            onPressed: provider.hasNextPage
                ? () => provider.loadLogs(page: provider.currentPage + 1)
                : null,
            child: const Text('Sau'),
          ),
        ],
      ),
    );
  }
}
