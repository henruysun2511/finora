import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/models/recurring-enum.dart';
import '../../domain/models/recurring-transaction-filter.dart';
import '../../domain/models/recurring-transaction.dart';
import '../providers/recurring-transaction-list-provider.dart';
import 'recurring-transaction-form-screen.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = ref.watch(recurringTransactionListProvider);
    final filter = ref.watch(recurringTransactionFilterProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Hóa đơn & Đăng ký định kỳ'),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Tạo quy tắc định kỳ',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RecurringTransactionFormScreen(),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: items.when(
        data: (transactions) {
          final activeItems =
              transactions.where((item) => !item.isPaused).toList();
          final monthlyExpense = activeItems
              .where((item) => item.type == TransactionType.expense)
              .fold<double>(
                0,
                (sum, item) => sum + _monthlyAmount(item),
              );
          final pausedCount =
              transactions.where((item) => item.isPaused).length;

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(recurringTransactionListProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _OverviewCard(
                  monthlyExpense: monthlyExpense,
                  activeCount: activeItems.length,
                  pausedCount: pausedCount,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                _FilterChips(filter: filter, ref: ref),
                const SizedBox(height: 20),
                if (transactions.isEmpty)
                  _EmptyState(isDark: isDark)
                else
                  ...transactions.map(
                    (item) => _RecurringTransactionCard(
                      item: item,
                      isDark: isDark,
                      onPause: () async {
                        try {
                          await ref
                              .read(recurringTransactionListProvider.notifier)
                              .togglePause(item.id);
                        } catch (error) {
                          if (context.mounted) {
                            AppToast.error(context, error.toString());
                          }
                        }
                      },
                      onDelete: () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Xóa giao dịch định kỳ',
                          message:
                              'Bạn có chắc muốn xóa "${item.name}"? Hành động này không thể hoàn tác.',
                          confirmText: 'Xóa',
                        );
                        if (!confirmed || !context.mounted) return;

                        try {
                          await ref
                              .read(recurringTransactionListProvider.notifier)
                              .delete(item.id);
                          if (context.mounted) {
                            AppToast.success(
                              context,
                              'Đã xóa giao dịch định kỳ.',
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            AppToast.error(context, error.toString());
                          }
                        }
                      },
                      onExecute: () async {
                        try {
                          await ref
                              .read(recurringTransactionListProvider.notifier)
                              .executeNow(item.id);
                          if (context.mounted) {
                            AppToast.success(
                              context,
                              'Đã thực hiện giao dịch định kỳ.',
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            AppToast.error(context, error.toString());
                          }
                        }
                      },
                    ),
                  ),
                if (transactions.isEmpty) const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Không thể tải các giao dịch định kỳ.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(recurringTransactionListProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _monthlyAmount(RecurringTransaction item) {
    switch (item.frequency) {
      case RecurringFrequency.daily:
        return item.amount * 30;
      case RecurringFrequency.weekly:
        return item.amount * 4.345;
      case RecurringFrequency.biweekly:
        return item.amount * 2.172;
      case RecurringFrequency.monthly:
        return item.amount;
      case RecurringFrequency.quarterly:
        return item.amount / 3;
      case RecurringFrequency.yearly:
        return item.amount / 12;
    }
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.monthlyExpense,
    required this.activeCount,
    required this.pausedCount,
    required this.isDark,
  });

  final double monthlyExpense;
  final int activeCount;
  final int pausedCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primaryGradientEnd
          ],
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHI PHÍ ĐỊNH KỲ ƯỚC TÍNH / THÁNG',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${monthlyExpense.toStringAsFixed(0)} ₫',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _CountLabel(label: 'Đang chạy', count: activeCount),
              const SizedBox(width: 20),
              _CountLabel(label: 'Tạm dừng', count: pausedCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountLabel extends StatelessWidget {
  const _CountLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count $label',
      style: const TextStyle(color: Colors.white, fontSize: 13),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.ref});

  final RecurringTransactionFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildChip('Tất cả', filter.isPaused == null, () {
          ref.read(recurringTransactionFilterProvider.notifier).state =
              filter.copyWith(clearPaused: true);
        }),
        _buildChip('Đang chạy', filter.isPaused == false, () {
          ref.read(recurringTransactionFilterProvider.notifier).state =
              filter.copyWith(isPaused: false);
        }),
        _buildChip('Tạm dừng', filter.isPaused == true, () {
          ref.read(recurringTransactionFilterProvider.notifier).state =
              filter.copyWith(isPaused: true);
        }),
      ],
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _RecurringTransactionCard extends StatelessWidget {
  const _RecurringTransactionCard({
    required this.item,
    required this.isDark,
    required this.onPause,
    required this.onDelete,
    required this.onExecute,
  });

  final RecurringTransaction item;
  final bool isDark;
  final VoidCallback onPause;
  final VoidCallback onDelete;
  final VoidCallback onExecute;

  @override
  Widget build(BuildContext context) {
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Card(
      color: isDark ? AppColors.darkSurface : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${item.amount.toStringAsFixed(0)} ${item.currency}',
                  style: TextStyle(
                    color: item.type == TransactionType.expense
                        ? AppColors.danger
                        : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${item.frequency.displayName} · Đến hạn ${_formatDate(item.nextRunDate)}',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              item.accountName ?? 'Chưa có thông tin ví',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Xóa quy tắc định kỳ',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
                ),
                TextButton.icon(
                  onPressed: onPause,
                  icon: Icon(
                    item.isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                  ),
                  label: Text(item.isPaused ? 'Tiếp tục' : 'Tạm dừng'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: item.isPaused ? null : onExecute,
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('Chạy ngay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
            'Tạo quy tắc đầu tiên để theo dõi các khoản thu chi lặp lại.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
        ],
      ),
    );
  }
}
