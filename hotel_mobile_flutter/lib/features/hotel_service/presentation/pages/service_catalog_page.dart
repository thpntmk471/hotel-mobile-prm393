import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/hotel_service_item.dart';
import '../providers/hotel_service_provider.dart';

class ServiceCatalogPage extends StatefulWidget {
  const ServiceCatalogPage({super.key});

  @override
  State<ServiceCatalogPage> createState() => _ServiceCatalogPageState();
}

class _ServiceCatalogPageState extends State<ServiceCatalogPage> {
  final _searchController = TextEditingController();
  final List<String> _categories = ['Tất cả', 'F&B', 'Laundry', 'Spa', 'Transportation'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelServiceProvider>().fetchServices();
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

  void _showOrderDialog(BuildContext context, HotelServiceItem service) {
    int quantity = 1;
    String roomNumber = 'DEV-101';

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
                      DropdownButton<String>(
                        value: roomNumber,
                        items: ['DEV-101', 'DEV-202', 'DEV-301']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (val) => setModalState(() => roomNumber = val!),
                      ),
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
                            onPressed: quantity < 10 ? () => setModalState(() => quantity++) : null,
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
                    onPressed: () {
                      context.read<HotelServiceProvider>().orderService(
                            stayId: 1,
                            roomNumber: roomNumber,
                            service: service,
                            quantity: quantity,
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã gửi yêu cầu ${service.name} tới phòng $roomNumber!'),
                          backgroundColor: AppColors.statusActiveText,
                        ),
                      );
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menu Dịch Vụ Khách Sạn'),
      ),
      body: Column(
        children: [
          // Tìm kiếm & Danh mục
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => context.read<HotelServiceProvider>().setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm dịch vụ (Buffet, Spa, Giặt là...)...',
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
                    children: _categories.map((cat) {
                      final isSelected = provider.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => context.read<HotelServiceProvider>().setCategoryFilter(cat),
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
                const Text('Danh sách dịch vụ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Có ${provider.services.length} dịch vụ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
                if (provider.services.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.room_service_outlined,
                    title: 'Không tìm thấy dịch vụ nào',
                    subtitle:
                        'Vui lòng thử tìm kiếm với từ khóa khác hoặc chuyển sang danh mục dịch vụ khác.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<HotelServiceProvider>().fetchServices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.services.length,
                    itemBuilder: (context, index) {
                    final s = provider.services[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              s.category == 'F&B'
                                  ? Icons.restaurant
                                  : s.category == 'Spa'
                                      ? Icons.spa
                                      : s.category == 'Laundry'
                                          ? Icons.local_laundry_service
                                          : Icons.directions_car,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(s.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                Text('${_formatCurrency(s.price)} / ${s.unit}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showOrderDialog(context, s),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Gọi món', style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ],
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

