import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_progress_indicator.dart';

/// Bước 5 Onboarding: Hoàn tất thiết lập & Kích hoạt tài khoản
/// Đồng bộ 100% với static-ui/device-preview/screens/onboarding/all-set.html
class OnboardingAllSetScreen extends ConsumerStatefulWidget {
  const OnboardingAllSetScreen({super.key});

  @override
  ConsumerState<OnboardingAllSetScreen> createState() =>
      _OnboardingAllSetScreenState();
}

class _OnboardingAllSetScreenState extends ConsumerState<OnboardingAllSetScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final List<_ConfettiParticle> _particles;
  bool _isLoading = false;

  final _currencyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    final rnd = math.Random();
    final colors = [
      AppColors.primary,
      const Color(0xFF48BB78),
      const Color(0xFFED8936),
      const Color(0xFFEC4899),
      const Color(0xFFB7791F),
      const Color(0xFF38BDF8),
      const Color(0xFFFACC15),
    ];

    _particles = List.generate(60, (_) {
      return _ConfettiParticle(
        x: rnd.nextDouble(),
        y: rnd.nextDouble() * 1.5 - 0.5,
        size: rnd.nextDouble() * 7 + 4,
        speed: rnd.nextDouble() * 0.8 + 0.4,
        color: colors[rnd.nextInt(colors.length)],
        angle: rnd.nextDouble() * math.pi * 2,
        rotSpeed: rnd.nextDouble() * 2 - 1,
      );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _onFinish() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
      if (mounted) {
        context.go(RoutePaths.home);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = ref.watch(onboardingControllerProvider);
    final mascot = data.assignedMascot;
    final mascotColor = Color(
      int.parse(mascot.colorHex.replaceFirst('#', '0xFF')),
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ── Background Festive Gradient ───────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0F172A),
                          AppColors.darkBackground,
                        ]
                      : [
                          const Color(0xFFF0FDF4),
                          Colors.white,
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Confetti Particle Canvas ──────────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _confettiController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Main Content Layout ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // ── Mascot Celebrate Stage ──────────────────────────
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mascotColor.withValues(
                              alpha: isDark ? 0.25 : 0.12,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: mascotColor.withValues(
                                  alpha: isDark ? 0.35 : 0.2,
                                ),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: MascotWidget(
                              mascot: mascot,
                              mode: MascotMode.avatar,
                              size: 110,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Congrats Speech Bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.05,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.45,
                                color: isDark
                                    ? AppColors.darkForeground
                                    : const Color(0xFF1E293B),
                              ),
                              children: [
                                const TextSpan(text: 'Tuyệt vời '),
                                TextSpan(
                                  text: data.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(text: '! Mình là '),
                                TextSpan(
                                  text: '${mascot.name} (${mascot.role})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: mascotColor,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      ', sẵn sàng đồng hành cùng bạn trên con đường tự do tài chính! 🚀',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title & Subtitle
                        Text(
                          'Tất cả đã sẵn sàng! 🎉',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            color: isDark
                                ? AppColors.darkForeground
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hồ sơ và nguồn tiền của bạn đã được thiết lập thành công.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.darkMuted
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Summary Box (.summary-box) ──────────────────────
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.04,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                label: 'Chủ tài khoản:',
                                value: data.name,
                                isDark: isDark,
                              ),
                              const Divider(height: 20),
                              _buildSummaryRow(
                                label: 'Ví & Nguồn tiền:',
                                value:
                                    '${data.walletName} (${data.walletTypeLabel})',
                                isDark: isDark,
                              ),
                              const Divider(height: 20),
                              _buildSummaryRow(
                                label: 'Số dư khởi điểm:',
                                value:
                                    '${_currencyFormat.format(data.balance.toInt())} ₫',
                                isDark: isDark,
                                isHighlight: true,
                              ),
                              const Divider(height: 20),
                              _buildSummaryRow(
                                label: 'Trợ lý AI đồng hành:',
                                value:
                                    '${mascot.name} (${mascot.tier} · ${data.mascotTone.label})',
                                isDark: isDark,
                                customColor: mascotColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer Flow ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const OnboardingProgressIndicator(currentStep: 5),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onFinish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Vào Finora ngay',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const LucideIcon(
                                      name: LucideIcons.arrowUpRight,
                                      size: 19,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {
                          context.go(RoutePaths.onboardingWelcome);
                        },
                        child: Text(
                          'Thiết lập lại từ đầu',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkMuted
                                : const Color(0xFF64748B),
                          ),
                        ),
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

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required bool isDark,
    bool isHighlight = false,
    Color? customColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: customColor ??
                  (isHighlight
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.darkForeground
                          : const Color(0xFF0F172A))),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.angle,
    required this.rotSpeed,
  });

  final double x;
  double y;
  final double size;
  final double speed;
  final Color color;
  double angle;
  final double rotSpeed;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = ((p.y + progress * p.speed) % 1.2) * size.height;
      final currentX = (p.x + math.sin(progress * math.pi * 2 + p.angle) * 0.05) * size.width;
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.angle + progress * p.rotSpeed * math.pi * 2);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
