import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../domain/models/current_mascot.dart';
import '../../domain/models/mascot_enums.dart';
import '../../domain/models/mascot_evolution.dart';
import '../../domain/models/mascot_settings_input.dart';
import '../../domain/models/mascot_tier.dart';
import '../../domain/repositories/mascot_repository.dart';
import '../mappers/mascot_mapper.dart';
import '../services/mascot_api_service.dart';

class MascotRepositoryImpl implements MascotRepository {
  MascotRepositoryImpl(this._service);

  final MascotApiService _service;

  @override
  Future<CurrentMascot> getCurrentMascot() async {
    try {
      final res = await _service.getCurrentMascot();
      return MascotMapper.toCurrentDomain(res);
    } catch (_) {
      // Fallback cục bộ khi offline / mất kết nối
      return _getLocalFallbackCurrentMascot();
    }
  }

  @override
  Future<List<MascotTier>> getAllMascotTiers() async {
    try {
      final res = await _service.getAllMascotTiers();
      if (res.isNotEmpty) {
        return res.map(MascotMapper.toTierDomain).toList();
      }
    } catch (_) {}

    return _getLocalMascotTiers();
  }

  @override
  Future<MascotEvolution> syncEvolution() async {
    try {
      final res = await _service.syncEvolution();
      return MascotMapper.toEvolutionDomain(res);
    } catch (_) {
      final cur = _getLocalFallbackCurrentMascot();
      return MascotEvolution(
        evolved: false,
        netWorth: cur.netWorth,
        currentMascot: cur.mascot,
        message: 'Đồng bộ linh vật thành công (Offline mode)',
      );
    }
  }

  @override
  Future<void> updateMascotSettings(MascotSettingsInput input) async {
    final req = MascotMapper.toSettingsRequest(input);
    await _service.updateMascotSettings(req);
  }

  CurrentMascot _getLocalFallbackCurrentMascot() {
    final defaultTier = _getLocalMascotTiers()[3]; // Nora
    return CurrentMascot(
      netWorth: 12500000,
      totalWalletBalance: 15000000,
      totalDebt: 2500000,
      showMascot: true,
      mascotTone: MascotTone.balanced,
      mascotSensitivity: MascotSensitivity.anomaliesOnly,
      greeting:
          'Khoản chi này vẫn nằm trong tầm kiểm soát của tháng. Bạn hoàn toàn có thể chi trả mà không ảnh hưởng mục tiêu chung.',
      mascot: defaultTier,
    );
  }

  List<MascotTier> _getLocalMascotTiers() {
    return [
      MascotTier(
        id: 'ash',
        tierName: 'ash',
        displayName: MascotRegistry.ash.name,
        minNetWorth: MascotRegistry.ash.min,
        maxNetWorth: MascotRegistry.ash.max,
        displayOrder: 1,
        quotes: MascotRegistry.ash.quotes,
        systemPrompt: MascotRegistry.ash.personality,
      ),
      MascotTier(
        id: 'penny',
        tierName: 'penny',
        displayName: MascotRegistry.penny.name,
        minNetWorth: MascotRegistry.penny.min,
        maxNetWorth: MascotRegistry.penny.max,
        displayOrder: 2,
        quotes: MascotRegistry.penny.quotes,
        systemPrompt: MascotRegistry.penny.personality,
      ),
      MascotTier(
        id: 'sage',
        tierName: 'sage',
        displayName: MascotRegistry.sage.name,
        minNetWorth: MascotRegistry.sage.min,
        maxNetWorth: MascotRegistry.sage.max,
        displayOrder: 3,
        quotes: MascotRegistry.sage.quotes,
        systemPrompt: MascotRegistry.sage.personality,
      ),
      MascotTier(
        id: 'nora',
        tierName: 'nora',
        displayName: MascotRegistry.nora.name,
        minNetWorth: MascotRegistry.nora.min,
        maxNetWorth: MascotRegistry.nora.max,
        displayOrder: 4,
        quotes: MascotRegistry.nora.quotes,
        systemPrompt: MascotRegistry.nora.personality,
      ),
      MascotTier(
        id: 'jade',
        tierName: 'jade',
        displayName: MascotRegistry.jade.name,
        minNetWorth: MascotRegistry.jade.min,
        maxNetWorth: MascotRegistry.jade.max,
        displayOrder: 5,
        quotes: MascotRegistry.jade.quotes,
        systemPrompt: MascotRegistry.jade.personality,
      ),
      MascotTier(
        id: 'ruby',
        tierName: 'ruby',
        displayName: MascotRegistry.ruby.name,
        minNetWorth: MascotRegistry.ruby.min,
        maxNetWorth: MascotRegistry.ruby.max,
        displayOrder: 6,
        quotes: MascotRegistry.ruby.quotes,
        systemPrompt: MascotRegistry.ruby.personality,
      ),
      MascotTier(
        id: 'bellingham',
        tierName: 'bellingham',
        displayName: MascotRegistry.bellingham.name,
        minNetWorth: MascotRegistry.bellingham.min,
        maxNetWorth: null,
        displayOrder: 7,
        quotes: MascotRegistry.bellingham.quotes,
        systemPrompt: MascotRegistry.bellingham.personality,
      ),
    ];
  }
}

