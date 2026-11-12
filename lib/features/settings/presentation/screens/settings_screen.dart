import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/ai_settings.dart';
import '../../domain/models/general_settings.dart';
import '../providers/user_settings_provider.dart';

/// Màn hình Cài đặt chung chuẩn FinTech Design System
/// Quản lý Tiền tệ, Ngôn ngữ, Quyền riêng tư, Cấu hình Mô hình AI & API Key (BYOK)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, String>> supportedCurrencies = [
    {'code': 'VND', 'name': 'Việt Nam Đồng', 'symbol': '₫'},
    {'code': 'USD', 'name': 'Đô la Mỹ', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Đồng Euro', 'symbol': '€'},
    {'code': 'JPY', 'name': 'Yên Nhật', 'symbol': '¥'},
    {'code': 'KRW', 'name': 'Won Hàn Quốc', 'symbol': '₩'},
    {'code': 'SGD', 'name': 'Đô la Singapore', 'symbol': 'S\$'},
    {'code': 'GBP', 'name': 'Bảng Anh', 'symbol': '£'},
    {'code': 'THB', 'name': 'Bạt Thái Lan', 'symbol': '฿'},
  ];

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

  void _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: Row(
                    children: [
                      Text(
                        'Chọn đơn vị tiền tệ mặc định',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 20, color: muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: supportedCurrencies.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: border),
                    itemBuilder: (c, i) {
                      final item = supportedCurrencies[i];
                      final code = item['code']!;
                      final name = item['name']!;
                      final symbol = item['symbol']!;
                      final isSelected = code == currentCode.toUpperCase();

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: isSelected
                            ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                            : Colors.transparent,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            symbol,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          '$code - $name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : foreground,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
                            : null,
                        onTap: () async {
                          Navigator.pop(ctx);
                          if (!isSelected) {
                            try {
                              await ref
                                  .read(generalSettingsProvider.notifier)
                                  .updateGeneral(defaultCurrency: code);
                              if (context.mounted) {
                                AppToast.success(context, 'Đã đổi đơn vị tiền tệ sang $code ($symbol)');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppToast.error(context, e);
                              }
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final languages = [
      {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
      {'code': 'en', 'name': 'English (US)', 'flag': '🇺🇸'},
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    children: [
                      Text(
                        'Chọn ngôn ngữ hiển thị',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 20, color: muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: border),
                  itemBuilder: (c, i) {
                    final item = languages[i];
                    final code = item['code']!;
                    final name = item['name']!;
                    final flag = item['flag']!;
                    final isSelected = code == currentLang.toLowerCase();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isSelected
                          ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                          : Colors.transparent,
                      leading: Text(flag, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : foreground,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (!isSelected) {
                          try {
                            await ref
                                .read(generalSettingsProvider.notifier)
                                .updateGeneral(language: code);
                            if (context.mounted) {
                              AppToast.success(context, 'Đã chuyển ngôn ngữ sang $name');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(context, e);
                            }
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVisibilityPicker(
    BuildContext context,
    WidgetRef ref,
    String currentVis,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final visOptions = [
      {
        'key': 'PRIVATE',
        'title': 'Chỉ mình tôi (Riêng tư)',
        'subtitle': 'Mặc định không chia sẻ khoảnh khắc chi tiêu lên Bảng tin',
        'icon': Icons.lock_outline_rounded,
      },
      {
        'key': 'FRIENDS',
        'title': 'Bạn bè (Friends & Locket)',
        'subtitle': 'Chia sẻ với bạn bè trong danh sách và nhận phản hồi tin nhắn',
        'icon': Icons.people_outline_rounded,
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    children: [
                      Text(
                        'Quyền riêng tư bài đăng mặc định',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 20, color: muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: visOptions.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: border),
                  itemBuilder: (c, i) {
                    final item = visOptions[i];
                    final key = item['key'] as String;
                    final title = item['title'] as String;
                    final subtitle = item['subtitle'] as String;
                    final icon = item['icon'] as IconData;
                    final isSelected = key == currentVis.toUpperCase();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isSelected
                          ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                          : Colors.transparent,
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? AppColors.primary : foreground,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (!isSelected) {
                          try {
                            await ref
                                .read(generalSettingsProvider.notifier)
                                .updateGeneral(defaultTransactionVisibility: key);
                            if (context.mounted) {
                              AppToast.success(context, 'Đã cập nhật quyền riêng tư mặc định: $title');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(context, e);
                            }
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showModelPicker(
    BuildContext context,
    WidgetRef ref,
    String? currentModel,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    const models = [
      {
        'id': 'gemini-1.5-flash',
        'name': 'Gemini 1.5 Flash (Mặc định)',
        'desc': 'Tối ưu tốc độ cao, nhận diện hóa đơn cực nhanh & miễn phí hạn mức',
      },
      {
        'id': 'gemini-2.0-flash',
        'name': 'Gemini 2.0 Flash (Thế hệ mới)',
        'desc': 'Mô hình thế hệ mới nhất của Google với tốc độ xử lý siêu tốc',
      },
      {
        'id': 'gemini-1.5-pro',
        'name': 'Gemini 1.5 Pro (Chuyên sâu)',
        'desc': 'Khả năng tư duy logic và phân tích xu hướng tài chính chuyên sâu',
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Chọn mô hình Google Gemini',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 20, color: muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: models.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: border),
                  itemBuilder: (c, i) {
                    final item = models[i];
                    final modelId = item['id']!;
                    final modelName = item['name']!;
                    final modelDesc = item['desc']!;
                    final isSelected = (currentModel == null && i == 0) || currentModel == modelId;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isSelected
                          ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                          : Colors.transparent,
                      title: Text(
                        modelName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? AppColors.primary : foreground,
                        ),
                      ),
                      subtitle: Text(
                        modelDesc,
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (!isSelected) {
                          try {
                            await ref
                                .read(aiSettingsProvider.notifier)
                                .updateAiSettings(model: modelId);
                            if (context.mounted) {
                              AppToast.success(context, 'Đã chọn mô hình: $modelId');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(context, e);
                            }
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApiKeySheet(
    BuildContext context,
    WidgetRef ref,
    String? currentKey,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final keyCtrl = TextEditingController();
    bool obscure = true;
    bool isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final viewInsets = MediaQuery.of(modalCtx).viewInsets;

            return Padding(
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: muted.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF0284C7),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thiết lập Gemini API Key cá nhân',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: foreground,
                                    ),
                                  ),
                                  Text(
                                    'Dành cho: Google Gemini API (Miễn phí 100%)',
                                    style: TextStyle(fontSize: 12, color: muted),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close_rounded, size: 20, color: muted),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline_rounded,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Cách lấy Google Gemini API Key miễn phí:',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: foreground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '1. Truy cập https://aistudio.google.com/app/apikey\n'
                                '2. Đăng nhập tài khoản Google và chọn "Create API key"\n'
                                '3. Sao chép và dán khóa (bắt đầu bằng AIzaSy...)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nhập Google Gemini API Key:',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: keyCtrl,
                          obscureText: obscure,
                          autofocus: true,
                          style: TextStyle(fontSize: 13.5, color: foreground, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: 'AIzaSy...',
                            hintStyle: TextStyle(fontSize: 13, color: muted),
                            filled: true,
                            fillColor: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                size: 18,
                                color: muted,
                              ),
                              onPressed: () => setModalState(() => obscure = !obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: AppColors.success),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Khóa được mã hóa bảo mật và chỉ dùng riêng cho tài khoản của bạn.',
                                style: TextStyle(fontSize: 11.5, color: muted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final val = keyCtrl.text.trim();
                                    if (val.isEmpty) {
                                      AppToast.warning(context, 'Vui lòng nhập API Key');
                                      return;
                                    }
                                    setModalState(() => isSaving = true);
                                    try {
                                      await ref
                                          .read(aiSettingsProvider.notifier)
                                          .updateAiSettings(provider: 'GEMINI', apiKey: val);
                                      if (context.mounted) {
                                        Navigator.pop(ctx);
                                        AppToast.success(context, 'Đã lưu Google Gemini API Key thành công!');
                                      }
                                    } catch (e) {
                                      setModalState(() => isSaving = false);
                                      if (context.mounted) {
                                        AppToast.error(context, e);
                                      }
                                    }
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Lưu Gemini API Key',
                                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTextDialog(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: foreground)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(fontSize: 13.5, color: muted, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final settingsAsync = ref.watch(generalSettingsProvider);
    final aiSettingsAsync = ref.watch(aiSettingsProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: PageHeader.subPage(
        title: 'Cài đặt chung',
        subtitle: 'Tiền tệ, ngôn ngữ, AI & hiển thị giao dịch',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: settingsAsync.when(
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
                  'Không thể tải cài đặt chung',
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
                  onPressed: () => ref.invalidate(generalSettingsProvider),
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
        data: (settings) {
          final notifier = ref.read(generalSettingsProvider.notifier);

          final currencyMatch = supportedCurrencies.firstWhere(
            (c) => c['code'] == settings.defaultCurrency,
            orElse: () => {'code': settings.defaultCurrency, 'name': 'Tiền tệ', 'symbol': settings.defaultCurrency},
          );

          final langLabel = settings.language.toLowerCase() == 'en' ? 'English (US)' : 'Tiếng Việt';
          final langFlag = settings.language.toLowerCase() == 'en' ? '🇺🇸' : '🇻🇳';

          final visLabel = settings.defaultTransactionVisibility == 'FRIENDS'
              ? 'Bạn bè (Friends)'
              : 'Chỉ mình tôi (Riêng tư)';

          final aiSettings = aiSettingsAsync.valueOrNull ?? const AiSettings();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // ── 1. BẢN ĐỊA HÓA & TIỀN TỆ ──
              FormCard(
                title: 'Bản địa hóa & Tiền tệ',
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _showCurrencyPicker(context, ref, settings.defaultCurrency),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _buildIconBadge(
                              icon: Icons.currency_exchange_rounded,
                              color: const Color(0xFF0284C7),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đơn vị tiền tệ chính',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Đơn vị gốc hiển thị trên ví, ngân sách & báo cáo',
                                    style: TextStyle(fontSize: 12, color: muted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${currencyMatch['code']} (${currencyMatch['symbol']})',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 18),
                    InkWell(
                      onTap: () => _showLanguagePicker(context, ref, settings.language),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _buildIconBadge(
                              icon: Icons.language_rounded,
                              color: const Color(0xFF8B5CF6),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ngôn ngữ hiển thị',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ngôn ngữ toàn bộ giao diện Finora',
                                    style: TextStyle(fontSize: 12, color: muted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(langFlag, style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 5),
                                  Text(
                                    langLabel,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: foreground,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_drop_down_rounded, size: 18, color: muted),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. CẤU HÌNH MÔ HÌNH AI & API KEY (GOOGLE GEMINI) ──
              FormCard(
                title: 'Mô hình AI & API Key (Google Gemini)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Badge (Google Gemini Only)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Google Gemini AI',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Trợ lý tài chính thông minh của Finora',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Miễn phí',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),

                    // Model Selector
                    InkWell(
                      onTap: () => _showModelPicker(
                        context,
                        ref,
                        aiSettings.model,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _buildIconBadge(
                              icon: Icons.memory_rounded,
                              color: const Color(0xFF6366F1),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mô hình Gemini (Model)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    aiSettings.model ?? 'gemini-1.5-flash (Mặc định)',
                                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_drop_down_rounded, size: 20, color: muted),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),

                    // API Key Status & Actions (BYOK)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: aiSettings.hasCustomApiKey
                            ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08)
                            : (isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: aiSettings.hasCustomApiKey
                              ? const Color(0xFF10B981).withValues(alpha: 0.35)
                              : border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                aiSettings.hasCustomApiKey ? Icons.verified_rounded : Icons.cloud_done_rounded,
                                size: 18,
                                color: aiSettings.hasCustomApiKey ? const Color(0xFF10B981) : muted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  aiSettings.hasCustomApiKey
                                      ? 'Đang dùng API Key riêng của bạn'
                                      : 'Đang dùng API Key mặc định của Finora',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: aiSettings.hasCustomApiKey ? const Color(0xFF10B981) : foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (aiSettings.hasCustomApiKey && aiSettings.maskedApiKey != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: border),
                              ),
                              child: Text(
                                'Key: ${aiSettings.maskedApiKey}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 4),
                            Text(
                              'Nhập API Key cá nhân để thoải mái hỏi đáp AI và phân tích hoá đơn không giới hạn số lượt mỗi ngày.',
                              style: TextStyle(fontSize: 11.5, color: muted, height: 1.35),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showApiKeySheet(
                                    context,
                                    ref,
                                    aiSettings.maskedApiKey,
                                  ),
                                  icon: Icon(
                                    aiSettings.hasCustomApiKey ? Icons.edit_rounded : Icons.add_rounded,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  label: Text(
                                    aiSettings.hasCustomApiKey ? 'Đổi API Key' : 'Thêm API Key riêng',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    side: const BorderSide(color: AppColors.primary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              if (aiSettings.hasCustomApiKey) ...[
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () async {
                                    final confirmed = await showConfirmDialog(
                                      context,
                                      title: 'Xóa API Key riêng?',
                                      message:
                                          'Hệ thống sẽ chuyển về sử dụng API Key mặc định của Finora.',
                                      confirmText: 'Xóa Key',
                                    );
                                    if (confirmed == true && context.mounted) {
                                      try {
                                        await ref
                                            .read(aiSettingsProvider.notifier)
                                            .deleteApiKey();
                                        if (context.mounted) {
                                          AppToast.success(context, 'Đã chuyển về dùng API Key mặc định');
                                        }
                                      } catch (e) {
                                        if (context.mounted) AppToast.error(context, e);
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.danger),
                                  label: const Text(
                                    'Xóa Key',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.danger),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3. QUYỀN RIÊNG TƯ & HIỂN THỊ ──
              FormCard(
                title: 'Quyền riêng tư & Hiển thị',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: _buildIconBadge(
                        icon: Icons.visibility_off_rounded,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                      title: Text(
                        'Mặc định ẩn số tiền',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        'Tự động che số dư bằng •••••• khi mở ứng dụng ở nơi công cộng',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      value: settings.defaultAmountHidden,
                      onChanged: (val) async {
                        try {
                          await notifier.updateGeneral(defaultAmountHidden: val);
                        } catch (e) {
                          if (context.mounted) {
                            AppToast.error(context, e);
                          }
                        }
                      },
                    ),
                    const Divider(height: 18),
                    InkWell(
                      onTap: () => _showVisibilityPicker(context, ref, settings.defaultTransactionVisibility),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _buildIconBadge(
                              icon: Icons.share_rounded,
                              color: const Color(0xFF10B981),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quyền riêng tư bài đăng mặc định',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Phạm vi chia sẻ khi ghi chép giao dịch khoảnh khắc',
                                    style: TextStyle(fontSize: 12, color: muted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    visLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: foreground,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_drop_down_rounded, size: 18, color: muted),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 4. DỮ LIỆU & BỘ NHỚ ĐỆM ──
              FormCard(
                title: 'Dữ liệu & Bộ nhớ',
                child: InkWell(
                  onTap: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: 'Xóa bộ nhớ đệm?',
                      message:
                          'Hành động này sẽ giải phóng dung lượng ảnh hóa đơn, ảnh đại diện đã tải tạm thời. Dữ liệu tài chính của bạn hoàn toàn an toàn.',
                      confirmText: 'Xóa ngay',
                    );
                    if (confirmed == true && context.mounted) {
                      PaintingBinding.instance.imageCache.clear();
                      PaintingBinding.instance.imageCache.clearLiveImages();
                      AppToast.success(context, 'Đã giải phóng bộ nhớ đệm thành công!');
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        _buildIconBadge(
                          icon: Icons.cleaning_services_rounded,
                          color: const Color(0xFFEC4899),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xóa bộ nhớ đệm (Clear Cache)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dọn dẹp ảnh tạm thời để ứng dụng hoạt động nhẹ nhàng hơn',
                                style: TextStyle(fontSize: 12, color: muted),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: muted, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 5. THÔNG TIN ỨNG DỤNG & PHÁP LÝ ──
              FormCard(
                title: 'Thông tin ứng dụng',
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          _buildIconBadge(
                            icon: Icons.info_outline_rounded,
                            color: const Color(0xFF64748B),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phiên bản ứng dụng',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: foreground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'FINORA Mobile v1.0.0 (Build 2026.11)',
                                  style: TextStyle(fontSize: 12, color: muted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Mới nhất',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 18),
                    InkWell(
                      onTap: () => _showTextDialog(
                        context,
                        'Chính sách bảo mật',
                        'Finora cam kết bảo vệ dữ liệu cá nhân và tài chính của người dùng theo tiêu chuẩn an toàn cao nhất.\n\n'
                        '1. Thu thập dữ liệu: Dữ liệu giao dịch, ví và ngân sách chỉ được dùng để phân tích tài chính cho chính bạn.\n'
                        '2. Mã hóa: Mật khẩu và mã PIN được mã hóa 1 chiều bằng thuật toán an toàn bcrypt.\n'
                        '3. Chia sẻ dữ liệu: Finora không bao giờ bán thông tin cá nhân hoặc lịch sử chi tiêu cho bên thứ ba.\n'
                        '4. Quyền riêng tư: Bạn có toàn quyền thiết lập chế độ riêng tư hoặc xóa tài khoản vĩnh viễn bất kỳ lúc nào.',
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _buildIconBadge(
                              icon: Icons.privacy_tip_outlined,
                              color: const Color(0xFF0D9488),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Chính sách bảo mật dữ liệu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: muted, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 18),
                    InkWell(
                      onTap: () => _showTextDialog(
                        context,
                        'Điều khoản dịch vụ',
                        'Chào mừng bạn đến với Finora - Trợ lý quản lý tài chính thông minh.\n\n'
                        '1. Điều kiện sử dụng: Người dùng chịu trách nhiệm về tính chính xác của các giao dịch đã nhập.\n'
                        '2. Dịch vụ AI & Mascot: Linh vật đưa ra các gợi ý tham khảo dựa trên quy tắc quản lý chi tiêu và không chịu trách nhiệm cho các quyết định đầu tư thực tế.\n'
                        '3. Hoạt động cộng đồng: Tôn trọng người khác trên Bảng tin khoảnh khắc, không đăng tải nội dung vi phạm pháp luật hoặc quấy rối bạn bè.',
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _buildIconBadge(
                              icon: Icons.description_outlined,
                              color: const Color(0xFFF97316),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Điều khoản dịch vụ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: muted, size: 20),
                          ],
                        ),
                      ),
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
