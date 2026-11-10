import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:finora_mb/features/transactions/domain/models/transaction_enums.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/banner_header.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/models/recurring_enums.dart';
import '../../domain/models/recurring_transaction_filter.dart';
import '../../domain/models/recurring_transaction.dart';
import '../providers/recurring_transaction_list_provider.dart';
import 'recurring_transaction_detail_screen.dart';
import 'recurring_transaction_form_screen.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemsAsync = ref.watch(recurringTransactionListProvider);
    final filter = ref.watch(recurringTransactionFilterProvider);

    // Tính toán số liệu thống kê cho Hero Banner
    final transactions = itemsAsync.valueOrNull ?? [];
    final activeItems = transactions.where((item) => !item.isPaused).toList();
    final monthlyExpense = activeItems
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(
          0,
          (sum, item) => sum + _monthlyAmount(item),
        );
    final monthlyIncome = activeItems
        .where((item) => item.type == TransactionType.income)
        .fold<double>(
          0,
          (sum, item) => sum + _monthlyAmount(item),
        );
    final pausedCount = transactions.where((item) => item.isPaused).length;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ── 1. Banner Header Hero lớn chuẩn GEMINI.md & static-ui ────────
          BannerHeader(
            title: 'Giao dịch định kỳ',
            centerTitle: true,
            showBackButton: true,
            action: BannerHeader.glassButton(
              icon: const Icon(
                Icons.add_rounded,
                size: 22,
                color: Colors.white,
              ),
              onTap: () =>
                  context.push(RoutePaths.createRecurringTransaction),
              tooltip: 'Tạo quy tắc mới',
            ),
            child: _buildBannerHero(
              monthlyExpense: monthlyExpense,
              monthlyIncome: monthlyIncome,
              activeCount: activeItems.length,
              pausedCount: pausedCount,
            ),
          ),

          // ── 2. Bộ lọc Tabs (ChoiceChips tuân thủ chuẩn GEMINI.md) ─────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: _FilterChips(filter: filter, ref: ref),
          ),

          // ── 3. Danh sách các quy tắc định kỳ ─────────────────────────────
          Expanded(
            child: itemsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => ref
                        .read(recurringTransactionListProvider.notifier)
                        .refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _EmptyState(isDark: isDark),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref
                      .read(recurringTransactionListProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final tx = list[index];
                      return _RecurringTransactionCard(
                        item: tx,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecurringTransactionDetailScreen(id: tx.id),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecurringTransactionFormScreen(initialRule: tx),
                            ),
                          );
                        },
                        onPause: () => _togglePause(context, ref, tx),
                        onDelete: () => _confirmDelete(context, ref, tx),
                        onExecute: () => _executeNow(context, ref, tx),
                      );
                    },
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: AppColors.danger),
                      const SizedBox(height: 12),
                      Text('Lỗi tải dữ liệu: $e', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref
                            .read(recurringTransactionListProvider.notifier)
                            .refresh(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerHero({
    required double monthlyExpense,
    required double monthlyIncome,
    required int activeCount,
    required int pausedCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHI PHÍ ĐỊNH KỲ ƯỚC TÍNH / THÁNG',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          CurrencyFormatter.formatVnd(monthlyExpense),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        if (monthlyIncome > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Thu nhập định kỳ: +${CurrencyFormatter.format(monthlyIncome)}/tháng',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            _CountBadge(
              label: 'Đang chạy',
              count: activeCount,
              icon: Icons.play_circle_fill_rounded,
              bgColor: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(width: 10),
            _CountBadge(
              label: 'Tạm dừng',
              count: pausedCount,
              icon: Icons.pause_circle_rounded,
              bgColor: Colors.white.withValues(alpha: 0.12),
            ),
          ],
        ),
      ],
    );
  }

  double _monthlyAmount(RecurringTransaction item) {
    switch (item.frequency) {
      case RecurringFrequency.daily:
        return item.amount * 30;
      case RecurringFrequency.weekly:
        return item.amount * 4.33;
      case RecurringFrequency.biweekly:
        return item.amount * 2.16;
      case RecurringFrequency.monthly:
        return item.amount;
      case RecurringFrequency.quarterly:
        return item.amount / 3;
      case RecurringFrequency.yearly:
        return item.amount / 12;
    }
  }

  void _togglePause(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction item,
  ) async {
    try {
      await ref
          .read(recurringTransactionListProvider.notifier)
          .togglePause(item.id);
      if (context.mounted) {
        AppToast.success(
          context,
          item.isPaused ? 'Đã tiếp tục quy tắc' : 'Đã tạm dừng quy tắc',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, 'Lỗi cập nhật trạng thái: $e');
      }
    }
  }

  void _executeNow(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction item,
  ) async {
    try {
      await ref
          .read(recurringTransactionListProvider.notifier)
          .executeNow(item.id);
      if (context.mounted) {
        AppToast.success(context, 'Đã thực thi giao dịch định kỳ thành công');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, 'Lỗi thực thi giao dịch: $e');
      }
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction item,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa quy tắc định kỳ',
      message:
          'Bạn có chắc chắn muốn xóa "${item.name}"? Các giao dịch đã thực hiện trong quá khứ sẽ không bị ảnh hưởng.',
      confirmText: 'Xóa',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(recurringTransactionListProvider.notifier)
            .delete(item.id);
        if (context.mounted) {
          AppToast.success(context, 'Đã xóa quy tắc định kỳ');
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.error(context, 'Lỗi khi xóa: $e');
        }
      }
    }
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.label,
    required this.count,
    required this.icon,
    required this.bgColor,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thanh lọc ChoiceChip tuân thủ nghiêm ngặt Quy chuẩn 2 trong GEMINI.md
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.ref});

  final RecurringTransactionFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'Tất cả',
            selected: filter.isPaused == null && filter.type == null,
            onSelected: () {
              ref.read(recurringTransactionFilterProvider.notifier).state =
                  filter.copyWith(clearPaused: true, clearType: true);
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Chi tiêu',
            icon: Icons.arrow_downward_rounded,
            selected: filter.type == TransactionType.expense,
            onSelected: () {
              ref.read(recurringTransactionFilterProvider.notifier).state =
                  filter.copyWith(
                type: filter.type == TransactionType.expense
                    ? null
                    : TransactionType.expense,
                clearType: filter.type == TransactionType.expense,
              );
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Thu nhập',
            icon: Icons.arrow_upward_rounded,
            selected: filter.type == TransactionType.income,
            onSelected: () {
              ref.read(recurringTransactionFilterProvider.notifier).state =
                  filter.copyWith(
                type: filter.type == TransactionType.income
                    ? null
                    : TransactionType.income,
                clearType: filter.type == TransactionType.income,
              );
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Đang chạy',
            icon: Icons.play_arrow_rounded,
            selected: filter.isPaused == false,
            onSelected: () {
              ref.read(recurringTransactionFilterProvider.notifier).state =
                  filter.copyWith(
                isPaused: filter.isPaused == false ? null : false,
                clearPaused: filter.isPaused == false,
              );
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Tạm dừng',
            icon: Icons.pause_rounded,
            selected: filter.isPaused == true,
            onSelected: () {
              ref.read(recurringTransactionFilterProvider.notifier).state =
                  filter.copyWith(
                isPaused: filter.isPaused == true ? null : true,
                clearPaused: filter.isPaused == true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 15,
              color: selected
                  ? Colors.white
                  : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      side: BorderSide(
        color: selected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}

class _RecurringTransactionCard extends StatelessWidget {
  const _RecurringTransactionCard({
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onEdit,
    required this.onPause,
    required this.onDelete,
    required this.onExecute,
  });

  final RecurringTransaction item;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onPause;
  final VoidCallback onDelete;
  final VoidCallback onExecute;

  @override
  Widget build(BuildContext context) {
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final isExpense = item.type == TransactionType.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (isExpense ? AppColors.danger : AppColors.success)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isExpense
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color:
                            isExpense ? AppColors.danger : AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.frequency.displayName} · ${item.accountName ?? "Ví chính"}',
                            style: TextStyle(color: muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isExpense ? "-" : "+"}${CurrencyFormatter.format(item.amount)}',
                          style: TextStyle(
                            color: isExpense
                                ? AppColors.danger
                                : AppColors.success,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.isPaused
                                ? (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder)
                                : AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.isPaused ? 'Tạm dừng' : 'Đang chạy',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: item.isPaused
                                  ? muted
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 13, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      'Đến hạn: ${_formatDate(item.nextRunDate)}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz_rounded,
                          size: 20, color: muted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (val) {
                        if (val == 'edit') onEdit();
                        if (val == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.danger),
                              SizedBox(width: 8),
                              Text('Xóa',
                                  style: TextStyle(color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onPause,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: Icon(
                        item.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 16,
                      ),
                      label: Text(
                        item.isPaused ? 'Tiếp tục' : 'Tạm dừng',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    FilledButton.tonal(
                      onPressed: item.isPaused ? null : onExecute,
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 14),
                          SizedBox(width: 2),
                          Text('Chạy', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.event_repeat_rounded, size: 52, color: muted),
          const SizedBox(height: 16),
          Text(
            'Chưa có giao dịch định kỳ',
            style: TextStyle(
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo quy tắc đầu tiên để tự động hóa các khoản thu chi lặp lại.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
