import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/theme_mode_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Cài đặt & Hồ sơ',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // User Profile Card (Clickable to open UserProfileDetailScreen)
          GestureDetector(
            onTap: () => context.push(RoutePaths.userProfileDetail),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppColors.radiusLg),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0] : 'N',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Nguyễn Văn A',
                          style: AppTextStyles.h4.copyWith(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? 'demo@finora.vn',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.darkMuted
                          : AppColors.lightMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme Settings Card
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
                Text(
                  'Giao diện ứng dụng',
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined, size: 18),
                        label: Text('Sáng'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined, size: 18),
                        label: Text('Tối'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined, size: 18),
                        label: Text('Hệ thống'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeModeNotifierProvider.notifier)
                          .setThemeMode(selection.first);
                    },
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
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.event_repeat_rounded,
                  title: 'Giao dịch định kỳ',
                  subtitle: 'Quản lý các khoản chi cố định tự động',
                  onTap: () => context.push(RoutePaths.recurringTransactions),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.handshake_rounded,
                  title: 'Sổ ghi nợ',
                  subtitle: 'Theo dõi cho vay & đi vay',
                  onTap: () => context.push(RoutePaths.loans),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.call_split_rounded,
                  title: 'Chia tiền nhóm',
                  subtitle: 'Split bill ăn uống & du lịch',
                  onTap: () => context.push(RoutePaths.splitExpenses),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildSettingsRow(
                  isDark: isDark,
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
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.person_outline_rounded,
                  title: 'Hồ sơ cá nhân',
                  subtitle: 'Họ tên, số điện thoại, avatar & tài khoản',
                  onTap: () => context.push(RoutePaths.userProfileDetail),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.security_rounded,
                  title: 'Bảo mật & Mã PIN',
                  subtitle: 'Sinh trắc học Face ID, Touch ID',
                  onTap: () => context.push(RoutePaths.securitySettings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.category_rounded,
                  title: 'Quản lý Danh mục',
                  subtitle: 'Cấu hình danh mục thu chi',
                  onTap: () => context.push(RoutePaths.categorySettings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.pets_rounded,
                  title: 'AI Mascot & Tính cách',
                  subtitle: 'Linh vật đồng hành tài chính',
                  onTap: () => context.push(RoutePaths.aiPersonaSettings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.notifications_none_rounded,
                  title: 'Cài đặt Thông báo',
                  subtitle: 'Cảnh báo ngân sách & lịch nhắc',
                  onTap: () => context.push(RoutePaths.notificationSettings),
                ),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildSettingsRow(
                  isDark: isDark,
                  icon: Icons.help_outline_rounded,
                  title: 'Trợ lý Nora AI Chat',
                  subtitle: 'Hỏi đáp & hỗ trợ tài chính',
                  onTap: () => context.push(RoutePaths.aiChat),
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
                _buildSettingsRow(
                  isDark: isDark,
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
                context.go(RoutePaths.login);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkMuted : const Color(0xFF94A3B8),
            size: 20,
          ),
        ],
      ),
    );
  }
}
