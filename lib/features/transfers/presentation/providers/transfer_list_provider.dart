import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/transfer.dart';
import 'transfer_providers.dart';

class TransferListState {
  final List<Transfer> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;
  final bool isLoadingMore;
  final String? accountIdFilter;

  const TransferListState({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.accountIdFilter,
  });

  TransferListState copyWith({
    List<Transfer>? items,
    int? total,
    int? page,
    int? limit,
    bool? hasMore,
    bool? isLoadingMore,
    String? accountIdFilter,
  }) {
    return TransferListState(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      accountIdFilter: accountIdFilter ?? this.accountIdFilter,
    );
  }
}

class TransferListNotifier extends AsyncNotifier<TransferListState> {
  @override
  Future<TransferListState> build() async {
    return _fetch(page: 1);
  }

  Future<TransferListState> _fetch({
    required int page,
    String? accountId,
  }) async {
    final repo = ref.read(transferRepositoryProvider);
    final result = await repo.getList(
      accountId: accountId,
      page: page,
      limit: 20,
    );

    return TransferListState(
      items: result.items,
      total: result.total,
      page: result.page,
      limit: result.limit,
      hasMore: result.items.length < result.total,
      isLoadingMore: false,
      accountIdFilter: accountId,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(page: 1, accountId: state.valueOrNull?.accountIdFilter),
    );
  }

  Future<void> filterByAccount(String? accountId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(page: 1, accountId: accountId));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(transferRepositoryProvider);
      final nextPage = current.page + 1;
      final result = await repo.getList(
        accountId: current.accountIdFilter,
        page: nextPage,
        limit: current.limit,
      );

      final newItems = [...current.items, ...result.items];
      state = AsyncValue.data(
        current.copyWith(
          items: newItems,
          total: result.total,
          page: result.page,
          hasMore: newItems.length < result.total,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }
}

final transferListProvider =
    AsyncNotifierProvider<TransferListNotifier, TransferListState>(
  TransferListNotifier.new,
);
