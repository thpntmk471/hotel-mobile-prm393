import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/report_provider.dart';

class ReportOverviewPage extends StatefulWidget {
  const ReportOverviewPage({super.key});

  @override
  State<ReportOverviewPage> createState() => _ReportOverviewPageState();
}

class _ReportOverviewPageState extends State<ReportOverviewPage> {
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  final dateFormatter = DateFormat('dd/MM/yyyy');
  final dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final role = auth.session?.role ?? '';
      final isAdmin = role.toLowerCase().contains('admin');
      if (isAdmin) {
        context.read<ReportProvider>().loadReport();
      }
    });
  }

  Future<void> _selectDate(bool isFromDate) async {
    final provider = context.read<ReportProvider>();
    final initialDate = isFromDate ? provider.fromDate : provider.toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (!mounted) return;
    if (picked != null) {
      if (isFromDate) {
        if (picked.isAfter(provider.toDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Từ ngày không được lớn hơn đến ngày.')),
          );
          return;
        }
        provider.loadReport(from: picked);
      } else {
        if (picked.isBefore(provider.fromDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đến ngày không được nhỏ hơn từ ngày.')),
          );
          return;
        }
        provider.loadReport(to: picked);
      }
    }
  }

  String _mapReservationStatus(int code) {
    switch (code) {
      case 1:
        return 'Đã tạo';
      case 2:
        return 'Đã xác nhận';
      case 3:
        return 'Đã nhận phòng';
      case 4:
        return 'Đã trả phòng';
      case 5:
        return 'Đã hủy';
      default:
        return 'Khác ($code)';
    }
  }

  String _mapTaskType(int code) {
    switch (code) {
      case 1:
        return 'Dọn/kiểm tra phòng';
      case 2:
        return 'Bảo trì';
      default:
        return 'Khác ($code)';
    }
  }

  String _mapPaymentMethod(int method) {
    switch (method) {
      case 1:
        return 'Tiền mặt';
      case 2:
        return 'Chuyển khoản';
      case 3:
        return 'Thẻ ngân hàng';
      default:
        return 'Khác ($method)';
    }
  }

  String _mapRoomType(int code) {
    switch (code) {
      case 1:
        return 'Standard (DEV-STD)';
      case 2:
        return 'Deluxe (DEV-DLX)';
      case 3:
        return 'Family (DEV-FAM)';
      default:
        return 'Loại $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.session?.role ?? '';
    final isAdmin = role.toLowerCase().contains('admin');

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Báo cáo tổng hợp')),
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
                  'Tính năng "Báo cáo tổng hợp" chỉ dành riêng cho Quản trị viên (Admin).',
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

    final provider = context.watch<ReportProvider>();
    final report = provider.report;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      appBar: AppBar(
        title: const Text('Báo cáo tổng hợp'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Báo cáo lại hệ thống',
            onPressed: () => provider.loadReport(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadReport(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow & Title
              const Text(
                'QUẢN TRỊ / THỐNG KÊ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Báo cáo tổng hợp',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('Báo cáo lại', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => provider.loadReport(),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Theo dõi hoạt động kinh doanh, tình trạng phòng và công việc vận hành khách sạn.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Date Range Filter Card
              _buildDateFilterCard(context, provider),
              const SizedBox(height: 16),

              // Error Banner
              if (provider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
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

              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (report != null) ...[
                // 4 Top KPI Cards
                _buildKpiGrid(context, report),
                const SizedBox(height: 16),

                // Card 1: Báo cáo phòng
                _buildRoomsCard(report),
                const SizedBox(height: 16),

                // Card 2: Báo cáo đặt phòng
                _buildReservationsCard(report),
                const SizedBox(height: 16),

                // Card 3: Doanh thu thực thu
                _buildRevenueCard(report),
                const SizedBox(height: 16),

                // Card 4: Báo cáo công việc
                _buildTasksCard(report),
                const SizedBox(height: 24),

                // Footer with Generation Timestamp
                Center(
                  child: Text(
                    'Dữ liệu báo cáo được tạo lúc: ${dateTimeFormatter.format(report.generatedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterCard(BuildContext context, ReportProvider provider) {
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
          const Text(
            'Khoảng thời gian báo cáo',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(true),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF8FAFC),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormatter.format(provider.fromDate),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('—', style: TextStyle(color: AppColors.textSecondary)),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF8FAFC),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormatter.format(provider.toDate),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Xem báo cáo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => provider.loadReport(),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => provider.setCurrentMonth(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Tháng hiện tại'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, dynamic report) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildKpiCard(
            title: 'Tổng số phòng',
            value: '${report.rooms.totalRooms}',
            note: 'Hoạt động: ${report.rooms.totalRooms}',
            color: const Color(0xFF176B62),
            width: width,
          ),
          _buildKpiCard(
            title: 'Đặt phòng',
            value: '${report.reservations.totalReservations}',
            note: 'Trong khoảng: ${report.reservations.totalReservations}',
            color: const Color(0xFF3475AB),
            width: width,
          ),
          _buildKpiCard(
            title: 'Doanh thu thực thu',
            value: currencyFormatter.format(report.revenue.totalReceived),
            note: '${report.revenue.paymentCount} giao dịch',
            color: const Color(0xFFCA8842),
            width: width,
          ),
          _buildKpiCard(
            title: 'Tổng công việc',
            value: '${report.tasks.totalTasks}',
            note: 'Đã hoàn thành: ${report.tasks.completedTasks}',
            color: const Color(0xFF7B6FB1),
            width: width,
          ),
        ],
      );
    });
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String note,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent color bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsCard(dynamic report) {
    final rooms = report.rooms;
    final util = (rooms.utilizationPercent as double).clamp(0.0, 100.0);

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
          const Text(
            'Báo cáo phòng',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const Divider(height: 20),

          // 3 Mini stats
          Row(
            children: [
              _buildMiniStatBox('Đang sử dụng', '${rooms.occupiedRoomsNow}'),
              const SizedBox(width: 8),
              _buildMiniStatBox('Trống / sạch', '${rooms.availableRoomsNow}'),
              const SizedBox(width: 8),
              _buildMiniStatBox('Chờ dọn', '${rooms.blockedRoomsNow}'),
            ],
          ),
          const SizedBox(height: 16),

          // Utilization bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Công suất sử dụng', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              Text(
                '${util.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: util / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown by Room Type
          const Text('Phân bổ theo loại phòng', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (rooms.byRoomType.isEmpty)
            const Text('Không có dữ liệu phân bổ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else
            ...rooms.byRoomType.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_mapRoomType(item.code), style: const TextStyle(fontSize: 12.5)),
                    Text('${item.count} phòng', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildReservationsCard(dynamic report) {
    final res = report.reservations;

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
          const Text(
            'Báo cáo đặt phòng',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const Divider(height: 20),

          // 2 Mini stats
          Row(
            children: [
              _buildMiniStatBox('Đã đặt phòng', '${res.totalReservations}'),
              const SizedBox(width: 8),
              _buildMiniStatBox('Khách đã đến', '${res.totalGuestsBooked}'),
            ],
          ),
          const SizedBox(height: 16),

          // Breakdown by Status
          const Text('Thống kê theo trạng thái', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (res.byStatus.isEmpty)
            const Text('Không có dữ liệu trạng thái', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else
            ...res.byStatus.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_mapReservationStatus(item.code), style: const TextStyle(fontSize: 12.5)),
                    Text('${item.count}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(dynamic report) {
    final rev = report.revenue;

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
          const Text(
            'Doanh thu thực thu',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const Divider(height: 20),

          // Big total
          Text(
            currencyFormatter.format(rev.totalReceived),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '${rev.paymentCount} giao dịch thanh toán trong kỳ',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Breakdown by Method
          if (rev.byMethod.isNotEmpty) ...[
            const Text('Phương thức thanh toán', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rev.byMethod.map<Widget>((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '${_mapPaymentMethod(m.method)}: ${currencyFormatter.format(m.amount)} (${m.paymentCount})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Breakdown by Date Table
          const Text('Chi tiết giao dịch theo ngày', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (rev.byDate.isEmpty)
            const Text('Không có giao dịch trong kỳ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else
            ...rev.byDate.map<Widget>((d) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d.date, style: const TextStyle(fontSize: 12.5)),
                    Text(
                      '${d.paymentCount} GD  •  ${currencyFormatter.format(d.amount)}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTasksCard(dynamic report) {
    final tasks = report.tasks;

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
          const Text(
            'Báo cáo công việc',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const Divider(height: 20),

          // 3 Mini stats
          Row(
            children: [
              _buildMiniStatBox('Tổng việc', '${tasks.totalTasks}'),
              const SizedBox(width: 8),
              _buildMiniStatBox('Hoàn thành', '${tasks.completedTasks}'),
              const SizedBox(width: 8),
              _buildMiniStatBox('Chưa giao', '${tasks.unassignedTasks}'),
            ],
          ),
          const SizedBox(height: 16),

          // Breakdown by Task Type
          const Text('Phân loại công việc', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (tasks.byTaskType.isEmpty)
            const Text('Không có dữ liệu phân loại', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else
            ...tasks.byTaskType.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_mapTaskType(item.code), style: const TextStyle(fontSize: 12.5)),
                    Text('${item.count} việc', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildMiniStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
