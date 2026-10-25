import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import 'section_header.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Thao tác nhanh',
          actionText: '16 tiện ích',
          onTap: () {},
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
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.add_circle_outline_rounded,
                label: 'Thu/Chi',
                bgColor: const Color(0xFF1E5BD8),
                onTap: () => context.push(RoutePaths.createTransaction),
              ),
              // 2. Quét hóa đơn OCR
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.document_scanner_rounded,
                label: 'Quét bill',
                bgColor: const Color(0xFFF97316),
                onTap: () => context.push(RoutePaths.scanReceipt),
              ),
              // 3. Chuyển tiền nội bộ
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.swap_horiz_rounded,
                label: 'Chuyển ví',
                bgColor: const Color(0xFF0D9488),
                onTap: () => context.push(RoutePaths.transfer),
              ),
              // 4. Lịch sử giao dịch
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.receipt_long_rounded,
                label: 'Sổ GD',
                bgColor: const Color(0xFF3B82F6),
                onTap: () => context.push(RoutePaths.transactions),
              ),
              // 5. Ngân sách chi tiêu
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.calendar_month_rounded,
                label: 'Ngân sách',
                bgColor: const Color(0xFF8B5CF6),
                onTap: () => context.go(RoutePaths.budgets),
              ),
              // 6. Báo cáo & Phân tích
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.pie_chart_rounded,
                label: 'Báo cáo',
                bgColor: const Color(0xFFEC4899),
                onTap: () => context.push(RoutePaths.analytics),
              ),
              // 7. Giao dịch định kỳ
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.event_repeat_rounded,
                label: 'Định kỳ',
                bgColor: const Color(0xFF10B981),
                onTap: () => context.push(RoutePaths.recurringTransactions),
              ),
              // 8. Sổ ghi nợ
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.handshake_rounded,
                label: 'Sổ nợ',
                bgColor: const Color(0xFFF59E0B),
                onTap: () => context.push(RoutePaths.loans),
              ),
              // 9. Chia tiền nhóm
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.call_split_rounded,
                label: 'Chia tiền',
                bgColor: const Color(0xFF6366F1),
                onTap: () => context.push(RoutePaths.splitExpenses),
              ),
              // 10. Quỹ chung nhóm
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.groups_rounded,
                label: 'Quỹ chung',
                bgColor: const Color(0xFF06B6D4),
                onTap: () => context.push(RoutePaths.sharedWallets),
              ),
              // 11. Giao dịch định kỳ
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.event_repeat_rounded,
                label: 'Định kỳ',
                bgColor: const Color(0xFF14B8A6),
                onTap: () => context.push(RoutePaths.recurringTransactions),
              ),
              // 12. Danh sách ví
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.account_balance_wallet_rounded,
                label: 'Ví của tôi',
                bgColor: const Color(0xFF2563EB),
                onTap: () => context.push(RoutePaths.wallets),
              ),
              // 13. Tỷ giá ngoại tệ
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.currency_exchange_rounded,
                label: 'Tỷ giá',
                bgColor: const Color(0xFFD97706),
                onTap: () => context.push(RoutePaths.exchangeRates),
              ),
              // 14. Bảng tin tài chính
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.dynamic_feed_rounded,
                label: 'Bảng tin',
                bgColor: const Color(0xFF84CC16),
                onTap: () => context.push(RoutePaths.socialFeed),
              ),
              // 15. Bạn bè & Kết nối
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.person_add_alt_1_rounded,
                label: 'Bạn bè',
                bgColor: const Color(0xFF0EA5E9),
                onTap: () => context.push(RoutePaths.friends),
              ),
              // 16. Nora AI Chat
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.smart_toy_rounded,
                label: 'Nora Chat',
                bgColor: const Color(0xFFA855F7),
                onTap: () => context.push(RoutePaths.aiChat),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}
