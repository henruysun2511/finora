import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/balance_card.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/mascot_banner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Top Header (White card container in Light Mode) ──────
                Container(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                  child: Column(
                    children: [
                      // Greeting & Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chào buổi sáng',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                    ),
                                    children: [
                                      TextSpan(text: user?.name.split(' ').first ?? 'Nguyễn'),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                        text: user?.name.split(' ').last ?? 'Văn A',
                                        style: const TextStyle(color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              // Notification Bell Chip
                              GestureDetector(
                                onTap: () => context.push(RoutePaths.notifications),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkBackground : const Color(0xFFF4F6FB),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.notifications_none_rounded,
                                        size: 20,
                                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark ? AppColors.darkSurface : Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Avatar Chip
                              GestureDetector(
                                onTap: () => context.go(RoutePaths.profile),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    (user?.name.isNotEmpty == true) ? user!.name[0] : 'N',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Balance Hero Card
                      const BalanceCard(
                        netWorth: 24850000,
                        monthlyIncome: 15000000,
                        monthlyExpense: 8320000,
                        savingsRate: 44.5,
                        tierTitle: 'Gold Tier',
                        mascotMood: 'HAPPY',
                      ),
                    ],
                  ),
                ),

                // ── 2. Body Content (Soft Gray/Blue background) ─────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mascot AI Insight Banner
                      MascotBanner(
                        name: 'Nora AI',
                        message: 'Bạn đã tiết kiệm được 44.5% thu nhập tháng này, vượt mục tiêu 10%!',
                        actionText: 'Xem chi tiết',
                        onAction: () => context.go(RoutePaths.analytics),
                      ),
                      const SizedBox(height: 20),

                      // Section: Thao tác nhanh (Toàn bộ 16 menu tiện ích)
                      _buildSectionHeader(
                        context,
                        title: 'Thao tác nhanh',
                        actionText: '16 tiện ích',
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 6,
                          childAspectRatio: 0.88,
                          children: [
                            // 1. Thu/Chi thủ công
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.add_circle_outline_rounded,
                              label: 'Thu/Chi',
                              bgColor: const Color(0xFF1E5BD8),
                              onTap: () => context.push(RoutePaths.createTransaction),
                            ),
                            // 2. Quét hóa đơn OCR
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.document_scanner_rounded,
                              label: 'Quét bill',
                              bgColor: const Color(0xFFF97316),
                              onTap: () => context.push(RoutePaths.scanReceipt),
                            ),
                            // 3. Chuyển tiền nội bộ
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.swap_horiz_rounded,
                              label: 'Chuyển ví',
                              bgColor: const Color(0xFF0D9488),
                              onTap: () => context.push(RoutePaths.transfer),
                            ),
                            // 4. Lịch sử giao dịch
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.receipt_long_rounded,
                              label: 'Sổ GD',
                              bgColor: const Color(0xFF3B82F6),
                              onTap: () => context.push(RoutePaths.transactions),
                            ),
                            // 5. Ngân sách chi tiêu
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.calendar_month_rounded,
                              label: 'Ngân sách',
                              bgColor: const Color(0xFF8B5CF6),
                              onTap: () => context.go(RoutePaths.budgets),
                            ),
                            // 6. Báo cáo & Phân tích
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.pie_chart_rounded,
                              label: 'Báo cáo',
                              bgColor: const Color(0xFFEC4899),
                              onTap: () => context.push(RoutePaths.analytics),
                            ),
                            // 7. Giao dịch định kỳ
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.event_repeat_rounded,
                              label: 'Định kỳ',
                              bgColor: const Color(0xFF10B981),
                              onTap: () => context.push(RoutePaths.recurringTransactions),
                            ),
                            // 8. Sổ ghi nợ
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.handshake_rounded,
                              label: 'Sổ nợ',
                              bgColor: const Color(0xFFF59E0B),
                              onTap: () => context.push(RoutePaths.loans),
                            ),
                            // 9. Chia tiền nhóm
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.call_split_rounded,
                              label: 'Chia tiền',
                              bgColor: const Color(0xFF6366F1),
                              onTap: () => context.push(RoutePaths.splitExpenses),
                            ),
                            // 10. Quỹ chung nhóm
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.groups_rounded,
                              label: 'Quỹ chung',
                              bgColor: const Color(0xFF06B6D4),
                              onTap: () => context.push(RoutePaths.sharedWallets),
                            ),
                            // 11. Giao dịch định kỳ
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.event_repeat_rounded,
                              label: 'Định kỳ',
                              bgColor: const Color(0xFF14B8A6),
                              onTap: () => context.push(RoutePaths.recurringTransactions),
                            ),
                            // 12. Danh sách ví
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Ví của tôi',
                              bgColor: const Color(0xFF2563EB),
                              onTap: () => context.push(RoutePaths.wallets),
                            ),
                            // 13. Tỷ giá ngoại tệ
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.currency_exchange_rounded,
                              label: 'Tỷ giá',
                              bgColor: const Color(0xFFD97706),
                              onTap: () => context.push(RoutePaths.exchangeRates),
                            ),
                            // 14. Bảng tin tài chính
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.dynamic_feed_rounded,
                              label: 'Bảng tin',
                              bgColor: const Color(0xFF84CC16),
                              onTap: () => context.push(RoutePaths.socialFeed),
                            ),
                            // 15. Bạn bè & Kết nối
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.person_add_alt_1_rounded,
                              label: 'Bạn bè',
                              bgColor: const Color(0xFF0EA5E9),
                              onTap: () => context.push(RoutePaths.friends),
                            ),
                            // 16. Nora AI Chat
                            _buildQuickActionItem(
                              context: context,
                              isDark: isDark,
                              icon: Icons.smart_toy_rounded,
                              label: 'Nora Chat',
                              bgColor: const Color(0xFFA855F7),
                              onTap: () => context.push(RoutePaths.aiChat),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Section: Tài khoản
                      _buildSectionHeader(
                        context,
                        title: 'Tài khoản',
                        actionText: 'Xem tất cả',
                        onTap: () => context.push(RoutePaths.wallets),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 108,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () => context.push(RoutePaths.wallets),
                              child: _buildAccountCard(
                                isDark: isDark,
                                name: 'Tiền mặt',
                                balance: 2500000,
                                icon: Icons.account_balance_wallet_rounded,
                                chipText: 'Ví tiền mặt',
                                chipColor: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => context.push(RoutePaths.wallets),
                              child: _buildAccountCard(
                                isDark: isDark,
                                name: 'Vietcombank',
                                balance: 18350000,
                                icon: Icons.account_balance_rounded,
                                chipText: 'Tài khoản NH',
                                chipColor: AppColors.primary,
                                isHighlighted: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => context.push(RoutePaths.wallets),
                              child: _buildAccountCard(
                                isDark: isDark,
                                name: 'MoMo',
                                balance: 4000000,
                                icon: Icons.smartphone_rounded,
                                chipText: 'Ví điện tử',
                                chipColor: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Section: Giao dịch gần đây
                      _buildSectionHeader(
                        context,
                        title: 'Giao dịch gần đây',
                        actionText: 'Tất cả',
                        onTap: () => context.push(RoutePaths.transactions),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(AppColors.radiusLg),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildTransactionRow(
                              context: context,
                              isDark: isDark,
                              emoji: '🍜',
                              title: 'Ăn trưa văn phòng',
                              subtitle: 'Ăn uống · Hôm nay 12:30',
                              amount: -55000,
                            ),
                            Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            _buildTransactionRow(
                              context: context,
                              isDark: isDark,
                              emoji: '💰',
                              title: 'Lương tháng 8',
                              subtitle: 'Thu nhập · Hôm qua',
                              amount: 15000000,
                              isIncome: true,
                            ),
                            Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            _buildTransactionRow(
                              context: context,
                              isDark: isDark,
                              emoji: '🛒',
                              title: 'Siêu thị VinMart',
                              subtitle: 'Mua sắm · 08/08',
                              amount: -420000,
                            ),
                            Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            _buildTransactionRow(
                              context: context,
                              isDark: isDark,
                              emoji: '🌐',
                              title: 'Cước Internet',
                              subtitle: 'Hóa đơn · 07/08',
                              amount: -230000,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? actionText,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required bool isDark,
    required String name,
    required double balance,
    required IconData icon,
    required String chipText,
    required Color chipColor,
    bool isHighlighted = false,
  }) {
    return Container(
      width: 154,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1.5,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: chipColor),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CurrencyFormatter.formatCompact(balance),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: chipColor),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      chipText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkMuted : AppColors.lightFaint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow({
    required BuildContext context,
    required bool isDark,
    required String emoji,
    required String title,
    required String subtitle,
    required double amount,
    bool isIncome = false,
  }) {
    return InkWell(
      onTap: () => context.push('${RoutePaths.transactions}/1'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            CategoryIcon(
              icon: emoji,
              size: 40,
              colorHex: isIncome ? '#00B764' : '#0072D5',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkMuted : AppColors.lightFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isIncome ? '+' : ''}${CurrencyFormatter.format(amount)}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isIncome ? AppColors.success : (isDark ? AppColors.darkForeground : AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias để tương thích ngược
typedef DashboardScreen = HomeScreen;
