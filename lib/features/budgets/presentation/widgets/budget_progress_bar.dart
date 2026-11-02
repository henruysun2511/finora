import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/budget_enums.dart';

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.height = 8.0,
    this.borderRadius = 8.0,
  });

  final double percentage;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final status = BudgetProgressStatus.fromPercentage(percentage);
    final clampedRatio = (percentage / 100.0).clamp(0.0, 1.0);

    Color progressColor;
    switch (status) {
      case BudgetProgressStatus.safe:
        progressColor = AppColors.success;
        break;
      case BudgetProgressStatus.warning:
        progressColor = AppColors.warning;
        break;
      case BudgetProgressStatus.exceeded:
        progressColor = AppColors.danger;
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedRatio,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

