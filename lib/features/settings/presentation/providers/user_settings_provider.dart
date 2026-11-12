import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/services/settings_api_service.dart';
import '../../domain/models/ai_settings.dart';
import '../../domain/models/general_settings.dart';
import '../../domain/models/notification_preferences.dart';

export '../../domain/models/ai_settings.dart';
export '../../domain/models/general_settings.dart';
export '../../domain/models/notification_preferences.dart';

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
      final settings = GeneralSettings.fromMap(data);
      CurrencyFormatter.defaultCurrency = settings.defaultCurrency;
      return settings;
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

    if (defaultCurrency != null && defaultCurrency.trim().isNotEmpty) {
      CurrencyFormatter.defaultCurrency = defaultCurrency.trim().toUpperCase();
    }

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

final aiSettingsProvider =
    AsyncNotifierProvider<AiSettingsNotifier, AiSettings>(() {
  return AiSettingsNotifier();
});

class AiSettingsNotifier extends AsyncNotifier<AiSettings> {
  @override
  Future<AiSettings> build() async {
    final service = ref.watch(settingsApiServiceProvider);
    try {
      final data = await service.getSettings();
      return AiSettings.fromMap(data);
    } catch (_) {
      return const AiSettings();
    }
  }

  Future<void> updateAiSettings({
    String? provider,
    String? model,
    String? apiKey,
  }) async {
    final current = state.value ?? const AiSettings();
    final updated = current.copyWith(
      provider: provider,
      model: model,
      hasCustomApiKey: (apiKey != null && apiKey.trim().isNotEmpty) ? true : current.hasCustomApiKey,
    );

    state = AsyncData(updated);

    try {
      final service = ref.read(settingsApiServiceProvider);
      final res = await service.updateAiSettings(
        provider: provider,
        model: model,
        apiKey: apiKey,
      );
      state = AsyncData(AiSettings.fromMap(res));
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> deleteApiKey() async {
    final current = state.value ?? const AiSettings();
    final updated = current.copyWith(
      hasCustomApiKey: false,
      maskedApiKey: null,
    );

    state = AsyncData(updated);

    try {
      final service = ref.read(settingsApiServiceProvider);
      final res = await service.deleteCustomApiKey();
      state = AsyncData(AiSettings.fromMap(res));
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

/// Provider cung cấp Locale hiện tại theo thiết lập của người dùng ('vi' hoặc 'en')
final appLocaleProvider = Provider<Locale>((ref) {
  final lang = ref.watch(generalSettingsProvider).valueOrNull?.language.toLowerCase();
  return Locale(lang == 'en' ? 'en' : 'vi');
});

/// Provider cung cấp mã tiền tệ mặc định toàn cục ('VND', 'USD', 'EUR', ...)
final defaultCurrencyProvider = Provider<String>((ref) {
  return ref.watch(generalSettingsProvider).valueOrNull?.defaultCurrency ?? 'VND';
});

/// Provider cung cấp ký hiệu tiền tệ mặc định toàn cục ('₫', '$', '€', ...)
final defaultCurrencySymbolProvider = Provider<String>((ref) {
  final code = ref.watch(defaultCurrencyProvider);
  return CurrencyFormatter.symbolFor(code);
});

