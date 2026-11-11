import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../providers/wallets_overview_provider.dart';

/// Màn hình Thêm tài khoản ngân hàng chuẩn 1:1 theo `device-preview/screens/accounts/add.html`
class CreateAccountScreen extends ConsumerStatefulWidget {
  final String? walletId;

  const CreateAccountScreen({super.key, this.walletId});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final List<Map<String, dynamic>> _banks = [
    {
      'name': 'Vietcombank',
      'app': 'VCB Digibank',
      'color': const Color(0xFF0072D5),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'Techcombank',
      'app': 'TCB Mobile',
      'color': const Color(0xFFEF4444),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'MB Bank',
      'app': 'Quân Đội',
      'color': const Color(0xFF2563EB),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'VPBank',
      'app': 'VPBank NEO',
      'color': const Color(0xFF16A34A),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'MoMo',
      'app': 'Ví điện tử MoMo',
      'color': const Color(0xFFA50064),
      'icon': Icons.smartphone_rounded,
    },
    {
      'name': 'ZaloPay',
      'app': 'Ví điện tử ZaloPay',
      'color': const Color(0xFF0088FF),
      'icon': Icons.smartphone_rounded,
    },
  ];

  void _selectBank(String bankName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Đang kết nối tới $bankName...',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chuyển sang cổng xác thực an toàn chuẩn 256-bit SSL...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.pop(context); // Đóng dialog
        ref.invalidate(walletsOverviewProvider);
        AppToast.success(context, 'Đã liên kết thành công tài khoản $bankName!');
        context.push(RoutePaths.accountDetailWithId('vcb'));
      }
    });
  }

  void _openManualDialog() {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final balCtrl = TextEditingController(text: '1,000,000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Thêm tài khoản thủ công',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên nguồn tiền / Thẻ',
                hintText: 'VD: Thẻ Visa ACB, Tiền tiết kiệm...',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: '4 số cuối tài khoản / thẻ (tùy chọn)',
                hintText: 'VD: 6789',
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: balCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số dư ban đầu (₫)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.invalidate(walletsOverviewProvider);
                AppToast.success(context, 'Đã thêm nguồn tiền thành công!');
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.wallets);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Thêm tài khoản', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context, isDark),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Chọn ngân hàng của bạn để kết nối tự động:',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Grid 2x2 ngân hàng
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.35,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _banks.length,
                      itemBuilder: (context, index) {
                        final bank = _banks[index];
                        return InkWell(
                          onTap: () => _selectBank(bank['name'] as String),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  bank['icon'] as IconData,
                                  color: bank['color'] as Color,
                                  size: 26,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bank['name'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: bank['color'] as Color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bank['app'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Tùy chọn thêm thủ công
                    OutlinedButton.icon(
                      onPressed: _openManualDialog,
                      icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                      label: Text(
                        'Thêm nguồn tiền thủ công',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: AppColors.primary),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.wallets);
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Liên kết Ngân hàng',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
        ],
      ),
    );
  }
}
