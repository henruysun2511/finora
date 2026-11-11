import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';

/// Lưới 12 nút tác vụ nhanh (3 dòng x 4 cột cân đối)
/// Chuẩn thiết kế FinTech SOLARN Style - Tinh giản các mục trùng lặp
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Card bọc lưới 12 tiện ích thiết yếu ──────────────────────────────
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
              // 3. Lịch sử giao dịch
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.receipt_long_rounded,
                label: 'Sổ GD',
                bgColor: const Color(0xFF3B82F6),
                onTap: () => context.push(RoutePaths.transactions),
              ),
              // 4. Ngân sách chi tiêu
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.calendar_month_rounded,
                label: 'Ngân sách',
                bgColor: const Color(0xFF8B5CF6),
                onTap: () => context.go(RoutePaths.budgets),
              ),
              // 5. Báo cáo & Phân tích
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.pie_chart_rounded,
                label: 'Báo cáo',
                bgColor: const Color(0xFFEC4899),
                onTap: () => context.push(RoutePaths.analytics),
              ),
              // 6. Giao dịch định kỳ
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.event_repeat_rounded,
                label: 'Định kỳ',
                bgColor: const Color(0xFF10B981),
                onTap: () => context.push(RoutePaths.recurringTransactions),
              ),
              // 7. Sổ ghi nợ
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.handshake_rounded,
                label: 'Sổ nợ',
                bgColor: const Color(0xFFF59E0B),
                onTap: () => context.push(RoutePaths.loans),
              ),
              // 8. Chia tiền nhóm
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.call_split_rounded,
                label: 'Chia tiền',
                bgColor: const Color(0xFF6366F1),
                onTap: () => context.push(RoutePaths.splitExpenses),
              ),
              // 9. Danh mục thu chi
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.category_rounded,
                label: 'Danh mục',
                bgColor: const Color(0xFF14B8A6),
                onTap: () => context.push(RoutePaths.categorySettings),
              ),
              // 10. Danh sách ví tiền
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.account_balance_wallet_rounded,
                label: 'Ví tiền',
                bgColor: const Color(0xFF2563EB),
                onTap: () => context.go(RoutePaths.wallets),
              ),
              // 11. Tỷ giá ngoại tệ
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.currency_exchange_rounded,
                label: 'Tỷ giá',
                bgColor: const Color(0xFFD97706),
                onTap: () => context.push(RoutePaths.exchangeRates),
              ),
              // 12. Bảng tin tài chính
              _QuickActionItem(
                isDark: isDark,
                icon: Icons.dynamic_feed_rounded,
                label: 'Bảng tin',
                bgColor: const Color(0xFF84CC16),
                onTap: () => context.push(RoutePaths.socialFeed),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: bgColor.withValues(alpha: 0.12),
        highlightColor: bgColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? bgColor.withValues(alpha: 0.22)
                      : bgColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: bgColor.withValues(alpha: isDark ? 0.35 : 0.22),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: isDark
                        ? Color.lerp(bgColor, Colors.white, 0.45)
                        : bgColor,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkForeground
                      : const Color(0xFF1E293B),
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
