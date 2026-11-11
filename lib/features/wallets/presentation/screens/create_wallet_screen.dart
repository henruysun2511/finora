import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/wallets_overview_provider.dart';

/// Màn hình Thêm ví & Nguồn tiền chuẩn 1:1 theo `device-preview/screens/wallets/add.html`
class CreateWalletScreen extends ConsumerStatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  ConsumerState<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends ConsumerState<CreateWalletScreen> {
  int _selectedTypeIndex = 0; // 0: Ngân hàng, 1: Ví điện tử, 2: Tiền mặt, 3: Tiết kiệm
  final _nameController = TextEditingController(text: 'Techcombank Priority');
  final _balanceController = TextEditingController(text: '5,000,000');
  String _selectedCurrency = 'VND (₫) · Việt Nam Đồng';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _types = [
    {
      'icon': Icons.account_balance_rounded,
      'title': 'Tài khoản ngân hàng',
    },
    {
      'icon': Icons.smartphone_rounded,
      'title': 'Ví điện tử',
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'Tiền mặt',
    },
    {
      'icon': Icons.savings_rounded,
      'title': 'Sổ tiết kiệm',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      AppToast.error(context, 'Vui lòng nhập tên ví / tài khoản');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulating API call

    if (mounted) {
      ref.invalidate(walletsOverviewProvider);
      AppToast.success(context, 'Đã thêm nguồn tiền thành công vào danh mục của bạn!');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RoutePaths.wallets);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: PageHeader.subPage(
        title: 'Thêm ví & Nguồn tiền',
        subtitle: 'Khởi tạo ví mới hoặc kết nối ngân hàng',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.wallets);
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ──────────────── BODY FORM ─────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CHỌN LOẠI NGUỒN TIỀN',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Lưới 2x2 các loại nguồn tiền
                    _buildTypePillsGrid(isDark),

                    const SizedBox(height: 16),

                    // Form Group Container
                    _buildFormGroup(isDark),

                    const SizedBox(height: 24),

                    // Nút Tạo nguồn tiền ngay
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_rounded, color: Colors.white),
                      label: Text(
                        _isLoading ? 'Đang tạo...' : 'Tạo nguồn tiền ngay',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypePillsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _types.length,
      itemBuilder: (context, index) {
        final type = _types[index];
        final isSelected = _selectedTypeIndex == index;

        return InkWell(
          onTap: () => setState(() => _selectedTypeIndex = index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : (isDark ? AppColors.darkSurface : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type['title'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormGroup(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Field 1: Tên ví / tài khoản
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TÊN VÍ / TÀI KHOẢN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'VD: MB Bank, Tiền tiêu vặt...',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Field 2: Số dư ban đầu
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SỐ DƯ BAN ĐẦU',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '₫ ',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _balanceController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '0',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Field 3: Đơn vị tiền tệ
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ĐƠN VỊ TIỀN TỆ',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'VND (₫) · Việt Nam Đồng',
                        child: Text('VND (₫) · Việt Nam Đồng'),
                      ),
                      DropdownMenuItem(
                        value: 'USD (\$) · Đô la Mỹ',
                        child: Text('USD (\$) · Đô la Mỹ'),
                      ),
                      DropdownMenuItem(
                        value: 'JPY (¥) · Yên Nhật',
                        child: Text('JPY (¥) · Yên Nhật'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
