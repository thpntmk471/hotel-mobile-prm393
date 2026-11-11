import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/guest.dart';
import '../providers/guest_provider.dart';

class GuestListPage extends StatefulWidget {
  const GuestListPage({super.key});

  @override
  State<GuestListPage> createState() => _GuestListPageState();
}

class _GuestListPageState extends State<GuestListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestProvider>().fetchGuests();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditDialog([Guest? guest]) {
    final isEdit = guest != null;
    final nameCtrl = TextEditingController(text: guest?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: guest?.phoneNumber ?? '');
    final emailCtrl = TextEditingController(text: guest?.email ?? '');
    final docCtrl = TextEditingController(text: guest?.documentNumber ?? '');
    final addrCtrl = TextEditingController(text: guest?.address ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Sửa thông tin khách hàng' : 'Thêm khách hàng mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Họ và tên khách hàng *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Số điện thoại *'),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
                    final reg = RegExp(r'^0[3|5|7|8|9][0-9]{8}$');
                    if (!reg.hasMatch(v.trim())) return 'Số điện thoại không hợp lệ (10 số)';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: docCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số CCCD / Hộ chiếu *',
                    hintText: 'Nhập 12 số CCCD hoặc số hộ chiếu',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số CCCD / Hộ chiếu (bắt buộc)';
                    if (v.trim().length < 8) return 'Số CCCD / Hộ chiếu tối thiểu 8 ký tự';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email (tùy chọn)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Địa chỉ thường trú'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final provider = context.read<GuestProvider>();
                final messenger = ScaffoldMessenger.of(context);
                bool ok;
                if (isEdit) {
                  ok = await provider.updateGuest(
                    id: guest.id,
                    fullName: nameCtrl.text.trim(),
                    phoneNumber: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                    documentNumber: docCtrl.text.trim(),
                    address: addrCtrl.text.trim(),
                    rowVersion: guest.rowVersion,
                  );
                } else {
                  final created = await provider.createGuest(
                    fullName: nameCtrl.text.trim(),
                    phoneNumber: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                    documentNumber: docCtrl.text.trim(),
                    address: addrCtrl.text.trim(),
                  );
                  ok = created != null;
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  if (ok) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Cập nhật khách hàng thành công!' : 'Thêm khách hàng thành công!'),
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

  void _showDeleteGuestDialog(Guest guest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa khách hàng'),
        content: Text('Bạn có chắc chắn muốn xóa hồ sơ khách "${guest.fullName}" khỏi hệ thống không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusOccupiedText),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<GuestProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.archiveGuest(guest.id, guest.rowVersion);
              if (mounted) {
                if (ok) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa hồ sơ khách "${guest.fullName}"!'),
                      backgroundColor: AppColors.statusOccupiedText,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Xóa hồ sơ thất bại!'),
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
    final provider = context.watch<GuestProvider>();
    final query = _searchController.text.trim().toLowerCase();
    final items = provider.guests.where((g) {
      if (query.isEmpty) return true;
      return g.fullName.toLowerCase().contains(query) ||
          g.phoneNumber.contains(query) ||
          g.documentNumber.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Khách hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GuestProvider>().fetchGuests(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm khách hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditDialog(),
      ),
      body: Column(
        children: [
          // Tìm kiếm khách hàng
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, SĐT hoặc số CCCD...',
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
              onRefresh: () => context.read<GuestProvider>().fetchGuests(),
              child: Builder(
                builder: (context) {
                  if (provider.isLoading && provider.guests.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage != null && provider.guests.isEmpty) {
                    return Center(child: Text(provider.errorMessage!));
                  }
                  if (items.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.people_outline,
                      title: 'Chưa có thông tin khách hàng nào',
                      subtitle: 'Bấm nút "Thêm khách hàng" bên dưới để đăng ký hồ sơ khách mới.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final guest = items[index];
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
                                Expanded(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.primaryLight,
                                        child: Text(
                                          guest.fullName.isNotEmpty
                                              ? guest.fullName.substring(0, 1).toUpperCase()
                                              : 'G',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              guest.fullName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Mã KH: #${guest.id}',
                                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showAddEditDialog(guest);
                                    } else if (val == 'delete') {
                                      _showDeleteGuestDialog(guest);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                          SizedBox(width: 8),
                                          Text('Sửa thông tin'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 18, color: AppColors.statusOccupiedText),
                                          SizedBox(width: 8),
                                          Text('Xóa hồ sơ', style: TextStyle(color: AppColors.statusOccupiedText)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  guest.phoneNumber.isNotEmpty ? guest.phoneNumber : 'Chưa có SĐT',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const Spacer(),
                                const Icon(Icons.badge_outlined, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'CCCD: ${guest.documentNumber.isNotEmpty ? guest.documentNumber : 'Chưa cập nhật'}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            if (guest.address.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      guest.address,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
