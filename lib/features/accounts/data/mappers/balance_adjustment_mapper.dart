import '../../domain/enums/balance_direction.dart';
import '../../domain/models/balance_adjustment_model.dart';

class BalanceAdjustmentMapper {
  BalanceAdjustmentMapper._();

  static BalanceAdjustmentModel fromJson(Map<String, dynamic> json) {
    return BalanceAdjustmentModel(
      id: json['id'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      direction: BalanceDirection.fromString(json['direction'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'VND',
      reason: json['reason'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

