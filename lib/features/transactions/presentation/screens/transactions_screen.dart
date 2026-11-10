import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/banner_header.dart';
import '../../domain/models/monthly_transaction_summary.dart';
import '../providers/transaction_list_provider.dart';
import '../widgets/daily_transaction_group_card.dart';

/// Màn hình Sổ giao dịch với Hero Banner chuẩn FinTech (`BannerHeader`)
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  Widget _buildBannerContent({
    required BuildContext context,
    required DailyGridNotifier notifier,
    required AsyncValue<MonthlyTransactionSummary> gridAsync,
  }) {
    return gridAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Không tải được thống kê tháng này',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            IconButton(
              tooltip: 'Thử lại',
              onPressed: notifier.refresh,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
      data: (summary) {
        final totalTxCount = summary.days.fold<int>(
          0,
          (acc, day) => acc + day.transactions.length,
        );
        final formattedNet = NumberFormat('#,###', 'vi_VN')
            .format(summary.netAmount.abs().round());
        final formattedIncome = NumberFormat('#,###', 'vi_VN')
            .format(summary.totalIncome.round());
        final formattedExpense = NumberFormat('#,###', 'vi_VN')
            .format(summary.totalExpense.round());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'THẶNG DƯ RÒNG THÁNG',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$totalTxCount giao dịch',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${summary.netAmount >= 0 ? '+' : '-'}₫ $formattedNet',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 2 Ô Thu & Chi kính mờ chuẩn FinTech
            Row(
              children: [
                Expanded(
                  child: _FrostedStatBox(
                    label: 'TỔNG THU',
                    value: '+₫ $formattedIncome',
                    valueColor: const Color(0xFF86EFAC),
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FrostedStatBox(
                    label: 'TỔNG CHI',
                    value: '-₫ $formattedExpense',
                    valueColor: const Color(0xFFFCA5A5),
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(transactionPeriodProvider);
    final gridAsync = ref.watch(dailyGridProvider);
    final notifier = ref.read(dailyGridProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final monthTitle = 'Tháng ${period.month}, ${period.year}';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ── 1. BANNER HEADER MÀU MIDNIGHT SAPPHIRE MỚI ──
          BannerHeader(
            title: 'Sổ giao dịch',
            centerTitle: true,
            showBackButton: true,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.home);
              }
            },
            // Nền banner Midnight Slate & Deep Royal Blue sang trọng
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F172A), // Slate Navy đậm
                Color(0xFF1E293B), // Midnight Blue
                Color(0xFF1E3A8A), // Deep Royal Navy
              ],
              stops: [0.0, 0.45, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // Dấu cộng màu xanh thương hiệu không outline
            action: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push(RoutePaths.createTransaction),
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            child: _buildBannerContent(
              context: context,
              notifier: notifier,
              gridAsync: gridAsync,
            ),
          ),

          // ── 2. BỘ ĐIỀU HƯỚNG THÁNG (ĐẶT DƯỚI BANNER) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: notifier.previousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: foreground,
                    splashRadius: 20,
                    tooltip: 'Tháng trước',
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        monthTitle,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: notifier.nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: foreground,
                    splashRadius: 20,
                    tooltip: 'Tháng sau',
                  ),
                ],
              ),
            ),
          ),

          // ── 3. DANH SÁCH GIAO DỊCH THEO NGÀY ──
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: notifier.refresh,
              child: gridAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Không thể tải sổ giao dịch: $err',
                        style: GoogleFonts.inter(fontSize: 13, color: muted),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: notifier.refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
                data: (summary) {
                  if (summary.days.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 36,
                          ),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: muted.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có giao dịch trong $monthTitle',
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: foreground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nhấn nút dấu (+) ở góc trên để ghi chép khoản thu chi đầu tiên',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: muted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.push(RoutePaths.createTransaction),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(
                                  'Thêm giao dịch',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: summary.days.length,
                    itemBuilder: (context, index) {
                      final group = summary.days[index];
                      return DailyTransactionGroupCard(
                        group: group,
                        onTransactionTap: (tx) {
                          context.push(
                            RoutePaths.transactionDetail
                                .replaceFirst(':id', tx.id),
                            extra: tx,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ thống kê kính mờ hiển thị trong Hero Banner
class _FrostedStatBox extends StatelessWidget {
  const _FrostedStatBox({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: valueColor,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
