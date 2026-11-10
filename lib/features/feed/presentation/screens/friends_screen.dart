import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:finora_mb/app/theme/app_colors.dart';
import 'package:finora_mb/core/widgets/lucide_icon.dart';
import 'package:finora_mb/core/widgets/page_header.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const PageHeader.subPage(
        title: 'Bạn bè & Kết nối',
        subtitle: 'Quản lý kết nối & danh sách bạn bè',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const LucideIcon(
                  name: 'user-plus',
                  color: AppColors.primary,
                  size: 32,
                  strokeWidth: 2.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn bè & Kết nối',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Quản lý danh sách bạn bè kết nối trong hệ sinh thái Finora (/friends)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
