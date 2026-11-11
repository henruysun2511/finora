import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/wallet_model.dart';
import '../providers/wallet_providers.dart';
import '../providers/wallets_overview_provider.dart';

/// Màn hình Tài khoản & Nguồn tiền (Danh sách ví) chuẩn 1:1 theo `device-preview/screens/wallets/list.html`
class WalletsOverviewScreen extends ConsumerWidget {
  const WalletsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHidden = ref.watch(isBalanceHiddenProvider);
    final overviewAsync = ref.watch(walletsOverviewProvider);

    // Dữ liệu fallback chuẩn device-preview nếu backend đang tải hoặc trống
    final dynamicOverview = overviewAsync.valueOrNull;
    final totalNetWorth = dynamicOverview?.totalNetWorth ?? 24850000.0;
    final totalSavings = 4000000.0;
    final totalAvailable = dynamicOverview != null
        ? (dynamicOverview.totalNetWorth - totalSavings).clamp(0, double.infinity).toDouble()
        : 20850000.0;

    final wallets = dynamicOverview?.wallets ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ──────────────── 1. ACC-HERO HEADER BANNER ────────────────
            _buildAccHero(context, ref, isHidden, totalNetWorth, totalSavings, totalAvailable),

            // ──────────────── 2. ACC-BODY CONTENT ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // THẺ VÍ 1: Ví Cá nhân (Personal Wallet)
                  _buildPersonalWalletCard(context, isDark, isHidden, wallets),

                  const SizedBox(height: 14),

                  // THẺ VÍ 2: Ví Du lịch & Ngoại tệ (USD Wallet)
                  _buildTravelUsdWalletCard(context, isDark, isHidden, wallets),

                  const SizedBox(height: 14),

                  // THẺ VÍ 3: Ví chung & Quỹ nhóm (Shared Wallets)
                  _buildSharedWalletCard(context, isDark, isHidden, wallets),

                  const SizedBox(height: 14),

                  // THẺ 4: Net Loans Summary Card (Net Cho vay - Đi vay)
                  _buildNetLoansCard(context, isHidden),

                  const SizedBox(height: 14),

                  // NÚT DASHED: Thêm nguồn tiền mới
                  _buildDashedAddButton(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner Hero màu xanh thương hiệu Solarn & vàng kim (#0055A9 -> #0072D5 -> #F5B53F)
  Widget _buildAccHero(
    BuildContext context,
    WidgetRef ref,
    bool isHidden,
    double totalNetWorth,
    double totalSavings,
    double totalAvailable,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0055A9),
            Color(0xFF0072D5),
            Color(0xFFF5B53F),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Circular Watermark
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Nav Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút Quay lại
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RoutePaths.home);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      // Tiêu đề
                      Text(
                        'Tài khoản & Nguồn tiền',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: Colors.white,
                        ),
                      ),

