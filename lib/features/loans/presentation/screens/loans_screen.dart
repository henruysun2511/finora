import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_filter.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';
import '../providers/loan_filter_provider.dart';
import '../providers/loan_list_provider.dart';
import '../providers/loan_list_state.dart';
import '../providers/loan_providers.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        ref.read(loanFilterProvider.notifier).setSearch(value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loans = ref.watch(loanListProvider);
    final filter = ref.watch(loanFilterProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Sổ ghi nợ',
          style: AppTextStyles.titleLarge(
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Đổi thứ tự khoản vay',
            onPressed: () =>
                ref.read(loanFilterProvider.notifier).toggleSortOrder(),
            icon: Icon(
              filter.sortOrder == LoanSortOrder.asc
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(RoutePaths.createLoan),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm khoản nợ'),
      ),
      body: Column(
        children: [
          _buildSearchField(isDark),
          _buildFilterChips(filter),
          Expanded(
            child: loans.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoansErrorView(
                message:
                    error is AppException ? error.message : error.toString(),
                onRetry: () => ref.invalidate(loanListProvider),
              ),
              data: (state) => RefreshIndicator(
                onRefresh: () => ref.read(loanListProvider.notifier).refresh(),
                child: _buildList(state, filter),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm theo tên người liên quan hoặc ghi chú',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(LoanFilter filter) {
    final selectedTab = filter.status == LoanStatus.settled
        ? _LoanTab.settled
        : switch (filter.type) {
            LoanType.lent => _LoanTab.lent,
            LoanType.borrowed => _LoanTab.borrowed,
            LoanType.installment => _LoanTab.installment,
            null => _LoanTab.all,
          };

    return SizedBox(
      height: 56,
      child: _FilterRow<_LoanTab>(
        options: const [
          _FilterOption(label: 'Tất cả', value: _LoanTab.all),
          _FilterOption(label: '🤝 Cho vay', value: _LoanTab.lent),
          _FilterOption(label: '💸 Đi vay', value: _LoanTab.borrowed),
          _FilterOption(label: '🛵 Trả góp', value: _LoanTab.installment),
          _FilterOption(label: '✅ Đã xong', value: _LoanTab.settled),
        ],
        selected: selectedTab,
        onSelected: (tab) {
          final filters = ref.read(loanFilterProvider.notifier);
          if (tab == _LoanTab.settled) {
            filters.setType(null);
            filters.setStatus(LoanStatus.settled);
          } else {
            filters.setStatus(null);
            filters.setType(switch (tab) {
              _LoanTab.lent => LoanType.lent,
              _LoanTab.borrowed => LoanType.borrowed,
              _LoanTab.installment => LoanType.installment,
              _LoanTab.all => null,
              _LoanTab.settled => null,
            });
          }
        },
      ),
    );
  }

  Widget _buildList(LoanListState state, LoanFilter filter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Loan? overdueLoan;
    for (final loan in state.items) {
      if (loan.effectiveStatus == LoanStatus.overdue) {
        overdueLoan = loan;
        break;
      }
    }
    final overdue = overdueLoan;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        const _LoanSummaryCard(),
        if (overdue != null) ...[
          const SizedBox(height: 12),
          _NoraOverdueCard(
            loan: overdue,
            onTap: () => context.pushNamed(
              RouteNames.loanDetail,
              pathParameters: {'id': overdue.id},
            ),
          ),
        ],
        if (state.items.isEmpty)
          _EmptyLoansState(
            filter: filter,
            isDark: isDark,
            onAdd: () => context.push(RoutePaths.createLoan),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 18, 2, 6),
            child: Text(
              '${state.items.length} khoản nợ',
              style: AppTextStyles.titleMedium(
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
          ),
          for (final loan in state.items)
            _LoanCard(
              loan: loan,
              onTap: () => context.pushNamed(
                RouteNames.loanDetail,
                pathParameters: {'id': loan.id},
              ),
            ),
        ],
      ],
    );
  }
}

class _EmptyLoansState extends StatelessWidget {
  const _EmptyLoansState({
    required this.filter,
    required this.isDark,
    required this.onAdd,
  });

  final LoanFilter filter;
  final bool isDark;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final hasSearch = filter.search?.isNotEmpty == true;
    final title = hasSearch
        ? 'Không tìm thấy khoản nợ phù hợp'
        : switch (filter.status) {
            LoanStatus.settled => 'Chưa có khoản nợ nào đã tất toán.',
            _ => switch (filter.type) {
                LoanType.lent =>
                  'Bạn không có khoản nợ nào cần thu hồi. Tiền bạc phân minh, an tâm tích lũy!',
                LoanType.borrowed =>
                  'Tuyệt vời! Bạn không có khoản nợ nào cần trả.',
                LoanType.installment =>
                  'Không có khoản mua sắm trả góp nào đang kích hoạt.',
                null => 'Chưa có khoản vay hoặc nợ nào.',
              },
          };

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 36, 12, 32),
      child: Column(
        children: [
          Icon(
            filter.type == LoanType.installment
                ? Icons.shopping_bag_outlined
                : filter.type == LoanType.borrowed
                    ? Icons.verified_rounded
                    : Icons.handshake_outlined,
            size: 56,
            color: filter.type == LoanType.borrowed
                ? AppColors.success
                : AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium(
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          if (!hasSearch && filter.status != LoanStatus.settled) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                filter.type == LoanType.lent
                    ? 'Cho ai đó vay'
                    : 'Thêm khoản mới',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterOption<T> {
  const _FilterOption({required this.label, required this.value});

  final String label;
  final T value;
}

enum _LoanTab { all, lent, borrowed, installment, settled }

class _FilterRow<T> extends StatelessWidget {
  const _FilterRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_FilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.value == selected;
          return ChoiceChip(
            label: Text(option.label),
            selected: isSelected,
            onSelected: (_) => onSelected(option.value),
            selectedColor: AppColors.primary.withValues(alpha: 0.14),
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            labelStyle: AppTextStyles.bodySmall(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                      ? AppColors.darkMuted
                      : AppColors.lightMuted,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

class _LoanSummaryCard extends ConsumerWidget {
  const _LoanSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(loanSummaryProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.balanceGradStart,
            AppColors.balanceGradMid,
            AppColors.balanceGradEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
      ),
      child: summary.when(
        loading: () => const SizedBox(
          height: 92,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (error, _) => Row(
          children: [
            Expanded(
              child: Text(
                'Không tải được tổng quan: '
                '${error is AppException ? error.message : error}',
                style: AppTextStyles.bodySmall(color: Colors.white),
              ),
            ),
            IconButton(
              tooltip: 'Tải lại tổng quan',
              onPressed: () => ref.invalidate(loanSummaryProvider),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VỊ THẾ NỢ RÒNG',
              style: AppTextStyles.bodySmall(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.formatVnd(data.netPosition),
              style: AppTextStyles.amountCard(
                color:
                    data.netPosition < 0 ? AppColors.danger : AppColors.success,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryAmount(
                    label: 'Cần thu',
                    amount: data.totalLent,
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _SummaryAmount(
                    label: 'Cần trả',
                    amount: data.totalBorrowed + data.totalInstallment,
                    color: AppColors.danger,
                  ),
                ),
                Expanded(
                  child: _SummaryAmount(
                    label: 'Quá hạn',
                    amount: data.overdueCount.toDouble(),
                    color: AppColors.danger,
                    isCount: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryAmount extends StatelessWidget {
  const _SummaryAmount({
    required this.label,
    required this.amount,
    required this.color,
    this.isCount = false,
  });

  final String label;
  final double amount;
  final Color color;
  final bool isCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall(color: Colors.white70)),
        const SizedBox(height: 3),
        Text(
          isCount
              ? '${amount.toInt()} khoản'
              : CurrencyFormatter.formatCompact(amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge(color: color),
        ),
      ],
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.loan, required this.onTap});

  final Loan loan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loanStatus = loan.effectiveStatus;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final statusColor = switch (loanStatus) {
      LoanStatus.overdue => AppColors.danger,
      LoanStatus.settled => AppColors.success,
      LoanStatus.active => switch (loan.type) {
          LoanType.lent => AppColors.primary,
          LoanType.borrowed => AppColors.orange,
          LoanType.installment => AppColors.violet,
        },
    };

    return Consumer(
      builder: (context, ref, _) {
        final lastReminder = ref.watch(reminderCooldownProvider(loan.id));
        final reminderCoolingDown = lastReminder != null &&
            DateTime.now().difference(lastReminder) < const Duration(hours: 6);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            side: BorderSide(
              color: loanStatus == LoanStatus.overdue
                  ? AppColors.danger
                  : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
              width: loanStatus == LoanStatus.overdue ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                            child: Text(
                              loan.counterpartyName.isEmpty
                                  ? '?'
                                  : loan.counterpartyName
                                      .substring(0, 1)
                                      .toUpperCase(),
                              style: AppTextStyles.labelLarge(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              loan.counterpartyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleMedium(
                                color: foreground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(
                            status: loanStatus,
                            color: statusColor,
                            overdueDays: loan.overdueDays,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        loan.type.displayName,
                        style: AppTextStyles.bodySmall(color: muted),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Còn lại',
                            style: AppTextStyles.bodySmall(color: muted),
                          ),
                          Text(
                            CurrencyFormatter.formatVnd(loan.remainingAmount),
                            style: AppTextStyles.amountItem(color: foreground),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: loan.repaidPercent,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Đã trả ${CurrencyFormatter.formatCompact(loan.paidAmount)}'
                              ' / ${CurrencyFormatter.formatCompact(loan.principalAmount)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall(color: muted),
                            ),
                          ),
                          if (loan.dueDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              loanStatus == LoanStatus.overdue
                                  ? 'Quá hạn ${loan.overdueDays ?? 0} ngày'
                                  : 'Hạn ${DateFormat('dd/MM/yyyy').format(loan.dueDate!)}',
                              style: AppTextStyles.bodySmall(
                                color: loanStatus == LoanStatus.overdue
                                    ? AppColors.danger
                                    : muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: loan.type == LoanType.lent
                        ? loan.isLinkedToFriend && !reminderCoolingDown
                            ? () async {
                                try {
                                  await ref
                                      .read(loanRepositoryProvider)
                                      .sendReminder(loan.id);
                                  ref
                                      .read(reminderCooldownProvider(loan.id)
                                          .notifier)
                                      .state = DateTime.now();
                                  if (context.mounted) {
                                    AppToast.success(
                                      context,
                                      'Đã gửi lời nhắc nợ.',
                                    );
                                  }
                                } catch (error) {
                                  final message = error is AppException
                                      ? error.message
                                      : error.toString();
                                  if (context.mounted) {
                                    AppToast.error(context, message);
                                  }
                                }
                              }
                            : null
                        : onTap,
                    icon: Icon(
                      loan.type == LoanType.lent
                          ? Icons.notifications_active_outlined
                          : Icons.add_card_rounded,
                    ),
                    label: Text(
                      loan.type == LoanType.lent
                          ? reminderCoolingDown
                              ? 'Đã nhắc gần đây'
                              : 'Nhắc nợ'
                          : 'Trả nợ',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NoraOverdueCard extends StatelessWidget {
  const _NoraOverdueCard({required this.loan, required this.onTap});

  final Loan loan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: AppColors.danger.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
        ),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.smart_toy_outlined, color: Colors.white),
          ),
          title: Text(
            'Nora: khoản nợ quá hạn',
            style: AppTextStyles.titleSmall(),
          ),
          subtitle: Text(
            '${loan.counterpartyName} còn nợ '
            '${CurrencyFormatter.formatVnd(loan.remainingAmount)} · '
            '${loan.overdueDays ?? 0} ngày quá hạn',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.color,
    this.overdueDays,
  });

  final LoanStatus status;
  final Color color;
  final int? overdueDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == LoanStatus.overdue && overdueDays != null
            ? 'Quá hạn $overdueDays ngày'
            : status.displayName,
        style: AppTextStyles.labelSmall(color: color),
      ),
    );
  }
}

class _LoansErrorView extends StatelessWidget {
  const _LoansErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
