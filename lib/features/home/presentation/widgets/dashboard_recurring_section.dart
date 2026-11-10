import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/domain/models/calendar_dashboard_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'section_header.dart';

/// Section: Giao dịch định kỳ & Hóa đơn sắp tới – kết nối GET /dashboard/calendar.
class DashboardRecurringSection extends ConsumerWidget {
  const DashboardRecurringSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calAsync = ref.watch(dashboardCalendarProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Hóa đơn & Định kỳ sắp tới',
          actionText: 'Quản lý',
          onTap: () => context.push(RoutePaths.recurringTransactions),
        ),
        const SizedBox(height: 12),
        calAsync.when(
          loading: () => const SizedBox(
            height: 116,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chưa có dữ liệu hóa đơn',
              style: GoogleFonts.inter(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ),
          data: (cal) {
            final bills = cal.upcomingBillsSummary.bills;
            if (bills.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  'Không có hóa đơn định kỳ nào cần thanh toán trong 30 ngày tới',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              );
            }

            return SizedBox(
              height: 116,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: bills.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final b = bills[index];
                  return GestureDetector(
                    onTap: () => context.push(RoutePaths.recurringTransactions),
                    child: _RecurringCard(
                      isDark: isDark,
                      emoji: '📄',
                      name: b.name,
                      amount: -b.amount,
                      cycle: b.frequency == 'MONTHLY' ? 'Hàng tháng' : 'Định kỳ',
                      nextDate: 'còn ${b.daysRemaining} ngày',
                      color: const Color(0xFF6366F1),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RecurringCard extends StatelessWidget {
  final bool isDark;
  final String emoji;
  final String name;
  final double amount;
  final String cycle;
  final String nextDate;
  final Color color;

  const _RecurringCard({
    required this.isDark,
    required this.emoji,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.nextDate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$cycle · $nextDate',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
