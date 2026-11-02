import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Widget hiển thị Avatar chính thức của Trợ lý AI Nora Mascot
///
/// Tự động tải hình ảnh chính thức của hệ thống từ `assets/images/nora.png`,
/// và cung cấp vector fallback giao diện Solarn khi chạy môi trường test
/// hoặc khi tài nguyên chưa tải kịp.
class NoraAvatar extends StatelessWidget {
  const NoraAvatar({
    super.key,
    this.size = 40.0,
    this.backgroundColor,
    this.showGlow = true,
  });

  final double size;
  final Color? backgroundColor;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/nora.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _NoraVectorFallback(size: size),
        ),
      ),
    );
  }
}

/// Fallback vector mô phỏng chính xác khuôn mặt Nora AI Mascot
/// (Thân xanh Solarn, kính màn hình trắng, mắt xanh kỹ thuật số, nụ cười vui vẻ)
class _NoraVectorFallback extends StatelessWidget {
  const _NoraVectorFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.65,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size * 0.12,
                height: size * 0.12,
                decoration: const BoxDecoration(
                  color: Color(0xFF0055A9),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: size * 0.14),
              Container(
                width: size * 0.12,
                height: size * 0.12,
                decoration: const BoxDecoration(
                  color: Color(0xFF0055A9),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

