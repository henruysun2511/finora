import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/budget_enums.dart';
import '../providers/budget_detail_provider.dart';
import '../providers/budget_list_provider.dart';
import '../widgets/budget_history_list.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/smart_daily_budget_card.dart';

class BudgetDetailScreen extends ConsumerWidget {
  const BudgetDetailScreen({
    super.key,
    required this.budgetId,
  });

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(budgetDetailProvider(budgetId));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: detailAsync.maybeWhen(
          data: (data) => data.budget.categoryName ?? 'Chi tiết ngân sách',
          orElse: () => 'Chi tiết ngân sách',
        ),
        subtitle: detailAsync.maybeWhen(
          data: (data) => 'Chu kỳ ',
          orElse: () => null,
        ),
        action: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 22),
          onPressed: () async {
            final confirmed = await showConfirmDialog(
              context,
              title: 'Xóa ngân sách?',
              message:
                  'Bạn có chắc chắn muốn xóa ngân sách này? Dữ liệu lịch sử sẽ không thể phục hồi.',
              confirmText: 'Xóa',
              isDestructive: true,
            );

            if (confirmed == true && context.mounted) {
              await ref
                  .read(budgetListProvider.notifier)
                  .deleteBudget(budgetId);
              if (context.mounted) {
                AppToast.show(
                  context,
                  message: 'Đã xóa ngân sách thành công!',
                  type: ToastType.success,
                );
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.budgets);
                }
              }
            }
          },
        ),
      ),
      body: detailAsync.when(
        data: (data) {
          final b = data.budget;
          final live = data.liveStatus;
          final effectiveLimit = live?.effectiveLimit ?? b.effectiveLimit;
          final spentAmount = live?.spentAmount ?? b.spentAmount;
          final remainingAmount = live?.remainingAmount ?? b.remainingAmount;
          final percentage = live?.percentage ?? b.percentage;
          final status = live?.status ?? b.status;
          final dailyBudgetRemaining =
              live?.dailyBudgetRemaining ?? b.dailyBudgetRemaining;

          Color statusColor;
          switch (status) {
            case BudgetProgressStatus.safe:
              statusColor = AppColors.success;
              break;
            case BudgetProgressStatus.warning:
              statusColor = AppColors.warning;
              break;
            case BudgetProgressStatus.exceeded:
              statusColor = AppColors.danger;
              break;
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(budgetDetailProvider(budgetId)),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header tiến độ chính
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CategoryIcon(
                                  icon: b.categoryIcon,
                                  colorHex: b.categoryColor,
                                  size: 36,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    b.categoryName ?? 'Chi tiêu chung',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.label,
                              style: GoogleFonts.inter(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tiến độ thanh Bar
                      BudgetProgressBar(percentage: percentage, height: 10),
                      const SizedBox(height: 16),

                      // Hạn mức, Đã dùng, Còn lại
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đã chi tiêu',
                                  style: GoogleFonts.inter(
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.lightMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currencyFormatter.format(spentAmount),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Hạn mức khả dụng',
                                  style: GoogleFonts.inter(
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.lightMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currencyFormatter.format(effectiveLimit),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Thặng dư/Bội chi Rollover
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cộng dồn từ kỳ trước:',
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              (b.rolloverAmount >= 0 ? '+' : '') +
                                  currencyFormatter.format(b.rolloverAmount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: b.rolloverAmount >= 0
                                    ? AppColors.success
                                    : AppColors.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Số tiền còn lại:',
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              currencyFormatter.format(remainingAmount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                color: remainingAmount < 0
                                    ? AppColors.danger
                                    : AppColors.primary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Trợ lý Nora: Gợi ý hạn mức chi tiêu mỗi ngày (live từ backend API)
                SmartDailyBudgetCard(budget: b, customDailyAmount: dailyBudgetRemaining),
                const SizedBox(height: 16),

                // Lịch sử các chu kỳ trước
                BudgetHistoryList(history: data.history),
                const SizedBox(height: 24),

                // Nút Chốt kỳ ngay & Sửa hạn mức
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Chốt kỳ sang chu kỳ mới?',
                            message:
                                'Khoản thặng dư hoặc bội chi hiện tại sẽ được kết chuyển sang chu kỳ mới theo cơ chế Rollover.',
                            confirmText: 'Chốt kỳ ngay',
                            isDestructive: false,
                            icon: Icons.autorenew_rounded,
                            iconColor: AppColors.primary,
                          );

                          if (confirmed == true && context.mounted) {
                            try {
                              await ref.read(
                                  budgetResetPeriodProvider(budgetId))();
                              if (context.mounted) {
                                AppToast.show(
                                  context,
                                  message:
                                      'Đã chuyển sang chu kỳ mới thành công!',
                                  type: ToastType.success,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppToast.show(
                                  context,
                                  message: 'Lỗi: $e',
                                  type: ToastType.error,
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.autorenew_rounded, size: 16),
                        label: const Text('Chốt kỳ sớm'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            RoutePaths.editBudget
                                .replaceAll(':id', b.id),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Sửa hạn mức'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Lỗi tải chi tiết: $err',
              style: const TextStyle(color: AppColors.danger)),
        ),
      ),
    );
  }
}
