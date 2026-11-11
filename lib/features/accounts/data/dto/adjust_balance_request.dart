import '../../domain/enums/balance_direction.dart';

class AdjustBalanceRequest {
  final BalanceDirection direction;
  final double amount;
  final String reason;
  final String? pin;

  const AdjustBalanceRequest({
    required this.direction,
    required this.amount,
    required this.reason,
    this.pin,
  });

  Map<String, dynamic> toJson() {
    return {
      'direction': direction.toServerString(),
      'amount': amount,
      'reason': reason.trim(),
      if (pin != null && pin!.isNotEmpty) 'pin': pin!.trim(),
    };
  }
}

