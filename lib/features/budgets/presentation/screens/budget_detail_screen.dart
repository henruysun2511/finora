import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/models/budget_enums.dart';
import '../providers/budget_detail_provider.dart';
import '../providers/budget_list_provider.dart';
import '../widgets/budget_history_list.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/smart_daily_budget_card.dart';
import 'budget_form_screen.dart';

class BudgetDetailScreen extends ConsumerWidget {
  const BudgetDetailScreen({
    super.key,
    required this.budgetId,
  });

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(budgetDetailProvider(budgetId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: detailAsync.maybeWhen(
          data: (data) => Text(
            (data.budget.categoryName ?? 'Chi tiết ngân sách').toUpperCase(),
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          orElse: () => const Text('Chi tiết ngân sách'),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => const ConfirmDialog(
                  title: 'Xóa ngân sách?',
                  message: 'Bạn có chắc chắn muốn xóa ngân sách này? Dữ liệu lịch sử sẽ không thể phục hồi.',
                  confirmText: 'Xóa',
                  isDestructive: true,
                ),
              );

              if (confirmed == true && context.mounted) {
                await ref.read(budgetListProvider.notifier).deleteBudget(budgetId);
                if (context.mounted) {
                  AppToast.show(context, message: 'Đã xóa ngân sách thành công', type: ToastType.success);
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: detailAsync.when(
        data: (data) {
          final b = data.budget;
          final status = b.status;

          Color statusColor;
          String statusText;
          switch (status) {
            case BudgetProgressStatus.safe:
              statusColor = AppColors.success;
              statusText = '🟢 An toàn';
              break;
            case BudgetProgressStatus.warning:
              statusColor = AppColors.warning;
              statusText = '🟡 Sắp chạm trần';
              break;
            case BudgetProgressStatus.exceeded:
              statusColor = AppColors.danger;
              statusText = '🔴 Đã vượt hạn mức';
              break;
          }

          final startStr = DateFormat('dd/MM/yyyy').format(b.startDate);
          final endStr = b.endDate != null ? DateFormat('dd/MM/yyyy').format(b.endDate!) : '--';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(budgetDetailProvider(budgetId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Thông tin kỳ
                Text(
                  'Kỳ chi tiêu: $startStr → $endStr · Còn lại: ${b.daysRemaining} ngày',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Card Đã chi tiêu
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ĐÃ CHI TIÊU',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(b.spentAmount),
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      Text(
                        '(${b.percentage.toStringAsFixed(1)} %)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      BudgetProgressBar(percentage: b.percentage, height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2 Cột: Hạn mức khả dụng & Số tiền còn lại
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HẠN MỨC KHẢ DỤNG',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.lightMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(b.effectiveLimit),
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              b.rolloverAmount != 0
                                  ? '(Gốc ${currencyFormatter.format(b.limitAmount)} ${b.rolloverAmount > 0 ? "+ Thừa" : "- Thiếu"})'
                                  : '(Gốc ${currencyFormatter.format(b.limitAmount)})',
                              style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CÒN ĐƯỢC PHÉP CHI',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.lightMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(b.remainingAmount),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: b.remainingAmount >= 0 ? statusColor : AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusText,
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Trợ lý thông minh Smart Daily Budget
                SmartDailyBudgetCard(budget: b),
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
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => const ConfirmDialog(
                              title: 'Chốt kỳ sang chu kỳ mới?',
                              message: 'Khoản thặng dư hoặc bội chi hiện tại sẽ được kết chuyển sang chu kỳ mới theo cơ chế Rollover.',
                              confirmText: 'Chốt kỳ ngay',
                              isDestructive: false,
                              icon: Icons.autorenew_rounded,
                              iconColor: AppColors.primary,
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            try {
                              await ref.read(budgetResetPeriodProvider(budgetId))();
                              if (context.mounted) {
                                AppToast.show(context, message: 'Đã chuyển sang chu kỳ mới thành công!', type: ToastType.success);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppToast.show(context, message: 'Lỗi: $e', type: ToastType.error);
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.autorenew_rounded, size: 16),
                        label: const Text('Chốt kỳ sớm'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BudgetFormScreen(initialBudget: b),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Sửa hạn mức'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          child: Text('Lỗi tải chi tiết: $err', style: const TextStyle(color: AppColors.danger)),
        ),
      ),
    );
  }
}
