import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../loans/presentation/providers/loan_list_provider.dart';
import '../providers/wallet_providers.dart';
import '../providers/wallets_overview_provider.dart';

/// Màn hình Tài khoản & Nguồn tiền (Danh sách ví) chuẩn 1:1 theo `device-preview/screens/wallets/list.html`
/// 100% kết nối API thật, loại bỏ hoàn toàn mock data
class WalletsOverviewScreen extends ConsumerWidget {
  const WalletsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHidden = ref.watch(isBalanceHiddenProvider);
    final overviewAsync = ref.watch(walletsOverviewProvider);

    final dynamicOverview = overviewAsync.valueOrNull;
    final totalNetWorth = dynamicOverview?.totalNetWorth ?? 0.0;

    double calculatedSavings = 0;
    if (dynamicOverview != null) {
      for (final item in dynamicOverview.items) {
        for (final acc in item.accountsPreview) {
          if (acc.name.toLowerCase().contains('tiết kiệm') ||
              acc.name.toLowerCase().contains('saving')) {
            calculatedSavings += acc.balance;
          }
        }
      }
    }
    final totalSavings = calculatedSavings;
    final totalAvailable =
        (totalNetWorth - totalSavings).clamp(0, double.infinity).toDouble();

    final hasRealWallets =
        dynamicOverview != null && dynamicOverview.items.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(walletsOverviewProvider.future);
          ref.invalidate(loanSummaryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ──────────────── 1. ACC-HERO HEADER BANNER ────────────────
              _buildAccHero(
                context,
                ref,
                isHidden,
                totalNetWorth,
                totalSavings,
                totalAvailable,
                currency: dynamicOverview?.defaultCurrency ?? 'VND',
              ),

              // ──────────────── 2. ACC-BODY CONTENT ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (overviewAsync.isLoading && dynamicOverview == null) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ] else if (overviewAsync.hasError && dynamicOverview == null) ...[
                      _buildErrorState(context, isDark, ref),
                    ] else if (!hasRealWallets) ...[
                      _buildEmptyState(context, isDark),
                      const SizedBox(height: 14),
                    ] else ...[
                      for (final item in dynamicOverview.items) ...[
                        _buildDynamicWalletCard(context, isDark, isHidden, item),
                        const SizedBox(height: 14),
                      ],
                    ],

                    // THẺ 4: Net Loans Summary Card (Net Cho vay - Đi vay) từ API
                    _buildNetLoansCard(context, ref, isHidden),

                    const SizedBox(height: 14),

                    // NÚT DASHED: Thêm nguồn tiền mới
                    _buildDashedAddButton(context, isDark),
                  ],
                ),
              ),
            ],
          ),
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
    double totalAvailable, {
    required String currency,
  }) {
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
                      Text(
                        'Tài khoản & Nguồn tiền',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: Colors.white,
                        ),
                      ),
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
                  const SizedBox(height: 22),

                  // Nhãn Tổng tài sản ròng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TỔNG TÀI SẢN RÒNG (NET WORTH)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(isBalanceHiddenProvider.notifier).state =
                              !isHidden;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isHidden
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
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
                    isHidden
                        ? '••••••••'
                        : CurrencyFormatter.format(totalNetWorth,
                            currency: currency),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
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
                                isHidden
                                    ? '••••••'
                                    : CurrencyFormatter.format(totalSavings,
                                        currency: currency),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
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
                                isHidden
                                    ? '••••••'
                                    : CurrencyFormatter.format(totalAvailable,
                                        currency: currency),
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

  /// Trạng thái trống khi chưa có ví nào từ API
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Chưa có nguồn tiền nào',
            style: GoogleFonts.inter(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bắt đầu quản lý tài chính bằng cách tạo ví hoặc liên kết tài khoản ngân hàng của bạn.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => context.push(RoutePaths.createWallet),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Tạo ví đầu tiên',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// Báo lỗi khi mất kết nối mạng
  Widget _buildErrorState(BuildContext context, bool isDark, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(
            'Không thể kết nối tới máy chủ',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vui lòng kiểm tra lại kết nối mạng hoặc thử lại.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(walletsOverviewProvider.future),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ Ví Động kết nối 100% từ Backend API
  Widget _buildDynamicWalletCard(
    BuildContext context,
    bool isDark,
    bool isHidden,
    WalletItemState item,
  ) {
    final wallet = item.wallet;
    final balance = item.balance;
    final accounts = item.accountsPreview;
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
            onTap: () => context.push(RoutePaths.walletDetailWithId(wallet.id)),
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
                    child: Icon(
                      wallet.isShared
                          ? Icons.groups_rounded
                          : (wallet.defaultCurrency == 'USD'
                              ? Icons.flight_takeoff_rounded
                              : Icons.person_rounded),
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
                          wallet.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${wallet.defaultCurrency} · ${accounts.length} tài khoản kết nối',
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
                    isHidden
                        ? '••••••'
                        : CurrencyFormatter.format(balance.totalBalance,
                            currency: wallet.defaultCurrency),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: borderColor),
          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: InkWell(
                onTap: () => context.push('${RoutePaths.createAccount}?walletId=${wallet.id}'),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Thêm tài khoản vào ví này',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...accounts.asMap().entries.map((entry) {
              final idx = entry.key;
              final acc = entry.value;
              final isLast = idx == accounts.length - 1;
              Color dotColor = AppColors.primary;
              IconData icon = Icons.account_balance_rounded;
              if (acc.type.isCash) {
                dotColor = AppColors.success;
                icon = Icons.account_balance_wallet_rounded;
              } else if (acc.type.isEWallet) {
                dotColor = const Color(0xFFA50064);
                icon = Icons.smartphone_rounded;
              }

              return _buildWalletRow(
                context: context,
                dotColor: dotColor,
                icon: icon,
                name: acc.name,
                amount: isHidden
                    ? '••••••'
                    : CurrencyFormatter.format(acc.balance,
                        currency: acc.currency),
                borderColor: borderColor,
                isDark: isDark,
                isLast: isLast,
                onTap: () => context.push(RoutePaths.accountDetailWithId(acc.id)),
              );
            }),
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
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(22))
          : BorderRadius.zero,
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
                  color:
                      isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color:
                    isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Thẻ 4: Net Loans Summary Card (Net Cho vay - Đi vay) 100% từ API
  Widget _buildNetLoansCard(
    BuildContext context,
    WidgetRef ref,
    bool isHidden,
  ) {
    final loanSummaryAsync = ref.watch(loanSummaryProvider);
    final summary = loanSummaryAsync.valueOrNull;

    final net = summary?.netPosition ?? 0.0;
    final lent = summary?.totalLent ?? 0.0;
    final borrowed = (summary?.totalBorrowed ?? 0.0) +
        (summary?.totalInstallment ?? 0.0);

    final isPositive = net >= 0;
    final netPrefix = isPositive ? '+' : '-';

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
                  isHidden
                      ? '••••••'
                      : '$netPrefix${CurrencyFormatter.format(net.abs())}',
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
                  isHidden ? '••••••' : '+${CurrencyFormatter.format(lent)}',
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
                  isHidden ? '••••••' : '-${CurrencyFormatter.format(borrowed)}',
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
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Thêm nguồn tiền mới (Ngân hàng / Ví ĐT / Tiền mặt)',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
