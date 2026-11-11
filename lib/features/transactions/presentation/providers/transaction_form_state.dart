import '../../domain/models/transaction_enums.dart';

class TransactionFormState {
  const TransactionFormState({
    this.type = TransactionType.expense,
    this.amountString = '0',
    this.amount = 0.0,
    this.name,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountId,
    this.accountName,
    this.toAccountId,
    this.toAccountName,
    this.transactionDate,
    this.note,
    this.photoUrl,
    this.locationName,
    this.fee = 0.0,
    this.excludeFromReport = false,
    this.amountHidden = false,
    this.visibility = 'PRIVATE',
    this.isLoading = false,
    this.errorMessage,
  });

  final TransactionType type;
  final String amountString;
  final double amount;
  final String? name;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? accountId;
  final String? accountName;
  final String? toAccountId;
  final String? toAccountName;
  final DateTime? transactionDate;
  final String? note;
  final String? photoUrl;
  final String? locationName;
  final double fee;
  final bool excludeFromReport;
  final bool amountHidden;
  final String visibility;
  final bool isLoading;
  final String? errorMessage;

  TransactionFormState copyWith({
    TransactionType? type,
    String? amountString,
    double? amount,
    String? name,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    String? accountId,
    String? accountName,
    String? toAccountId,
    String? toAccountName,
    DateTime? transactionDate,
    String? note,
    String? photoUrl,
    String? locationName,
    double? fee,
    bool? excludeFromReport,
    bool? amountHidden,
    String? visibility,
    bool? isLoading,
    String? errorMessage,
    bool clearPhoto = false,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      amountString: amountString ?? this.amountString,
      amount: amount ?? this.amount,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      toAccountId: toAccountId ?? this.toAccountId,
      toAccountName: toAccountName ?? this.toAccountName,
      transactionDate: transactionDate ?? this.transactionDate,
      note: note ?? this.note,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      locationName: locationName ?? this.locationName,
      fee: fee ?? this.fee,
      excludeFromReport: excludeFromReport ?? this.excludeFromReport,
      amountHidden: amountHidden ?? this.amountHidden,
      visibility: visibility ?? this.visibility,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
