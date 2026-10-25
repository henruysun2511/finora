import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/category_icon.dart';
import 'section_header.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
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
              const _TransactionRow(
                emoji: '🍜',
                title: 'Ăn trưa văn phòng',
                subtitle: 'Ăn uống · Hôm nay 12:30',
                amount: -55000,
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              const _TransactionRow(
                emoji: '💰',
                title: 'Lương tháng 8',
                subtitle: 'Thu nhập · Hôm qua',
                amount: 15000000,
                isIncome: true,
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              const _TransactionRow(
                emoji: '🛒',
                title: 'Siêu thị VinMart',
                subtitle: 'Mua sắm · 08/08',
                amount: -420000,
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              const _TransactionRow(
                emoji: '🌐',
                title: 'Cước Internet',
                subtitle: 'Hóa đơn · 07/08',
                amount: -230000,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;

  const _TransactionRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
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
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightFaint,
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
                color: isIncome
                    ? AppColors.success
                    : (isDark ? AppColors.darkForeground : AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
