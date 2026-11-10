import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../screens/mascot_showcase_screen.dart';

class MascotProfileDetailPanel extends StatelessWidget {
  const MascotProfileDetailPanel({
    super.key,
    required this.mascot,
    required this.isCurrentCompanion,
  });

  final MascotData mascot;
  final bool isCurrentCompanion;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(mascot.id),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Spotlight Header với Gradient ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    mascot.color.withValues(alpha: isDark ? 0.22 : 0.12),
                    isDark ? AppColors.darkSurface : Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(23)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: mascot.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: MascotWidget(
                      mascotId: mascot.id,
                      mode: MascotMode.avatar,
                      size: 82,
                      float: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              mascot.name,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground,
                              ),
                            ),
                            if (isCurrentCompanion) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ĐANG ĐỒNG HÀNH',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: mascot.color,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            mascot.role,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mốc tài sản ròng: ${mascot.range}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body Chi tiết ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: 'smile',
                    title: 'TÍNH CÁCH & VĂN PHONG',
                    content: mascot.personality,
                    accentColor: mascot.color,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: 'landmark',
                    title: 'TRIẾT LÝ TÀI CHÍNH',
                    content: mascot.finance,
                    accentColor: mascot.color,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: 'bot',
                    title: 'PHƯƠNG PHÁP TƯ VẤN',
                    content: mascot.advice,
                    accentColor: mascot.color,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'CÂU THOẠI ĐẶC TRƯNG',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (mascot.q1.isNotEmpty)
                    _buildQuoteBox(mascot.q1, mascot.color, isDark),
                  if (mascot.q2.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildQuoteBox(mascot.q2, mascot.color, isDark),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String icon,
    required String title,
    required String content,
    required Color accentColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            LucideIcon(name: icon, size: 14, color: accentColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteBox(String quote, Color accentColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Text(
        '"$quote"',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

