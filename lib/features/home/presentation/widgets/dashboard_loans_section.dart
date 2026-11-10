import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/domain/models/debts_dashboard_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'section_header.dart';

/// Section: Sổ ghi nợ tóm tắt – kết nối trực tiếp GET /dashboard/debts.
class DashboardLoansSection extends ConsumerWidget {
  const DashboardLoansSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final debtsAsync = ref.watch(dashboardDebtsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Sổ ghi nợ & Nghĩa vụ',
          actionText: 'Xem tất cả',
          onTap: () => context.push(RoutePaths.loans),
        ),
        const SizedBox(height: 12),
        debtsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chưa có dữ liệu sổ nợ',
              style: GoogleFonts.inter(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ),
          data: (debts) {
            final netPosition = debts.netDebtPosition;
            final isPositive = netPosition >= 0;

            return Column(
              children: [
                // Hero summary card
                GestureDetector(
                  onTap: () => context.push(RoutePaths.loans),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0F4B92),
                          AppColors.primary,
                          Color(0xFFF5B53F),
                        ],
                        stops: [0.0, 0.55, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          top: -40,
                          right: -30,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'VỊ THẾ NỢ RÒNG',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '${debts.topDebtors.length} khoản',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${isPositive ? '+ ' : '- '}${CurrencyFormatter.format(netPosition.abs())}',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _FrostedBox(
                                    label: 'Cần thu về',
                                    value: CurrencyFormatter.formatCompact(
                                        debts.totalReceivables),
                                    valueColor: const Color(0xFF86EFAC),
                                    icon: Icons.arrow_downward_rounded,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _FrostedBox(
                                    label: 'Phải trả',
                                    value: CurrencyFormatter.formatCompact(
                                        debts.totalPayables),
                                    valueColor: const Color(0xFFFCA5A5),
                                    icon: Icons.arrow_upward_rounded,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _FrostedBox(
                                    label: 'Quá hạn',
                                    value:
                                        '${debts.overdueStats.overduePayableCount + debts.overdueStats.overdueReceivableCount} khoản',
                                    valueColor: (debts.overdueStats
                                                    .overduePayableCount >
                                                0 ||
                                            debts.overdueStats
                                                    .overdueReceivableCount >
                                                0)
                                        ? const Color(0xFFFCA5A5)
                                        : Colors.white,
                                    icon: Icons.warning_amber_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Danh sách người vay/cho vay
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      ...List.generate(debts.topDebtors.length, (index) {
                        final item = debts.topDebtors[index];
                        final isLast = index == debts.topDebtors.length - 1;
                        final isLent = item.type == 'LENT';

                        return Column(
                          children: [
                            _LoanRow(
                              isDark: isDark,
                              name: item.counterpartyName,
                              label: isLent ? 'Cho vay' : 'Vay nợ',
                              dueDate: item.dueDate ?? 'Chưa đặt hạn',
                              amount: item.remainingAmount,
                              isLent: isLent,
                              isOverdue: item.isOverdue,
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                          ],
                        );
                      }),
                      InkWell(
                        onTap: () => context.push(RoutePaths.loans),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(18),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            'Xem tất cả khoản nợ chi tiết →',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FrostedBox extends StatelessWidget {
  const _FrostedBox({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanRow extends StatelessWidget {
  final bool isDark;
  final String name;
  final String label;
  final String dueDate;
  final double amount;
  final bool isLent;
  final bool isOverdue;

  const _LoanRow({
    required this.isDark,
    required this.name,
    required this.label,
    required this.dueDate,
    required this.amount,
    required this.isLent,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isLent ? AppColors.success : AppColors.danger;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: labelColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0] : 'N',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: labelColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: labelColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: labelColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '⚠ Quá hạn',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Hạn: $dueDate',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isLent ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
