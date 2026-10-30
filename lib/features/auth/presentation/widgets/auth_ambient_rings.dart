import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Các vòng phát sáng hào quang (Ambient Glowing Rings) chuẩn 1:1 theo device-preview
class AuthAmbientRings extends StatelessWidget {
  const AuthAmbientRings({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Vòng tròn hào quang lớn phía trên bên phải
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Vòng tròn hổ phách thứ hai phía dưới bên trái
          Positioned(
            top: 240,
            left: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.28),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
