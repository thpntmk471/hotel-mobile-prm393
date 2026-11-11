import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/room_type.dart';
import '../providers/room_type_provider.dart';

class RoomTypeListPage extends StatefulWidget {
  const RoomTypeListPage({super.key});

  @override
  State<RoomTypeListPage> createState() => _RoomTypeListPageState();
}

class _RoomTypeListPageState extends State<RoomTypeListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomTypeProvider>().fetchRoomTypes();
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

  void _showAddEditDialog([RoomType? roomType]) {
    final isEdit = roomType != null;
    final codeCtrl = TextEditingController(text: roomType?.code ?? '');
    final nameCtrl = TextEditingController(text: roomType?.name ?? '');
    final descCtrl = TextEditingController(text: roomType?.description ?? '');
    final capCtrl = TextEditingController(text: roomType?.capacity.toString() ?? '2');
    final priceCtrl = TextEditingController(text: roomType != null ? roomType.basePricePerNight.toInt().toString() : '500000');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: Text(
          isEdit ? 'Cập nhật loại phòng' : 'Thêm loại phòng mới',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Mã loại phòng (ví dụ: STD, DLX)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mã loại phòng' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tên loại phòng (ví dụ: Deluxe Room)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên loại phòng' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: capCtrl,
                    decoration: InputDecoration(
                      labelText: 'Sức chứa tối đa (người)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') == null || int.parse(v!) <= 0) ? 'Sức chứa phải lớn hơn 0' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: InputDecoration(
                      labelText: 'Giá niêm yết mỗi đêm (VNĐ)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (double.tryParse(v ?? '') == null || double.parse(v!) <= 0) ? 'Giá phải lớn hơn 0' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: 'Mô tả ngắn',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final provider = context.read<RoomTypeProvider>();
                bool ok;
                if (isEdit) {
                  ok = await provider.updateRoomType(
                    id: roomType.id,
                    code: codeCtrl.text.trim(),
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    capacity: int.parse(capCtrl.text.trim()),
                    basePricePerNight: double.parse(priceCtrl.text.trim()),
                    rowVersion: roomType.rowVersion,
                  );
                } else {
                  ok = await provider.createRoomType(
                    code: codeCtrl.text.trim(),
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    capacity: int.parse(capCtrl.text.trim()),
                    basePricePerNight: double.parse(priceCtrl.text.trim()),
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  if (ok) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Cập nhật loại phòng thành công!' : 'Thêm loại phòng thành công!'),
                        backgroundColor: AppColors.statusActiveText,
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ?? 'Thao tác thất bại!'),
                        backgroundColor: AppColors.statusOccupiedText,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(isEdit ? 'Lưu' : 'Thêm mới', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(RoomType rt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa loại phòng'),
        content: Text('Bạn có chắc chắn muốn xóa loại phòng "${rt.name}" (${rt.code}) không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusOccupiedText),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<RoomTypeProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.deleteRoomType(rt.id);
              if (mounted) {
                if (ok) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa loại phòng ${rt.code}!'),
                      backgroundColor: AppColors.statusOccupiedText,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Xóa loại phòng thất bại!'),
                      backgroundColor: AppColors.statusOccupiedText,
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomTypeProvider>();
    final query = _searchController.text.trim().toLowerCase();
    final items = provider.roomTypes.where((rt) {
      if (query.isEmpty) return true;
      return rt.name.toLowerCase().contains(query) || rt.code.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Loại Phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RoomTypeProvider>().fetchRoomTypes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm loại phòng', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditDialog(),
      ),
      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm theo mã (STD, VIP) hoặc tên...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<RoomTypeProvider>().fetchRoomTypes(),
              child: Builder(
                builder: (context) {
                  if (provider.isLoading && provider.roomTypes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage != null && provider.roomTypes.isEmpty) {
                    return Center(child: Text(provider.errorMessage!));
                  }
                  if (items.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.category_outlined,
                      title: 'Chưa có loại phòng nào',
                      subtitle: 'Bấm nút "Thêm loại phòng" bên dưới để thiết lập hạng phòng mới.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final rt = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        rt.code,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      rt.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                      tooltip: 'Sửa',
                                      onPressed: () => _showAddEditDialog(rt),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.statusOccupiedText),
                                      tooltip: 'Xóa',
                                      onPressed: () => _showDeleteDialog(rt),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (rt.description.isNotEmpty) ...[
                              Text(rt.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                            ],
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text('Tối đa: ${rt.capacity} người', style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                                Text(
                                  '${_formatCurrency(rt.basePricePerNight)} / đêm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
