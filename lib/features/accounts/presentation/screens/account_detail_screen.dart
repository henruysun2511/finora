import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../widgets/adjust_balance_dialog.dart';

/// Màn hình Chi tiết tài khoản & Đồng bộ Open Banking chuẩn 1:1 theo `device-preview/screens/accounts/detail.html`
class AccountDetailScreen extends ConsumerStatefulWidget {
  final String accountId;

  const AccountDetailScreen({super.key, required this.accountId});

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  bool _autoReadTx = true;
  bool _aiNoraCategorize = true;
  bool _isSyncing = false;

  void _openAdjustBalance() {
    showDialog(
      context: context,
      builder: (ctx) => const AdjustBalanceDialog(),
    );
  }

  Future<void> _syncNow() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isSyncing = false);
      AppToast.success(context, 'Đã ép làm mới và tải các giao dịch mới nhất từ Vietcombank!');
    }
  }

  void _confirmUnlink() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hủy liên kết tài khoản?'),
        content: const Text(
          'Dữ liệu giao dịch đã đồng bộ sẽ được giữ lại, nhưng hệ thống sẽ dừng tự động đọc biến động số dư.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppToast.success(context, 'Đã hủy liên kết Open Banking thành công.');
              context.pop();
            },
            child: const Text('HỦY LIÊN KẾT', style: TextStyle(color: AppColors.danger)),
          ),
        ],
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
              // ──────────────── 1. HEADER ────────────────
              _buildHeader(context, isDark),

              // ──────────────── 2. BODY CONTENT ──────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Card: Trạng thái kết nối Open Banking
                    _buildSyncStatusCard(isDark),

                    const SizedBox(height: 16),

                    // Card Tùy chọn cấu hình đồng bộ
                    _buildSettingsCard(isDark),

                    const SizedBox(height: 24),

                    // Nút: Đồng bộ ngay bây giờ
                    ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _syncNow,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.sync_rounded, color: Colors.white),
                      label: Text(
                        _isSyncing ? 'Đang đồng bộ...' : 'Đồng bộ ngay bây giờ',
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

                    const SizedBox(height: 12),

                    // Nút phụ: Điều chỉnh số dư đối soát thực tế
                    OutlinedButton.icon(
                      onPressed: _openAdjustBalance,
                      icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                      label: Text(
                        'Điều chỉnh số dư thực tế',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Nút: Hủy liên kết tài khoản
                    TextButton(
                      onPressed: _confirmUnlink,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Hủy liên kết tài khoản',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.danger,
                        ),
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
            'Đồng bộ Open Banking',
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

  Widget _buildSyncStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Vietcombank API Sync',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kết nối trực tiếp chuẩn bảo mật 256-bit SSL',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Đang kết nối tự động (Real-time)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Row 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tự động đọc biến động số dư',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkForeground : const Color(0xFF334155),
                ),
              ),
              Switch(
                value: _autoReadTx,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _autoReadTx = val),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Row 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Nora tự gán danh mục',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkForeground : const Color(0xFF334155),
                ),
              ),
              Switch(
                value: _aiNoraCategorize,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _aiNoraCategorize = val),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Row 3
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lần đồng bộ cuối',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '12:30 hôm nay',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
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
