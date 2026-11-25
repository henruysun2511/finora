import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../widgets/onboarding_progress_indicator.dart';

/// Bước 1 Onboarding: Chào mừng & Giới thiệu Nora AI
/// Đồng bộ 100% với static-ui/device-preview/screens/onboarding/welcome.html
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0072D5), // Primary solid
      body: Stack(
        children: [
          // ── Ambient Background Glow & Rings ─────────────────────────────────
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 140,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // ── Main Content Layout ───────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top status bar placeholder space
                const SizedBox(height: 16),

                // ── Hero Section: Nora Mascot & Slogan ──────────────────────
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Hào quang tỏa sáng quanh Nora
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    blurRadius: 36,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: MascotWidget(
                                  mascot: MascotRegistry.nora,
                                  mode: MascotMode.avatar,
                                  size: 140,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Tên định danh
                            Text(
                              'Nora',
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Slogan
                            Text(
                              'Quản lý chi tiêu thông minh bằng giọng nói & AI',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Bottom Sheet Trượt lên (.ob-sheet) ───────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Thanh tiến độ 5 nấc
                      const OnboardingProgressIndicator(currentStep: 1),
                      const SizedBox(height: 20),

                      // Tiêu đề
                      Text(
                        'Nói là xong — Nora hiểu',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark
                              ? AppColors.darkForeground
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Nội dung mô tả
                      Text(
                        '"Ăn sáng 40k, grab đi làm 35k" — chỉ cần nhắn thế, Nora lo phần còn lại. Khám phá 7 trợ lý AI đồng hành cá nhân hóa theo từng cấp bậc tài chính của bạn.',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: isDark
                              ? AppColors.darkMuted
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nút Bắt đầu ngay
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(RoutePaths.onboardingProfile);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child: Text(
                                'Bắt đầu ngay',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                              const SizedBox(width: 8),
                              const LucideIcon(
                                name: LucideIcons.arrowUpRight,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Link Đăng nhập
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 0,
                        runSpacing: 2,
                        children: [
                          Text(
                            'Đã có tài khoản? ',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go(RoutePaths.login);
                            },
                            child: Text(
                              'Đăng nhập',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
