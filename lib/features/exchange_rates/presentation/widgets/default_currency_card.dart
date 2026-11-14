import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../settings/presentation/providers/user_settings_provider.dart';
import '../../domain/models/currency_item.dart';
import 'currency_picker_bottom_sheet.dart';

class DefaultCurrencyCard extends ConsumerWidget {
  const DefaultCurrencyCard({super.key});

  Future<void> _handlePickCurrency(
      BuildContext context, WidgetRef ref, String currentCode) async {
    final picked = await CurrencyPickerBottomSheet.show(
      context: context,
      selectedCode: currentCode,
      title: 'Chọn tiền tệ mặc định',
    );

    if (picked != null && picked.code != currentCode) {
      try {
        await ref
            .read(defaultCurrencyProvider.notifier)
            .updateCurrency(picked.code);
        if (context.mounted) {
          AppToast.show(
            context,
            message:
                'Đã đổi tiền tệ mặc định sang ${picked.code} (${picked.name})',
            type: ToastType.success,
          );
        }
      } catch (_) {
        if (context.mounted) {
          AppToast.show(
            context,
            message: 'Không thể cập nhật cài đặt tiền tệ. Vui lòng thử lại.',
            type: ToastType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyAsync = ref.watch(defaultCurrencyProvider);
    final currencyCode = currencyAsync.value ?? 'VND';
    final currentItem = CurrencyItem.findByCode(currencyCode);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return FormCard(
      title: 'Cài đặt tiền tệ mặc định',
      child: InkWell(
        onTap: () => _handlePickCurrency(context, ref, currencyCode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                alignment: Alignment.center,
                child: Text(
                  currentItem.flagEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${currentItem.code} - ${currentItem.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currentItem.symbol,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tiền tệ cơ sở quy đổi tài sản ròng và linh vật',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Text(
                      'Đổi',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
