import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/banner_header.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/models/recurring_enums.dart';
import '../../domain/models/recurring_transaction.dart';
import '../providers/recurring_transaction_list_provider.dart';
import '../widgets/recurring_banner_hero.dart';
import '../widgets/recurring_empty_state.dart';
import '../widgets/recurring_filter_chips.dart';
import '../widgets/recurring_transaction_card.dart';
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
            action: BannerHeader.primaryButton(
              icon: const Icon(
                Icons.add_rounded,
                size: 22,
                color: Colors.white,
              ),
              onTap: () =>
                  context.push(RoutePaths.createRecurringTransaction),
              tooltip: 'Tạo quy tắc mới',
            ),
            child: RecurringBannerHero(
              monthlyExpense: monthlyExpense,
              monthlyIncome: monthlyIncome,
              activeCount: activeItems.length,
              pausedCount: pausedCount,
            ),
          ),

          // ── 2. Bộ lọc Tabs (ChoiceChips tuân thủ chuẩn GEMINI.md) ─────────
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
            child: RecurringFilterChips(
              filter: filter,
              onFilterChanged: (newFilter) {
                ref.read(recurringTransactionFilterProvider.notifier).state =
                    newFilter;
              },
            ),
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
                        RecurringEmptyState(isDark: isDark),
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
                      return RecurringTransactionCard(
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
        AppToast.error(context, e);
      }
    }
  }

  void _executeNow(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction item,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Kích hoạt ngay bây giờ?',
      message: 'Một giao dịch "${item.name}" sẽ được tạo ngay lập tức vào ví.',
      confirmText: 'Kích hoạt',
      isDestructive: false,
      icon: Icons.play_arrow_rounded,
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(recurringTransactionListProvider.notifier)
          .executeNow(item.id);
      if (context.mounted) {
        AppToast.success(context, 'Đã tạo giao dịch định kỳ thành công!');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, e);
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
      title: 'Xác nhận xóa quy tắc',
      message:
          'Bạn có chắc chắn muốn xóa quy tắc lặp lại "${item.name}"? Các giao dịch đã tạo trước đó sẽ không bị ảnh hưởng.',
      confirmText: 'Xóa quy tắc',
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(recurringTransactionListProvider.notifier)
          .delete(item.id);
      if (context.mounted) {
        AppToast.success(context, 'Đã xóa quy tắc định kỳ');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, e);
      }
    }
  }
}
