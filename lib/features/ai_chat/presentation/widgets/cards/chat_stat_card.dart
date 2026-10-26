import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';

class ChatStatCard extends StatelessWidget {
  final Map<String, dynamic> payload;

  const ChatStatCard({super.key, required this.payload});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 ₫';
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount).trim();
  }

  IconData _getAccountIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tiền mặt') || lower.contains('cash')) {
      return Icons.payments_outlined;
    } else if (lower.contains('momo') || lower.contains('zalo') || lower.contains('ví')) {
      return Icons.account_balance_wallet_outlined;
    } else if (lower.contains('thẻ') || lower.contains('credit')) {
      return Icons.credit_card_rounded;
    }
    return Icons.account_balance_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCategoryStat = payload.containsKey('categoryName') || payload.containsKey('percentOfExpense');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isCategoryStat
          ? _buildCategoryStatView(context, isDark)
          : _buildWalletBalanceView(context, isDark),
    );
  }

  Widget _buildWalletBalanceView(BuildContext context, bool isDark) {
    final totalBalanceFormatted =
        payload['totalBalanceFormatted'] as String? ?? '0 ₫';
    final accounts = payload['accounts'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SỐ DƯ TÀI KHOẢN VÍ',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${accounts.length} tài khoản',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total Balance Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0072D5), Color(0xFF0055A9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0072D5).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng tài sản khả dụng',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalBalanceFormatted,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Account breakdown list
        ...accounts.map((acc) {
          final name = acc['name']?.toString() ?? 'Tài khoản';
          final balanceFormatted =
              acc['balanceFormatted']?.toString() ?? '0 ₫';
          final icon = _getAccountIcon(name);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: const Color(0xFF0072D5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  balanceFormatted,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryStatView(BuildContext context, bool isDark) {
    final periodLabel = payload['periodLabel'] as String? ?? 'Kỳ này';
    final categoryName = payload['categoryName'] as String? ?? 'Danh mục';
    final totalFormatted = payload['totalFormatted'] as String? ?? '0 ₫';
    final percentOfExpense = payload['percentOfExpense'] as num? ?? 0;
    final transactionCount = payload['transactionCount'] as num? ?? 0;
    final rawBudgets = payload['categoryBudgets'] as List<dynamic>? ?? [];
    final isBudgetHealth = rawBudgets.isNotEmpty;

    final headerTitle = isBudgetHealth ? 'TIẾN ĐỘ NGÂN SÁCH THÁNG' : 'CHI TIẾT DANH MỤC';
    final headerIcon = isBudgetHealth ? Icons.track_changes_rounded : Icons.insights_rounded;
    final headerColor = isBudgetHealth ? const Color(0xFF0072D5) : const Color(0xFFF59E0B);
    final subSubtitle = isBudgetHealth
        ? 'Đã trôi qua $transactionCount ngày trong tháng'
        : 'Đã phát sinh $transactionCount giao dịch';
    final progressLabel = isBudgetHealth
        ? 'Đã dùng $percentOfExpense% ngân sách'
        : 'Chiếm $percentOfExpense% tổng chi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    headerIcon,
                    size: 16,
                    color: headerColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  headerTitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                periodLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              totalFormatted,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar for percent of total expense or budget
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percentOfExpense / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentOfExpense >= 100
                        ? const Color(0xFFEF4444)
                        : percentOfExpense >= 80
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              progressLabel,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: percentOfExpense >= 100
                    ? const Color(0xFFEF4444)
                    : percentOfExpense >= 80
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
              ),
            ),
          ],
        ),

        // Chi tiết từng danh mục ngân sách nếu có (GET_BUDGET_HEALTH)
        if (isBudgetHealth) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(
            'CHI TIẾT TỪNG DANH MỤC NGÂN SÁCH',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          ...rawBudgets.map((b) {
            final catName = b['categoryName']?.toString() ?? 'Danh mục';
            final spentAmount = (b['spentAmount'] as num?)?.toDouble() ?? 0.0;
            final limitAmount = (b['limitAmount'] as num?)?.toDouble() ?? 0.0;
            final spentPct = (b['spentPercentage'] as num?)?.toDouble() ?? 0.0;
            final colorStatus = b['colorStatus']?.toString().toUpperCase() ?? 'GREEN';

            Color statusColor = const Color(0xFF10B981);
            if (colorStatus == 'RED' || spentPct >= 100) {
              statusColor = const Color(0xFFEF4444);
            } else if (colorStatus == 'ORANGE' || spentPct >= 80) {
              statusColor = const Color(0xFFF59E0B);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        catName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      Text(
                        '${spentPct.toStringAsFixed(0)}% · ${_formatCurrency(spentAmount)} / ${_formatCurrency(limitAmount)}',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (spentPct / 100).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
