import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Thanh tiến độ 5 nấc phân đoạn chuẩn FinTech (.ob-progress)
class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    this.isLightSurface = false,
  });

  final int currentStep;
  final int totalSteps;

  /// Đặt true khi thanh tiến độ nằm trên nền tối / nền xanh thương hiệu
  final bool isLightSurface;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;

        Color activeColor;
        Color inactiveColor;

        if (isLightSurface) {
          activeColor = Colors.white;
          inactiveColor = Colors.white.withValues(alpha: 0.28);
        } else {
          activeColor = AppColors.primary;
          inactiveColor = isDark
              ? AppColors.darkBorder
              : const Color(0xFFE2E8F0);
        }

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < totalSteps - 1 ? 6.0 : 0.0,
            ),
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

