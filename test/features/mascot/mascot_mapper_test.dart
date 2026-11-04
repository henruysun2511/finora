import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/mascot/data/dto/current_mascot_response.dart';
import 'package:finora_mb/features/mascot/data/dto/mascot_evolution_response.dart';
import 'package:finora_mb/features/mascot/data/dto/mascot_tier_response.dart';
import 'package:finora_mb/features/mascot/data/mappers/mascot_mapper.dart';
import 'package:finora_mb/features/mascot/domain/models/mascot_enums.dart';

void main() {
  group('MascotMapper Tests', () {
    test('toTierDomain chuyển đổi chính xác DTO sang Domain MascotTier', () {
      const dto = MascotTierResponse(
        id: 'tier-nora-uuid',
        tierName: 'nora',
        displayName: 'Huấn Luyện Viên Đời Sống',
        minNetWorth: 5000000,
        maxNetWorth: 20000000,
        displayOrder: 4,
        quotes: ['Bình tĩnh nào bạn iu!'],
        systemPrompt: 'Prompt cho Nora...',
      );

      final domain = MascotMapper.toTierDomain(dto);

      expect(domain.id, 'tier-nora-uuid');
      expect(domain.tierName, 'nora');
      expect(domain.displayName, 'Huấn Luyện Viên Đời Sống');
      expect(domain.minNetWorth, 5000000);
      expect(domain.maxNetWorth, 20000000);
      expect(domain.rangeLabel, '5 – 20 triệu ₫');
      expect(domain.quotes.first, 'Bình tĩnh nào bạn iu!');
    });

    test('toCurrentDomain chuyển đổi chính xác CurrentMascotResponse sang CurrentMascot', () {
      const dto = CurrentMascotResponse(
        netWorth: 12000000,
        totalWalletBalance: 15000000,
        totalDebt: 3000000,
        showMascot: true,
        mascotTone: 'ROAST',
        mascotSensitivity: 'ALL',
        greeting: 'Chào mừng trở lại!',
        mascot: MascotTierResponse(
          id: 'tier-ash-uuid',
          tierName: 'ash',
          displayName: 'Ash - Kẻ Sinh Tồn',
          minNetWorth: -999999999,
          maxNetWorth: -1,
        ),
      );

      final domain = MascotMapper.toCurrentDomain(dto);

      expect(domain.netWorth, 12000000);
      expect(domain.totalWalletBalance, 15000000);
      expect(domain.totalDebt, 3000000);
      expect(domain.showMascot, isTrue);
      expect(domain.mascotTone, MascotTone.roast);
      expect(domain.mascotSensitivity, MascotSensitivity.all);
      expect(domain.greeting, 'Chào mừng trở lại!');
      expect(domain.mascot.displayName, 'Ash - Kẻ Sinh Tồn');
    });

    test('toEvolutionDomain chuyển đổi chính xác MascotEvolutionResponse', () {
      const dto = MascotEvolutionResponse(
        evolved: true,
        isLevelUp: true,
        netWorth: 25000000,
        currentMascot: MascotTierResponse(
          id: 'jade-uuid',
          tierName: 'jade',
          displayName: 'Chiến Lược Gia',
          minNetWorth: 20000000,
        ),
        message: 'Chúc mừng thăng hạng!',
      );

      final domain = MascotMapper.toEvolutionDomain(dto);

      expect(domain.evolved, isTrue);
      expect(domain.isLevelUp, isTrue);
      expect(domain.netWorth, 25000000);
      expect(domain.currentMascot.tierName, 'jade');
      expect(domain.message, 'Chúc mừng thăng hạng!');
    });

    test('MascotTone và MascotSensitivity fromString fallback an toàn', () {
      expect(MascotTone.fromString('GENTLE'), MascotTone.gentle);
      expect(MascotTone.fromString('BALANCED'), MascotTone.balanced);
      expect(MascotTone.fromString('ROAST'), MascotTone.roast);
      expect(MascotTone.fromString('UNKNOWN'), MascotTone.balanced);
      expect(MascotTone.fromString(null), MascotTone.balanced);

      expect(MascotSensitivity.fromString('ALL'), MascotSensitivity.all);
      expect(MascotSensitivity.fromString('ANOMALIES_ONLY'), MascotSensitivity.anomaliesOnly);
      expect(MascotSensitivity.fromString('SILENT'), MascotSensitivity.silent);
      expect(MascotSensitivity.fromString('UNKNOWN'), MascotSensitivity.anomaliesOnly);
      expect(MascotSensitivity.fromString(null), MascotSensitivity.anomaliesOnly);
    });
  });
}

