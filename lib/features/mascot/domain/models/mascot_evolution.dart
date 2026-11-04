import 'mascot_tier.dart';

/// Kết quả sự kiện kiểm tra và đồng bộ tiến hóa linh vật
class MascotEvolution {
  const MascotEvolution({
    required this.evolved,
    this.isLevelUp,
    required this.netWorth,
    required this.currentMascot,
    this.previousMascot,
    required this.message,
  });

  final bool evolved;
  final bool? isLevelUp;
  final double netWorth;
  final MascotTier currentMascot;
  final MascotTier? previousMascot;
  final String message;
}

