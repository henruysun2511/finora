import '../../domain/models/current_mascot.dart';
import '../../domain/models/mascot_enums.dart';
import '../../domain/models/mascot_evolution.dart';
import '../../domain/models/mascot_settings_input.dart';
import '../../domain/models/mascot_tier.dart';
import '../dto/current_mascot_response.dart';
import '../dto/mascot_evolution_response.dart';
import '../dto/mascot_tier_response.dart';
import '../dto/update_mascot_settings_request.dart';

class MascotMapper {
  static MascotTier toTierDomain(MascotTierResponse dto) {
    return MascotTier(
      id: dto.id,
      tierName: dto.tierName,
      displayName: dto.displayName,
      minNetWorth: dto.minNetWorth,
      maxNetWorth: dto.maxNetWorth,
      displayOrder: dto.displayOrder,
      quotes: dto.quotes,
      systemPrompt: dto.systemPrompt,
      htmlContent: dto.htmlContent,
      mascotAssetUrl: dto.mascotAssetUrl,
      isActive: dto.isActive,
    );
  }

  static CurrentMascot toCurrentDomain(CurrentMascotResponse dto) {
    return CurrentMascot(
      netWorth: dto.netWorth,
      totalWalletBalance: dto.totalWalletBalance,
      totalDebt: dto.totalDebt,
      showMascot: dto.showMascot,
      mascotTone: MascotTone.fromString(dto.mascotTone),
      mascotSensitivity: MascotSensitivity.fromString(dto.mascotSensitivity),
      greeting: dto.greeting,
      mascot: toTierDomain(dto.mascot),
    );
  }

  static MascotEvolution toEvolutionDomain(MascotEvolutionResponse dto) {
    return MascotEvolution(
      evolved: dto.evolved,
      isLevelUp: dto.isLevelUp,
      netWorth: dto.netWorth,
      currentMascot: toTierDomain(dto.currentMascot),
      previousMascot: dto.previousMascot != null ? toTierDomain(dto.previousMascot!) : null,
      message: dto.message,
    );
  }

  static UpdateMascotSettingsRequest toSettingsRequest(MascotSettingsInput input) {
    return UpdateMascotSettingsRequest(
      showMascot: input.showMascot,
      mascotTone: input.mascotTone?.value,
      mascotSensitivity: input.mascotSensitivity?.value,
    );
  }
}

