import 'mascot_tier_response.dart';

/// DTO phản hồi sự kiện đồng bộ tiến hóa từ POST /mascots/sync-evolution
class MascotEvolutionResponse {
  const MascotEvolutionResponse({
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
  final MascotTierResponse currentMascot;
  final MascotTierResponse? previousMascot;
  final String message;

  factory MascotEvolutionResponse.fromJson(Map<String, dynamic> json) {
    final curMascotJson = json['currentMascot'] as Map<String, dynamic>? ?? {};
    final prevMascotJson = json['previousMascot'] as Map<String, dynamic>?;

    return MascotEvolutionResponse(
      evolved: json['evolved'] as bool? ?? false,
      isLevelUp: json['isLevelUp'] as bool?,
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      currentMascot: MascotTierResponse.fromJson(curMascotJson),
      previousMascot: prevMascotJson != null ? MascotTierResponse.fromJson(prevMascotJson) : null,
      message: json['message']?.toString() ?? 'Đồng bộ linh vật thành công',
    );
  }
}

