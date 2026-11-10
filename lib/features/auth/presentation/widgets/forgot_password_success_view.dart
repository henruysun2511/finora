import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import 'auth_gradient_button.dart';

class ForgotPasswordSuccessView extends StatelessWidget {
  const ForgotPasswordSuccessView({
    super.key,
    required this.onLoginPressed,
  });

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 46,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Đổi mật khẩu thành công!',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tài khoản Finora của bạn đã được cập nhật mật khẩu mới. Bạn có thể đăng nhập ngay bây giờ.',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 26),
        AuthGradientButton(
          label: 'ĐĂNG NHẬP NGAY',
          icon: Icons.login_rounded,
          isLoading: false,
          onPressed: onLoginPressed,
        ),
      ],
    );
  }
}

