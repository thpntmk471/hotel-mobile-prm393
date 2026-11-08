import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await context.read<AuthProvider>().login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
      if (!success && mounted) {
        final error = context.read<AuthProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Đăng nhập thất bại'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      extendBodyBehindAppBar: true,
      // AppBar đặt chữ & logo sắc nét bằng widget chuẩn trên nền banner
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 76,
        titleSpacing: 20,
        title: Row(
          children: [
            // Logo Box "HM" bo góc sắc nét
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E36), // Deep Navy
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'HM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Tên và mô tả hệ thống dạng văn bản nét mịn
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hotel Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hệ thống quản lý khách sạn',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. Banner sảnh khách sạn với chuông và chậu cây (không dính chữ raster)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/login_banner_clean.png',
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // 2. Họa tiết lượn sóng chân trang (không dính chữ raster)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/login_bottom_wave.png',
              width: double.infinity,
              height: 95,
              fit: BoxFit.fill,
            ),
          ),

          // 3. Nội dung form cuộn
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Khoảng cách để Card gối lên đường cong của banner khách sạn
                    const SizedBox(height: 140),

                    // Card Đăng nhập bo góc 24px sang trọng
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag nhỏ phong cách hiện đại
                          const Text(
                            'KHÔNG GIAN LÀM VIỆC',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F766E),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Tiêu đề Đăng nhập
                          const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Mô tả phụ
                          const Text(
                            'Nhập thông tin tài khoản để truy cập hệ thống.',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Trường: Tên đăng nhập
                          const Text(
                            'Tên đăng nhập',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'demo.reception',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14.5,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFF64748B),
                                size: 22,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F6F8),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F766E),
                                  width: 1.4,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D5D51),
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 1.2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập tên đăng nhập'
                                : null,
                          ),
                          const SizedBox(height: 18),

                          // Trường: Mật khẩu
                          const Text(
                            'Mật khẩu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••••••••••••',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14.5,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Color(0xFF64748B),
                                size: 22,
                              ),
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    _obscurePassword ? 'Hiện' : 'Ẩn',
                                    style: const TextStyle(
                                      color: Color(0xFF0F766E),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F6F8),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D5D51),
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 1.2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Vui lòng nhập mật khẩu'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Nút Đăng nhập màu xanh đậm
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D5D51),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Đăng nhập',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Lời nhắn chân thẻ
                          const Center(
                            child: Text(
                              'Sử dụng tài khoản được cấp để đăng nhập.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dòng chữ chân trang duy nhất, sắc nét 100%
                    const SizedBox(height: 28),
                    const Text(
                      'PRN232 Hotel Management',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
