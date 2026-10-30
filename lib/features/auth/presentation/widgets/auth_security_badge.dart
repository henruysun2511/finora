import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Huy hiệu cam kết bảo mật tài chính chuẩn device-preview
class AuthSecurityBadge extends StatelessWidget {
  const AuthSecurityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_rounded,
          size: 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Bảo mật mã hóa đầu cuối với JWT & AES-256',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
