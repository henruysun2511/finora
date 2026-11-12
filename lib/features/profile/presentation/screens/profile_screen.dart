import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/theme_mode_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/profile_settings_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10n?.navProfile ?? 'Cài đặt & Hồ sơ',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkSurface, const Color(0xFF1E293B)]
                    : [AppColors.primaryLight, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Người dùng FINORA',
                        style: AppTextStyles.h3.copyWith(
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Thành viên FINORA',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Theme Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giao diện ứng dụng',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => ref
                              .read(themeModeNotifierProvider.notifier)
                              .setThemeMode(ThemeMode.light),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: themeMode == ThemeMode.light
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: themeMode == ThemeMode.light
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.wb_sunny_rounded,
                                  size: 16,
                                  color: themeMode == ThemeMode.light
                                      ? Colors.white
                                      : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n?.settingsThemeLight ?? 'Sáng',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: themeMode == ThemeMode.light
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: themeMode == ThemeMode.light
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.darkForeground
                                            : AppColors.lightForeground),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => ref
                              .read(themeModeNotifierProvider.notifier)
                              .setThemeMode(ThemeMode.dark),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: themeMode == ThemeMode.dark
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: themeMode == ThemeMode.dark
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.nightlight_round,
                                  size: 16,
                                  color: themeMode == ThemeMode.dark
                                      ? Colors.white
                                      : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n?.settingsThemeDark ?? 'Tối',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: themeMode == ThemeMode.dark
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: themeMode == ThemeMode.dark
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.darkForeground
                                            : AppColors.lightForeground),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Features & Management
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                ProfileSettingsTile(
                  icon: Icons.event_repeat_rounded,
                  title: l10n?.recurringTitle ?? 'Giao dịch định kỳ',
                  subtitle: 'Quản lý các khoản chi cố định tự động',
                  onTap: () => context.push(RoutePaths.recurringTransactions),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.handshake_rounded,
                  title: l10n?.loanTitle ?? 'Sổ ghi nợ',
                  subtitle: 'Theo dõi cho vay & đi vay',
                  onTap: () => context.push(RoutePaths.loans),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.call_split_rounded,
                  title: l10n?.splitTitle ?? 'Chia tiền nhóm',
                  subtitle: 'Split bill ăn uống & du lịch',
                  onTap: () => context.push(RoutePaths.splitExpenses),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.groups_rounded,
                  title: 'Quỹ chung nhóm',
                  subtitle: 'Ví gia đình và bạn cùng phòng',
                  onTap: () => context.push(RoutePaths.sharedWallets),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App Settings & Preferences
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                ProfileSettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: l10n?.navProfile ?? 'Hồ sơ cá nhân',
                  subtitle: 'Họ tên, số điện thoại, avatar & tài khoản',
                  onTap: () => context.push(RoutePaths.userProfileDetail),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.tune_rounded,
                  title: l10n?.settingsTitle ?? 'Cài đặt chung',
                  subtitle: 'Tiền tệ, ngôn ngữ, AI & quyền riêng tư',
                  onTap: () => context.push(RoutePaths.settings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.security_rounded,
                  title: l10n?.settingsPrivacy ?? 'Bảo mật & Mã PIN',
                  subtitle: 'Sinh trắc học Face ID, Touch ID',
                  onTap: () => context.push(RoutePaths.securitySettings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.category_rounded,
                  title: 'Quản lý Danh mục',
                  subtitle: 'Cấu hình danh mục thu chi',
                  onTap: () => context.push(RoutePaths.categorySettings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.pets_rounded,
                  title: 'AI Mascot & Tính cách',
                  subtitle: 'Linh vật đồng hành tài chính',
                  onTap: () => context.push(RoutePaths.aiPersonaSettings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: l10n?.settingsNotifications ?? 'Cài đặt Thông báo',
                  subtitle: 'Cảnh báo ngân sách & lịch nhắc',
                  onTap: () => context.push(RoutePaths.notificationSettings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ProfileSettingsTile(
                  icon: Icons.currency_exchange_rounded,
                  title: 'Tỷ giá & Quy đổi ngoại tệ',
                  subtitle: 'Tra cứu tỷ giá & công cụ quy đổi',
                  onTap: () => context.push(RoutePaths.exchangeRates),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sample Features (Feature Mẫu CRUD)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.science_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Feature Mẫu (Clean Architecture)',
                      style: AppTextStyles.h4.copyWith(
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ProfileSettingsTile(
                  icon: Icons.inventory_2_rounded,
                  title: 'Quản lý Sản phẩm (CRUD)',
                  subtitle: 'Mẫu chuẩn Create, Read, Update, Delete',
                  onTap: () => context.push(RoutePaths.products),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
              ),
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
            ),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(RoutePaths.welcome);
              }
            },
          ),
        ],
      ),
    );
  }
}
