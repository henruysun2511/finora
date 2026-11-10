import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:finora_mb/app/theme/app_colors.dart';
import 'package:finora_mb/core/widgets/lucide_icon.dart';
import 'package:finora_mb/core/widgets/page_header.dart';

class SocialChatScreen extends StatelessWidget {
  const SocialChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const PageHeader.subPage(
        title: 'Tin nhắn Locket Chat',
        subtitle: 'Nhắn tin & chia sẻ giao dịch',
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
                  name: 'message-circle',
                  color: AppColors.primary,
                  size: 32,
                  strokeWidth: 2.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tin nhắn Locket Chat',
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
                'Nhắn tin trò chuyện tài chính tế nhị kèm chia sẻ giao dịch (/social-chat)',
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
