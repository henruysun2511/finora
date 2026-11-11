import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/wallet_detail_provider.dart';

/// Màn hình Chi tiết ví & Tài khoản chuẩn 1:1 theo `device-preview/screens/wallets/detail.html`
class WalletDetailScreen extends ConsumerStatefulWidget {
  final String walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  ConsumerState<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(walletDetailProvider(widget.walletId));
    final walletDetail = detailAsync.valueOrNull;

    // Tên và số dư hiển thị
    final walletName = walletDetail?.wallet.name ?? 'Vietcombank Digital';
    final balance = walletDetail?.balance.availableBalance ?? 14350000.0;
    final currency = walletDetail?.wallet.defaultCurrency ?? 'VND';
    final isMain = walletDetail?.wallet.isShared != true;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: PageHeader.subPage(
        title: walletName,
        subtitle: isMain ? 'Ví cá nhân' : 'Ví dùng chung',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.wallets);
          }
        },
        action: IconButton(
          icon: Icon(
            Icons.tune_rounded,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
          onPressed: () => context.push(RoutePaths.accountDetailWithId(widget.walletId)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ──────────────── 1. BANK CARD HERO ─────────────────────
              _buildBankCardHero(
                walletName: walletName,
                balance: balance,
                currency: currency,
                isMain: isMain,
              ),

              const SizedBox(height: 16),

              // ──────────────── 3. QUICK ACTIONS GRID ─────────────────
              _buildQuickActions(context),

              const SizedBox(height: 20),

              // ──────────────── 4. TRANSACTION HISTORY ────────────────
              _buildTransactionHistory(context, isDark),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  /// Thẻ ngân hàng Bank Card Hero phong cách Solarn FinTech
  Widget _buildBankCardHero({
    required String walletName,
    required double balance,
    required String currency,
    required bool isMain,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0072D5),
            Color(0xFF0055A9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072D5).withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Circular Watermark
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Chip logo + Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        walletName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      isMain ? 'Tài khoản chính' : 'Ví thành viên',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Số dư khả dụng
              Text(
                'SỐ DƯ KHẢ DỤNG',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.format(balance, currency: currency),
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Row: Tên chủ thẻ & 4 số cuối
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHỦ TÀI KHOẢN',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NGUYEN VAN FINORA',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '9876 **** 8899',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3 Nút Quick Actions: Ghi sổ GD, Chuyển tiền, Đồng bộ
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _actionTile(
            icon: Icons.add_rounded,
            label: 'Ghi sổ GD',
            bgColor: const Color(0xFF0072D5).withValues(alpha: 0.12),
            iconColor: const Color(0xFF0072D5),
            onTap: () => context.push(RoutePaths.createTransaction),
          ),
          const SizedBox(width: 12),
          _actionTile(
            icon: Icons.swap_horiz_rounded,
            label: 'Chuyển tiền',
            bgColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
            iconColor: const Color(0xFF0D9488),
            onTap: () => context.push(RoutePaths.transfer),
          ),
          const SizedBox(width: 12),
          _actionTile(
            icon: Icons.sync_rounded,
            label: 'Đồng bộ',
            bgColor: AppColors.success.withValues(alpha: 0.12),
            iconColor: AppColors.success,
            onTap: () {
              AppToast.success(context, 'Đang đồng bộ giao dịch tự động qua Open Banking...');
            },
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lịch sử giao dịch của ví
  Widget _buildTransactionHistory(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch sử giao dịch ví',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RoutePaths.transactions),
                child: Text(
                  'Xem tất cả',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _txItem(
                  icon: Icons.payments_rounded,
                  iconBg: AppColors.success.withValues(alpha: 0.12),
                  iconColor: AppColors.success,
                  title: 'Lương tháng Finora',
                  meta: '17/08 · 16:45',
                  amount: '+₫15,000,000',
                  amountColor: AppColors.success,
                  isDark: isDark,
                  hasBorder: true,
                ),
                _txItem(
                  icon: Icons.shopping_bag_rounded,
                  iconBg: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                  iconColor: const Color(0xFFF43F5E),
                  title: 'Siêu thị WinMart',
                  meta: '15/08 · 19:20',
                  amount: '-₫420,000',
                  amountColor: AppColors.danger,
                  isDark: isDark,
                  hasBorder: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _txItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String meta,
    required String amount,
    required Color amountColor,
    required bool isDark,
    required bool hasBorder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: hasBorder
            ? const Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
