import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/stay_provider.dart';
import 'stay_detail_page.dart';

class StayListPage extends StatefulWidget {
  const StayListPage({super.key});

  @override
  State<StayListPage> createState() => _StayListPageState();
}

class _StayListPageState extends State<StayListPage> {
  final _searchController = TextEditingController();
  final List<String> _statuses = ['Tất cả', 'Đang lưu trú', 'Đã trả phòng'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StayProvider>().fetchStays();
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

  @override
  Widget build(BuildContext context) {
    final stayProvider = context.watch<StayProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lễ tân & Lưu trú'),
      ),
      body: Column(
        children: [
          // Tìm kiếm & Bộ lọc
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => context.read<StayProvider>().setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo mã lưu trú (STY...), tên khách, phòng...',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statuses.map((status) {
                      final isSelected = stayProvider.selectedStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (_) => context.read<StayProvider>().setStatusFilter(status),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách phòng đang lưu trú',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tổng cộng ${stayProvider.stays.length} lượt',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (stayProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (stayProvider.errorMessage != null) {
                  return Center(child: Text(stayProvider.errorMessage!));
                }
                if (stayProvider.stays.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.assignment_outlined,
                    title: 'Chưa có phòng nào đang lưu trú',
                    subtitle:
                        'Các đơn đặt phòng sau khi làm thủ tục Check-in nhận phòng sẽ được theo dõi tại đây.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<StayProvider>().fetchStays(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: stayProvider.stays.length,
                    itemBuilder: (context, index) {
                    final stay = stayProvider.stays[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.white,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Phòng ${stay.roomNumber} • ${stay.stayCode}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: stay.isActive ? AppColors.statusActiveBg : AppColors.statusGrayBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                stay.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: stay.isActive ? AppColors.statusActiveText : AppColors.statusGrayText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text('Khách hàng: ${stay.guestName}', style: const TextStyle(color: AppColors.textPrimary)),
                            Text('Loại phòng: ${stay.roomTypeName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Hóa đơn: ${_formatCurrency(stay.grandTotal)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                const Text('Chi tiết hóa đơn →', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StayDetailPage(stay: stay),
                            ),
                          );
                          if (context.mounted) {
                            context.read<StayProvider>().fetchStays();
                          }
                        },
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