                      // Nút Thêm mới (+)
                      GestureDetector(
                        onTap: () => context.push(RoutePaths.createWallet),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Top row: Label TỔNG TÀI SẢN + Nút Ẩn/Hiện
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TỔNG TÀI SẢN',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(isBalanceHiddenProvider.notifier).state = !isHidden;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isHidden ? 'Hiện' : 'Ẩn',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Số tiền Tổng tài sản ròng
                  Text(
                    isHidden ? '••••••••' : CurrencyFormatter.format(totalNetWorth),
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2 Hộp tóm tắt: Tiết kiệm & Khả dụng
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TIẾT KIỆM',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isHidden ? '••••••' : CurrencyFormatter.format(totalSavings),
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFD1E8FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KHẢ DỤNG',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isHidden ? '••••••' : CurrencyFormatter.format(totalAvailable),
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ Ví 1: Ví Cá nhân (VND · 3 tài khoản kết nối)
  Widget _buildPersonalWalletCard(
    BuildContext context,
    bool isDark,
    bool isHidden,
    List<WalletModel> wallets,
  ) {
    final personalWallet = wallets.cast<WalletModel?>().firstWhere(
          (w) => w?.isShared == false && w?.defaultCurrency == 'VND',
          orElse: () => null,
        );

    final walletId = personalWallet?.id ?? 'personal';
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Ví
          InkWell(
            onTap: () => context.push(RoutePaths.walletDetailWithId(walletId)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          personalWallet?.name ?? 'Ví Cá nhân',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'VND · ${personalWallet?.accountsCount ?? 3} tài khoản kết nối',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isHidden ? '••••••' : '₫20.85M',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Divider(height: 1, color: borderColor),

          // Danh sách dòng tài khoản con
          _buildWalletRow(
            context: context,
            dotColor: AppColors.success,
            icon: Icons.account_balance_wallet_rounded,
            name: 'Tiền mặt',
            amount: isHidden ? '••••••' : '₫2,500,000',
            borderColor: borderColor,
            isDark: isDark,
            onTap: () => context.push(RoutePaths.walletDetailWithId(walletId)),
          ),
          _buildWalletRow(
            context: context,
            dotColor: AppColors.primary,
            icon: Icons.account_balance_rounded,
            name: 'Vietcombank',
            amount: isHidden ? '••••••' : '₫14,350,000',
            borderColor: borderColor,
            isDark: isDark,
            onTap: () => context.push(RoutePaths.walletDetailWithId(walletId)),
          ),
          _buildWalletRow(
            context: context,
            dotColor: const Color(0xFFA50064),
            icon: Icons.smartphone_rounded,
            name: 'MoMo',
            amount: isHidden ? '••••••' : '₫4,000,000',
            borderColor: borderColor,
            isDark: isDark,
            isLast: true,
            onTap: () => context.push(RoutePaths.walletDetailWithId(walletId)),
          ),
        ],
      ),
    );
  }

  /// Thẻ Ví 2: Ví Du lịch & Ngoại tệ (USD · 1 tài khoản)
  Widget _buildTravelUsdWalletCard(
    BuildContext context,
    bool isDark,
    bool isHidden,
    List<WalletModel> wallets,
  ) {
    final usdWallet = wallets.cast<WalletModel?>().firstWhere(
          (w) => w?.defaultCurrency == 'USD',
          orElse: () => null,
        );

    final walletId = usdWallet?.id ?? 'usd';
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => context.push(RoutePaths.walletDetailWithId(walletId)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.flight_takeoff_rounded,
                      color: Color(0xFF0D9488),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usdWallet?.name ?? 'Ví Du lịch & Ngoại tệ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'USD · 1 tài khoản',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isHidden ? '••••••' : '\$160.00',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: borderColor),
          _buildWalletRow(
            context: context,
            dotColor: AppColors.success,
            icon: Icons.account_balance_wallet_rounded,
            name: 'Tiền mặt USD',
            amount: isHidden ? '••••••' : '\$160.00',
            borderColor: borderColor,
            isDark: isDark,
            isLast: true,
            onTap: () => context.push(RoutePaths.walletDetailWithId(walletId)),
          ),
        ],
      ),
    );
  }

  /// Thẻ Ví 3: Ví chung & Quỹ nhóm (Shared Wallets)
  Widget _buildSharedWalletCard(
    BuildContext context,
    bool isDark,
    bool isHidden,
    List<WalletModel> wallets,
  ) {
    final sharedWallet = wallets.cast<WalletModel?>().firstWhere(
          (w) => w?.isShared == true,
          orElse: () => null,
        );

    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: () => context.push(RoutePaths.sharedWallets),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ví chung & Quỹ nhóm',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text(
                                'MỚI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'VND · ${sharedWallet?.memberCount ?? 4} thành viên tham gia',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isHidden ? '••••••' : '₫18.65M',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),

          // Dòng quỹ cụ thể
          InkWell(
            onTap: () => context.push(RoutePaths.sharedWallets),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Text('🌴', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sharedWallet?.name ?? 'Quỹ Du lịch Đà Lạt',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isHidden ? '••••••' : '₫18,650,000',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      const Text(
                        '62.2% mục tiêu',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dòng hiển thị nguồn tiền con bên trong ví
  Widget _buildWalletRow({
    required BuildContext context,
    required Color dotColor,
    required IconData icon,
    required String name,
    required String amount,
    required Color borderColor,
    required bool isDark,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(22)) : BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 9),
            Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Thẻ 4: Net Loans Summary Card (Net Cho vay - Đi vay)
  Widget _buildNetLoansCard(BuildContext context, bool isHidden) {
    return GestureDetector(
      onTap: () => context.push(RoutePaths.loans),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E5BD8),
              Color(0xFF0F3E99),
              Color(0xFFF5B53F),
            ],
            stops: [0.0, 0.6, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E5BD8).withValues(alpha: 0.28),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NET (CHO VAY − ĐI VAY)',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isHidden ? '••••••' : '+₫2,500,000',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Người nợ bạn',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isHidden ? '••••••' : '+₫5,000,000',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6EF0C4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn đang nợ',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isHidden ? '••••••' : '-₫2,500,000',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFF8FAA),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Nút Dashed: Thêm nguồn tiền mới
  Widget _buildDashedAddButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => context.push(RoutePaths.createAccount),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
            width: 1.8,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              'Thêm nguồn tiền mới',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkForeground : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
