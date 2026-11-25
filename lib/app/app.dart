import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/providers/user_settings_provider.dart';
import 'package:finora_mb/l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'Finora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => DevicePreview.appBuilder(
        context,
        MediaQuery.withClampedTextScaling(
          // Giữ giao diện ổn định: chặn text scale quá lớn (device preview /
          // cài đặt hệ thống) gây tràn layout ở các khối có chiều cao cố định.
          maxScaleFactor: 1.2,
          child: child!,
        ),
      ),
      routerConfig: router,
    );
  }
}
