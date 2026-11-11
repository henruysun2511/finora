import '../enums/balance_direction.dart';

class BalanceAdjustmentModel {
  final String id;
  final String accountId;
  final BalanceDirection direction;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String currency;
  final String reason;
  final String createdBy;
  final DateTime createdAt;

  const BalanceAdjustmentModel({
    required this.id,
    required this.accountId,
    required this.direction,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.currency,
    required this.reason,
    required this.createdBy,
    required this.createdAt,
  });
}

