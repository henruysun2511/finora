import 'mascot_tier_response.dart';

/// DTO phản hồi linh vật hiện tại từ GET /mascots/current
class CurrentMascotResponse {
  const CurrentMascotResponse({
    required this.netWorth,
    required this.totalWalletBalance,
    required this.totalDebt,
    this.showMascot = true,
    this.mascotTone = 'BALANCED',
    this.mascotSensitivity = 'ANOMALIES_ONLY',
    required this.greeting,
    required this.mascot,
  });

  final double netWorth;
  final double totalWalletBalance;
  final double totalDebt;
  final bool showMascot;
  final String mascotTone;
  final String mascotSensitivity;
  final String greeting;
  final MascotTierResponse mascot;

  factory CurrentMascotResponse.fromJson(Map<String, dynamic> json) {
    final mascotJson = json['mascot'] as Map<String, dynamic>? ?? {};

    return CurrentMascotResponse(
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      totalWalletBalance: (json['totalWalletBalance'] as num?)?.toDouble() ?? 0.0,
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
      showMascot: json['showMascot'] as bool? ?? true,
      mascotTone: json['mascotTone']?.toString() ?? 'BALANCED',
      mascotSensitivity: json['mascotSensitivity']?.toString() ?? 'ANOMALIES_ONLY',
      greeting: json['greeting']?.toString() ?? 'Xin chào! Mình là linh vật Finora đồng hành cùng bạn.',
      mascot: MascotTierResponse.fromJson(mascotJson),
    );
  }
}

