import 'mascot_enums.dart';
import 'mascot_tier.dart';

/// Entity đại diện cho trạng thái linh vật hiện tại của người dùng
class CurrentMascot {
  const CurrentMascot({
    required this.netWorth,
    required this.totalWalletBalance,
    required this.totalDebt,
    required this.showMascot,
    required this.mascotTone,
    required this.mascotSensitivity,
    required this.greeting,
    required this.mascot,
  });

  final double netWorth;
  final double totalWalletBalance;
  final double totalDebt;
  final bool showMascot;
  final MascotTone mascotTone;
  final MascotSensitivity mascotSensitivity;
  final String greeting;
  final MascotTier mascot;

  CurrentMascot copyWith({
    double? netWorth,
    double? totalWalletBalance,
    double? totalDebt,
    bool? showMascot,
    MascotTone? mascotTone,
    MascotSensitivity? mascotSensitivity,
    String? greeting,
    MascotTier? mascot,
  }) {
    return CurrentMascot(
      netWorth: netWorth ?? this.netWorth,
      totalWalletBalance: totalWalletBalance ?? this.totalWalletBalance,
      totalDebt: totalDebt ?? this.totalDebt,
      showMascot: showMascot ?? this.showMascot,
      mascotTone: mascotTone ?? this.mascotTone,
      mascotSensitivity: mascotSensitivity ?? this.mascotSensitivity,
      greeting: greeting ?? this.greeting,
      mascot: mascot ?? this.mascot,
    );
  }
}

