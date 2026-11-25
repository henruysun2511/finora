import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/forgot_password_state.dart';

class ForgotPasswordStepIndicator extends StatelessWidget {
  const ForgotPasswordStepIndicator({
    super.key,
    required this.currentStep,
  });

  final ForgotPasswordStep currentStep;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int activeIndex;
    switch (currentStep) {
      case ForgotPasswordStep.email:
        activeIndex = 0;
        break;
      case ForgotPasswordStep.otp:
        activeIndex = 1;
        break;
      case ForgotPasswordStep.newPassword:
      case ForgotPasswordStep.success:
        activeIndex = 2;
        break;
    }

    const steps = ['Email', 'Xác thực OTP (30s)', 'Mật khẩu mới'];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final lineIdx = index ~/ 2;
          final isDone = lineIdx < activeIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          );
        }

        final stepIdx = index ~/ 2;
        final isActive = stepIdx == activeIndex;
        final isDone = stepIdx < activeIndex;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone || isActive
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${stepIdx + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isActive
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted),
                        ),
                      ),
              ),
            )),
            const SizedBox(width: 4),
            Flexible(
                child: Text(
              steps[stepIdx],
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? (isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground)
                    : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        );
      }),
    );
  }
}
