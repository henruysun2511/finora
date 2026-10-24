import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AmountQuickSelector extends StatelessWidget {
  final List<double> increments;
  final ValueChanged<double> onSelected;

  const AmountQuickSelector({
    super.key,
    this.increments = const [
      50000,
      100000,
      200000,
      500000,
      1000000,
      2000000,
      5000000,
    ],
    required this.onSelected,
  });

  String _formatChipLabel(double val) {
    if (val >= 1000000) {
      final m = val / 1000000;
      return '+${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
    final k = val / 1000;
    return '+${k.toStringAsFixed(0)}k';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: increments.map((amount) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelected(amount),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Text(
                  _formatChipLabel(amount),
                  style: AppTextStyles.labelSmall(
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
