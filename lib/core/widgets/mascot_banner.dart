import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'mascot/mascot.dart';

class MascotBanner extends StatelessWidget {
  final String name;
  final String message;
  final String emoji;
  final String? actionText;
  final VoidCallback? onAction;
  final String? mascotId;
  final num? balance;

  const MascotBanner({
    super.key,
    this.name = 'Nora AI',
    required this.message,
    this.emoji = '🤖',
    this.actionText,
    this.onAction,
    this.mascotId,
    this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D33) : const Color(0xFFEFF6FF),
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBFDBFE),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mascot Avatar Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MascotWidget(
                mascotId: mascotId ?? 'nora',
                balance: balance,
                size: 38,
                float: true,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Message & Action
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelSmall(
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                      ).copyWith(fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                    if (actionText != null)
                      GestureDetector(
                        onTap: onAction,
                        child: Text(
                          actionText!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E3A8A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
