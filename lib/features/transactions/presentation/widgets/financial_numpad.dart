import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

class FinancialNumPad extends StatelessWidget {
  const FinancialNumPad({
    super.key,
    required this.onKeyPress,
    required this.onSubmit,
  });

  final ValueChanged<String> onKeyPress;
  final VoidCallback onSubmit;

  Widget _buildKey(
    BuildContext context, {
    required String label,
    IconData? icon,
    Color? color,
    Color? bgColor,
    VoidCallback? onTap,
    bool isAction = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark
        ? AppColors.darkSurface
        : Colors.white;
    final defaultFg = isDark
        ? AppColors.darkForeground
        : AppColors.lightForeground;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: bgColor ?? defaultBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isAction ? Colors.transparent : border.withValues(alpha: 0.6),
            ),
          ),
          elevation: isDark ? 0 : (isAction ? 2 : 0.5),
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onTap != null) {
                onTap();
              } else {
                onKeyPress(label);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(
                      icon,
                      size: 22,
                      color: color ?? defaultFg,
                    )
                  : Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: label == '000' ? 18 : 22,
                        fontWeight: FontWeight.w700,
                        color: color ?? defaultFg,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hàng 1: 1, 2, 3, ⌫
        Row(
          children: [
            _buildKey(context, label: '1'),
            _buildKey(context, label: '2'),
            _buildKey(context, label: '3'),
            _buildKey(
              context,
              label: '⌫',
              icon: Icons.backspace_outlined,
              color: AppColors.danger,
              onTap: () => onKeyPress('⌫'),
            ),
          ],
        ),

        // Hàng 2: 4, 5, 6, +
        Row(
          children: [
            _buildKey(context, label: '4'),
            _buildKey(context, label: '5'),
            _buildKey(context, label: '6'),
            _buildKey(
              context,
              label: '+',
              icon: Icons.add_rounded,
              color: AppColors.primary,
            ),
          ],
        ),

        // Hàng 3: 7, 8, 9, -
        Row(
          children: [
            _buildKey(context, label: '7'),
            _buildKey(context, label: '8'),
            _buildKey(context, label: '9'),
            _buildKey(
              context,
              label: '-',
              icon: Icons.remove_rounded,
              color: AppColors.primary,
            ),
          ],
        ),

        // Hàng 4: 000, 0, ., ✓
        Row(
          children: [
            _buildKey(context, label: '000'),
            _buildKey(context, label: '0'),
            _buildKey(context, label: '.'),
            _buildKey(
              context,
              label: '✓',
              icon: Icons.check_rounded,
              color: Colors.white,
              bgColor: AppColors.primary,
              isAction: true,
              onTap: onSubmit,
            ),
          ],
        ),
      ],
    );
  }
}

