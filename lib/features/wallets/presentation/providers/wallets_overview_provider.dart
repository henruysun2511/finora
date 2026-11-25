import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/domain/models/account_model.dart';
import '../../domain/models/wallet_balance_model.dart';
import '../../domain/models/wallet_model.dart';
import 'wallet_providers.dart';

class WalletItemState {
  final WalletModel wallet;
  final WalletBalanceModel balance;
  final List<AccountModel> accountsPreview;

  /// Toàn bộ tài khoản của ví.
  ///
  /// Nullable để không vỡ state được tạo trước khi hot reload (Flutter không
  /// hỗ trợ thêm field vào class đang có instance sống).
  final List<AccountModel>? accounts;

  const WalletItemState({
    required this.wallet,
    required this.balance,
    required this.accountsPreview,
    this.accounts,
  });

  /// Danh sách tài khoản đầy đủ, fallback về preview nếu state còn cũ.
  List<AccountModel> get allAccounts => accounts ?? accountsPreview;
}

class WalletsOverviewState {
  final List<WalletItemState> items;
  final double totalNetWorth;
  final double totalCashAndBank;
  final double totalCreditDebt;
  final String defaultCurrency;

  const WalletsOverviewState({
    required this.items,
    required this.totalNetWorth,
    required this.totalCashAndBank,
    required this.totalCreditDebt,
    required this.defaultCurrency,
  });

  List<WalletModel> get wallets => items.map((e) => e.wallet).toList();

  List<WalletItemState> getFilteredItems(WalletFilterTab filter) {
    switch (filter) {
      case WalletFilterTab.personal:
        return items.where((w) => w.wallet.isPersonal).toList();
      case WalletFilterTab.shared:
        return items.where((w) => w.wallet.isShared).toList();
      case WalletFilterTab.all:
      default:
        return items;
    }
  }

  int countForTab(WalletFilterTab tab) {
    switch (tab) {
      case WalletFilterTab.all:
        return items.length;
      case WalletFilterTab.personal:
        return items.where((w) => w.wallet.isPersonal).length;
      case WalletFilterTab.shared:
        return items.where((w) => w.wallet.isShared).length;
    }
  }
}

class WalletsOverviewNotifier extends AsyncNotifier<WalletsOverviewState> {
  @override
  Future<WalletsOverviewState> build() async {
    final repo = ref.watch(walletRepositoryProvider);
    final wallets = await repo.getWallets();

    double totalNetWorth = 0;
    double totalCashAndBank = 0;
    double totalCreditDebt = 0;
    String currency = 'VND';

    final items = await Future.wait(
      wallets.map((wallet) async {
        if (wallet.defaultCurrency.isNotEmpty) {
          currency = wallet.defaultCurrency;
        }

        final balanceFuture = repo.getWalletBalance(wallet.id).catchError(
          (_) => WalletBalanceModel.empty(wallet.id),
        );
        final accountsFuture = repo.getWalletAccounts(wallet.id).catchError(
          (_) => <AccountModel>[],
        );

        final results = await Future.wait([balanceFuture, accountsFuture]);
        final balance = results[0] as WalletBalanceModel;
        final accounts = results[1] as List<AccountModel>;

        totalNetWorth += balance.totalBalance;

        for (final acc in accounts) {
          if (!acc.isArchived) {
            if (acc.type.isCredit) {
              totalCreditDebt += acc.balance;
            } else {
              totalCashAndBank += acc.balance;
            }
          }
        }

        return WalletItemState(
          wallet: wallet,
          balance: balance,
          accountsPreview: accounts.take(3).toList(),
          accounts: accounts,
        );
      }),
    );

    return WalletsOverviewState(
      items: items,
      totalNetWorth: totalNetWorth,
      totalCashAndBank: totalCashAndBank,
      totalCreditDebt: totalCreditDebt,
      defaultCurrency: currency,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> deleteWallet(String id) async {
    await ref.read(walletRepositoryProvider).deleteWallet(id);
    await refresh();
  }
}

final walletsOverviewProvider =
    AsyncNotifierProvider<WalletsOverviewNotifier, WalletsOverviewState>(() {
      return WalletsOverviewNotifier();
    });

