import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/services/settings_api_service.dart';

final settingsApiServiceProvider = Provider<SettingsApiService>((ref) {
  return DioSettingsApiService(ref.watch(dioProvider));
});

final defaultCurrencyProvider =
    AsyncNotifierProvider<DefaultCurrencyNotifier, String>(() {
  return DefaultCurrencyNotifier();
});

class DefaultCurrencyNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    try {
      final service = ref.watch(settingsApiServiceProvider);
      final data = await service.getSettings();
      return (data['defaultCurrency'] as String?)?.toUpperCase() ?? 'VND';
    } catch (_) {
      return 'VND';
    }
  }

  Future<void> updateCurrency(String newCode) async {
    final cleanCode = newCode.trim().toUpperCase();
    final prev = state.value ?? 'VND';

    // Optimistic update
    state = AsyncData(cleanCode);

    try {
      final service = ref.read(settingsApiServiceProvider);
      await service.updateGeneralSettings(defaultCurrency: cleanCode);
    } catch (e) {
      // Revert if error
      state = AsyncData(prev);
      rethrow;
    }
  }
}

