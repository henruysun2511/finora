import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../wallets/presentation/providers/wallet_detail_provider.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../../data/dto/adjust_balance_request.dart';
import '../../domain/enums/balance_direction.dart';
import '../../domain/models/account_model.dart';
import 'account_providers.dart';

class AccountTransactionItem {
  final String id;
  final String title;
  final double amount;
  final String type; // INCOME / EXPENSE / ADJUSTMENT
  final String? categoryName;
  final String? categoryIcon;
  final DateTime transactionDate;

  const AccountTransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryName,
    this.categoryIcon,
    required this.transactionDate,
  });
}

class AccountDetailState {
  final AccountModel account;
  final List<AccountTransactionItem> recentTransactions;

  const AccountDetailState({
    required this.account,
    required this.recentTransactions,
  });
}

final accountDetailProvider =
    FutureProvider.family<AccountDetailState, String>((ref, accountId) async {
  final repo = ref.watch(accountRepositoryProvider);
  final account = await repo.getAccountById(accountId);

  List<AccountTransactionItem> transactions = [];
  try {
    final dio = ref.watch(dioProvider);
    final res = await dio.get(
      '/transactions',
      queryParameters: {'accountId': accountId, 'limit': 10},
    );
    final data = res.data;
    dynamic items;
    if (data is Map<String, dynamic>) {
      items = data['data'] ?? data['items'];
      if (items is Map<String, dynamic> && items['items'] is List) {
        items = items['items'];
      }
    } else if (data is List) {
      items = data;
    }
    if (items is List) {
      transactions = items.map((raw) {
        final m = raw as Map<String, dynamic>;
        return AccountTransactionItem(
          id: m['id'] as String? ?? '',
          title: m['note'] as String? ??
              m['category']?['name'] as String? ??
              'Giao dịch',
          amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
          type: m['type'] as String? ?? 'EXPENSE',
          categoryName: m['category']?['name'] as String?,
          categoryIcon: m['category']?['icon'] as String?,
          transactionDate: m['transactionDate'] != null
              ? DateTime.tryParse(m['transactionDate'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
        );
      }).toList();
    }
  } catch (_) {}

  return AccountDetailState(
    account: account,
    recentTransactions: transactions,
  );
});

class AccountDetailActions {
  final Ref _ref;
  final String _accountId;

  AccountDetailActions(this._ref, this._accountId);

  Future<void> archiveAccount(String walletId) async {
    final repo = _ref.read(accountRepositoryProvider);
    await repo.archiveAccount(_accountId);
    _ref.invalidate(accountDetailProvider(_accountId));
    _ref.invalidate(walletDetailProvider(walletId));
    _ref.invalidate(walletsOverviewProvider);
  }

  Future<void> unarchiveAccount(String walletId) async {
    final repo = _ref.read(accountRepositoryProvider);
    await repo.unarchiveAccount(_accountId);
    _ref.invalidate(accountDetailProvider(_accountId));
    _ref.invalidate(walletDetailProvider(walletId));
    _ref.invalidate(walletsOverviewProvider);
  }

  Future<void> deleteAccount(String walletId) async {
    final repo = _ref.read(accountRepositoryProvider);
    await repo.deleteAccount(_accountId);
    _ref.invalidate(walletDetailProvider(walletId));
    _ref.invalidate(walletsOverviewProvider);
  }

  Future<void> adjustBalance({
    required String walletId,
    required BalanceDirection direction,
    required double amount,
    required String reason,
    String? pin,
    required String idempotencyKey,
  }) async {
    final repo = _ref.read(accountRepositoryProvider);
    await repo.adjustBalance(
      _accountId,
      AdjustBalanceRequest(
        direction: direction,
        amount: amount,
        reason: reason,
        pin: pin,
      ),
      idempotencyKey: idempotencyKey,
    );
    _ref.invalidate(accountDetailProvider(_accountId));
    _ref.invalidate(walletDetailProvider(walletId));
    _ref.invalidate(walletsOverviewProvider);
  }
}

final accountDetailActionsProvider =
    Provider.family<AccountDetailActions, String>((ref, accountId) {
  return AccountDetailActions(ref, accountId);
});
