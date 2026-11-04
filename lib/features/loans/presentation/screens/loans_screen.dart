import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_filter.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';
import '../providers/loan_filter_provider.dart';
import '../providers/loan_list_provider.dart';
import '../providers/loan_list_state.dart';
import '../widgets/loan_card.dart';
import '../widgets/loan_empty_state.dart';
import '../widgets/loan_filter_row.dart';
import '../widgets/loan_summary_card.dart';
import '../widgets/nora_overdue_card.dart';

enum _LoanTab { all, lent, borrowed, installment, settled }

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key, this.initialTab});

  final String? initialTab;

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyInitialTab(widget.initialTab!);
      });
    }
  }

  void _applyInitialTab(String tabStr) {
    final filters = ref.read(loanFilterProvider.notifier);
    switch (tabStr.toLowerCase()) {
      case 'lent':
        filters.setType(LoanType.lent);
        filters.setStatus(null);
        break;
      case 'borrowed':
        filters.setType(LoanType.borrowed);
        filters.setStatus(null);
        break;
      case 'installment':
        filters.setType(LoanType.installment);
        filters.setStatus(null);
        break;
      case 'settled':
        filters.setType(null);
        filters.setStatus(LoanStatus.settled);
        break;
    }
  }

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
      // Bỏ AppBar trên cùng theo yêu cầu: Nút quay lại và tiêu đề được đưa trực tiếp vào banner
      body: Column(
        children: [
          // ── Banner Vị Thế Nợ Ròng với Nút Quay Lại & Nút Thêm ở trong Banner ──
          LoanSummaryCard(
            sortOrder: filter.sortOrder,
            onToggleSort: () =>
                ref.read(loanFilterProvider.notifier).toggleSortOrder(),
            onAdd: () => context.push(RoutePaths.createLoan),
          ),

          // ── Ô Tìm kiếm & Bộ lọc Tab ──
          _buildSearchField(isDark),
          _buildFilterTabs(filter),

          // ── Danh sách các khoản nợ ──
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
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
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(LoanFilter filter) {
    final selectedTab = filter.status == LoanStatus.settled
        ? _LoanTab.settled
        : switch (filter.type) {
            LoanType.lent => _LoanTab.lent,
            LoanType.borrowed => _LoanTab.borrowed,
            LoanType.installment => _LoanTab.installment,
            null => _LoanTab.all,
          };

    return SizedBox(
      height: 52,
      child: LoanFilterRow<_LoanTab>(
        options: const [
          FilterOption(
            label: 'Tất cả',
            value: _LoanTab.all,
            icon: Icons.layers_outlined,
          ),
          FilterOption(
            label: 'Cho vay',
            value: _LoanTab.lent,
            icon: Icons.arrow_outward_rounded,
          ),
          FilterOption(
            label: 'Đi vay',
            value: _LoanTab.borrowed,
            icon: Icons.south_west_rounded,
          ),
          FilterOption(
            label: 'Trả góp',
            value: _LoanTab.installment,
            icon: Icons.credit_card_rounded,
          ),
          FilterOption(
            label: 'Đã xong',
            value: _LoanTab.settled,
            icon: Icons.task_alt_rounded,
          ),
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

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        if (overdueLoan != null) ...[
          NoraOverdueCard(
            loan: overdueLoan,
            onTap: () => context.pushNamed(
              RouteNames.loanDetail,
              pathParameters: {'id': overdueLoan!.id},
            ),
          ),
        ],
        if (state.items.isEmpty)
          LoanEmptyState(
            filter: filter,
            isDark: isDark,
            onAdd: () => context.push(RoutePaths.createLoan),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
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
            LoanCard(
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
            const Icon(Icons.cloud_off_rounded, color: AppColors.danger, size: 40),
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
