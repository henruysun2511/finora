import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/user_settings_provider.dart';

/// Màn hình Cài đặt Thông báo chuẩn FinTech Design System
/// Tuân thủ quy chuẩn PageHeader.subPage, FormCard & SwitchListTile của Finora
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  Widget _buildIconBadge({
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: PageHeader.subPage(
        title: 'Cài đặt Thông báo',
        subtitle: 'Tùy chỉnh kênh nhận tin & cảnh báo tài chính',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: prefsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger.withValues(alpha: 0.8)),
                const SizedBox(height: 12),
                Text(
                  'Không thể tải cài đặt thông báo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: foreground),
                ),
                const SizedBox(height: 6),
                Text(
                  AppToast.extractErrorMessage(err),
                  style: TextStyle(fontSize: 13, color: muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(notificationPreferencesProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (prefs) {
          final notifier = ref.read(notificationPreferencesProvider.notifier);

          Future<void> onToggle({
            bool? push,
            bool? email,
            bool? budget,
            bool? loan,
            bool? mascot,
            bool? friend,
          }) async {
            try {
              await notifier.updatePreference(
                pushNotifications: push,
                emailNotifications: email,
                budgetAlerts: budget,
                loanReminders: loan,
                mascotEvolutionAlerts: mascot,
                friendActivityAlerts: friend,
              );
            } catch (e) {
              if (context.mounted) {
                AppToast.error(context, 'Cập nhật thất bại: ${AppToast.extractErrorMessage(e)}');
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // ── Header Summary Card ──
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), AppColors.darkSurface]
                        : [const Color(0xFFEFF6FF), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  children: [
                    _buildIconBadge(
                      icon: Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chủ động kiểm soát tài chính',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Finora chỉ gửi thông báo quan trọng giúp bạn không bỏ lỡ hạn trả nợ và kiểm soát ngân sách.',
                            style: TextStyle(
                              fontSize: 12,
                              color: muted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 1. KÊNH NHẬN THÔNG BÁO ──
              FormCard(
                title: 'Kênh nhận thông báo',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: _buildIconBadge(
                        icon: Icons.phone_android_rounded,
                        color: const Color(0xFF3B82F6),
                        isDark: isDark,
                      ),
                      title: Text(
                        'Thông báo đẩy (Push)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Nhận thông báo tức thì trên thiết bị khi có biến động hoặc tin nhắn mới',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      value: prefs.pushNotifications,
                      onChanged: (val) => onToggle(push: val),
                    ),
                    const Divider(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: _buildIconBadge(
                        icon: Icons.mail_outline_rounded,
                        color: const Color(0xFF6366F1),
                        isDark: isDark,
                      ),
                      title: Text(
                        'Thông báo qua Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Nhận báo cáo tổng kết chi tiêu tuần, tháng và cảnh báo bảo mật qua hòm thư',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      value: prefs.emailNotifications,
                      onChanged: (val) => onToggle(email: val),
                    ),
                  ],
                ),
              ),

              // ── 2. CẢNH BÁO TÀI CHÍNH & NGÂN SÁCH ──
              FormCard(
                title: 'Cảnh báo tài chính & Ngân sách',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: _buildIconBadge(
                        icon: Icons.pie_chart_outline_rounded,
                        color: const Color(0xFFEF4444),
                        isDark: isDark,
                      ),
                      title: Text(
                        'Cảnh báo vượt ngân sách',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Báo động ngay khi chi tiêu đạt 80% hoặc vượt hạn mức ngân sách đã đặt',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      value: prefs.budgetAlerts,
                      onChanged: (val) => onToggle(budget: val),
                    ),
                    const Divider(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: _buildIconBadge(
                        icon: Icons.calendar_today_rounded,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                      title: Text(
                        'Nhắc nhở nợ & Khoản vay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Nhắc nhở các khoản vay nợ cần thu hoặc cần trả khi sắp đến ngày đáo hạn',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      value: prefs.loanReminders,
                      onChanged: (val) => onToggle(loan: val),
                    ),
                  ],
                ),
              ),

              // ── 3. CỘNG ĐỒNG & LINH VẬT AI ──
              FormCard(
                title: 'Cộng đồng & Linh vật AI',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: _buildIconBadge(
                        icon: Icons.pets_rounded,
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                      title: Text(
                        'Tiến hóa & Tâm trạng Linh vật',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Nhận tin chúc mừng khi Mascot thăng hạng tài sản hoặc nhắc nhở chi tiêu phũ phàng',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      value: prefs.mascotEvolutionAlerts,
                      onChanged: (val) => onToggle(mascot: val),
                    ),
                    const Divider(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: _buildIconBadge(
                        icon: Icons.people_alt_outlined,
                        color: const Color(0xFF8B5CF6),
                        isDark: isDark,
                      ),
                      title: Text(
                        'Bạn bè & Hoạt động chia tiền',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Thông báo tin nhắn riêng, tương tác bài đăng khoảnh khắc và yêu cầu chia tiền nhóm',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      value: prefs.friendActivityAlerts,
                      onChanged: (val) => onToggle(friend: val),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
