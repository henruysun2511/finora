import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';
import '../providers/loan_filter_provider.dart';
import '../providers/loan_list_provider.dart';
import '../widgets/loan_filter_tabs.dart';
import '../widgets/loan_list_view.dart';
import '../widgets/loan_search_bar.dart';
import '../widgets/loan_summary_card.dart';

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

  void _onTabSelected(LoanTab tab) {
    final filters = ref.read(loanFilterProvider.notifier);
    if (tab == LoanTab.settled) {
      filters.setType(null);
      filters.setStatus(LoanStatus.settled);
    } else {
      filters.setStatus(null);
      filters.setType(switch (tab) {
        LoanTab.lent => LoanType.lent,
        LoanTab.borrowed => LoanType.borrowed,
        LoanTab.installment => LoanType.installment,
        LoanTab.all => null,
        LoanTab.settled => null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loans = ref.watch(loanListProvider);
    final filter = ref.watch(loanFilterProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
          LoanSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: () {
              _searchController.clear();
              _onSearchChanged('');
              setState(() {});
            },
          ),
          LoanFilterTabs(
            filter: filter,
            onTabSelected: _onTabSelected,
          ),

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
                child: LoanListView(
                  state: state,
                  filter: filter,
                ),
              ),
            ),
          ),
        ],
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
