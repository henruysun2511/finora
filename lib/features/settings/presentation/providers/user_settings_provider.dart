import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/services/settings_api_service.dart';
import '../../domain/models/general_settings.dart';
import '../../domain/models/notification_preferences.dart';

final settingsApiServiceProvider = Provider<SettingsApiService>((ref) {
  return DioSettingsApiService(ref.watch(dioProvider));
});

final generalSettingsProvider =
    AsyncNotifierProvider<GeneralSettingsNotifier, GeneralSettings>(() {
  return GeneralSettingsNotifier();
});

class GeneralSettingsNotifier extends AsyncNotifier<GeneralSettings> {
  @override
  Future<GeneralSettings> build() async {
    final service = ref.watch(settingsApiServiceProvider);
    try {
      final data = await service.getSettings();
      return GeneralSettings.fromMap(data);
    } catch (_) {
      return const GeneralSettings();
    }
  }

  Future<void> updateGeneral({
    String? defaultCurrency,
    String? language,
    String? defaultTransactionVisibility,
    bool? defaultAmountHidden,
  }) async {
    final current = state.value ?? const GeneralSettings();
    final updated = current.copyWith(
      defaultCurrency: defaultCurrency,
      language: language,
      defaultTransactionVisibility: defaultTransactionVisibility,
      defaultAmountHidden: defaultAmountHidden,
    );

    // Optimistic update
    state = AsyncData(updated);

    try {
      final service = ref.read(settingsApiServiceProvider);
      await service.updateGeneralSettings(
        defaultCurrency: defaultCurrency,
        language: language,
        defaultTransactionVisibility: defaultTransactionVisibility,
        defaultAmountHidden: defaultAmountHidden,
      );
      if (defaultCurrency != null) {
        ref.invalidate(defaultCurrencyProvider);
      }
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

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

final notificationPreferencesProvider =
    AsyncNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(() {
  return NotificationPreferencesNotifier();
});

class NotificationPreferencesNotifier extends AsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() async {
    final service = ref.watch(settingsApiServiceProvider);
    try {
      final data = await service.getSettings();
      final prefsMap = data['notificationPreferences'] as Map<String, dynamic>?;
      return NotificationPreferences.fromMap(prefsMap);
    } catch (_) {
      return const NotificationPreferences();
    }
  }

  Future<void> updatePreference({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? budgetAlerts,
    bool? loanReminders,
    bool? mascotEvolutionAlerts,
    bool? friendActivityAlerts,
  }) async {
    final current = state.value ?? const NotificationPreferences();
    final updated = current.copyWith(
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      budgetAlerts: budgetAlerts,
      loanReminders: loanReminders,
      mascotEvolutionAlerts: mascotEvolutionAlerts,
      friendActivityAlerts: friendActivityAlerts,
    );

    // Optimistic update
    state = AsyncData(updated);

    try {
      final service = ref.read(settingsApiServiceProvider);
      final payload = <String, dynamic>{};
      if (pushNotifications != null) payload['pushNotifications'] = pushNotifications;
      if (emailNotifications != null) payload['emailNotifications'] = emailNotifications;
      if (budgetAlerts != null) payload['budgetAlerts'] = budgetAlerts;
      if (loanReminders != null) payload['loanReminders'] = loanReminders;
      if (mascotEvolutionAlerts != null) payload['mascotEvolutionAlerts'] = mascotEvolutionAlerts;
      if (friendActivityAlerts != null) payload['friendActivityAlerts'] = friendActivityAlerts;

      await service.updateNotificationPreferences(payload);
    } catch (e) {
      // Revert if error
      state = AsyncData(current);
      rethrow;
    }
  }
}

