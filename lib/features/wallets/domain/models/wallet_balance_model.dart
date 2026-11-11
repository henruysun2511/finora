class WalletBalanceModel {
  final String walletId;
  final String walletName;
  final String defaultCurrency;
  final double totalBalance;
  final Map<String, double> breakdownByCurrency;
  final int accountsCount;

  const WalletBalanceModel({
    required this.walletId,
    required this.walletName,
    required this.defaultCurrency,
    required this.totalBalance,
    required this.breakdownByCurrency,
    required this.accountsCount,
  });

  factory WalletBalanceModel.empty(String walletId) {
    return WalletBalanceModel(
      walletId: walletId,
      walletName: '',
      defaultCurrency: 'VND',
      totalBalance: 0.0,
      breakdownByCurrency: const {},
      accountsCount: 0,
    );
  }

  double get availableBalance => totalBalance;
}

