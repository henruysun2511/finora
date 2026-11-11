import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Thẻ Card chứa form / cài đặt switch theo chuẩn FinTech
/// (Thiết kế đồng bộ với khối 'Cài đặt bổ sung' trong form khoản vay nợ)
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    this.title,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 14),
    this.padding = const EdgeInsets.all(16),
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: margin,
      child: Material(
        color: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null && title!.isNotEmpty) ...[
                Text(
                  title!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Alias tương thích ngược
typedef SolarnFormCard = FormCard;

