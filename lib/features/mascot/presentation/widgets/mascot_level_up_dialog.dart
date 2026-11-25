import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../../../core/widgets/mascot/mascot_widget.dart';

/// Hộp thoại chúc mừng thăng hạng Linh vật AI (Mascot Level-Up Celebration)
/// Hiển thị mascot mới với hình ảnh vector, hào quang, hiệu ứng pháo hoa hạt và câu thoại đặc trưng.
class MascotLevelUpDialog extends StatefulWidget {
  final String tierName;
  final String? previousTierName;
  final String? customMessage;
  final double? netWorth;

  const MascotLevelUpDialog({
    super.key,
    required this.tierName,
    this.previousTierName,
    this.customMessage,
    this.netWorth,
  });

  /// Hàm tiện ích mở popup thăng hạng từ bất kỳ đâu trong ứng dụng
  static Future<void> show(
    BuildContext context, {
    required String tierName,
    String? previousTierName,
    String? customMessage,
    double? netWorth,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => MascotLevelUpDialog(
        tierName: tierName,
        previousTierName: previousTierName,
        customMessage: customMessage,
        netWorth: netWorth,
      ),
    );
  }

  @override
  State<MascotLevelUpDialog> createState() => _MascotLevelUpDialogState();
}

class _MascotLevelUpDialogState extends State<MascotLevelUpDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _particlesAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    _particlesAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mascot = MascotRegistry.get(widget.tierName);
    final prevMascot = widget.previousTierName != null
        ? MascotRegistry.get(widget.previousTierName!)
        : null;

    final quote = mascot.bubble.isNotEmpty
        ? mascot.bubble
        : (mascot.q1.isNotEmpty ? mascot.q1 : 'Chào mừng bạn đến với tầm cao tài chính mới!');

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ──────────────── 1. CELEBRATION PARTICLES LAYER ────
            AnimatedBuilder(
              animation: _particlesAnimation,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(360, 480),
                  painter: _ConfettiParticlesPainter(
                    progress: _particlesAnimation.value,
                    primaryColor: mascot.color,
                    accentColor: mascot.accent,
                  ),
                );
              },
            ),

            // ──────────────── 2. MAIN CARD ──────────────────────
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D31) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: mascot.color.withValues(alpha: 0.35),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: mascot.color.withValues(alpha: 0.25),
                    blurRadius: 36,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    // Ambient radial glow behind mascot
                    Positioned(
                      top: -40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                mascot.color.withValues(alpha: 0.25),
                                mascot.color.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content Body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Lời chúc mừng mở khóa linh vật mới ──
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.28,
                                letterSpacing: -0.2,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              children: [
                                const TextSpan(text: 'Chúc mừng bạn\n'),
                                TextSpan(
                                  text: 'mở khóa linh vật mới',
                                  style: TextStyle(color: mascot.color),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── MASCOT AVATAR HERO ──
                          SizedBox(
                            height: 140,
                            child: MascotWidget(
                              mascot: mascot,
                              mode: MascotMode.avatar,
                              size: 135,
                              float: true,
                              interactive: true,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── TÊN VÀ DANH XƯNG LINH VẬT ──
                          Text(
                            mascot.name,
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mascot.role,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: mascot.color,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ── MỐC TÀI CHÍNH ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Cột mốc: ${mascot.range}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── BƯỚC CHUYỂN TIẾN HÓA (nếu có prevMascot) ──
                          if (prevMascot != null && prevMascot.id != mascot.id) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBackground
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      prevMascot.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkMuted
                                            : AppColors.lightMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      mascot.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: mascot.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // ── LỜI CHÚC MỪNG & PHÁT BIỂU CỦA MASCOT ──
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: mascot.accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: mascot.accent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              widget.customMessage ?? '“$quote”',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.95)
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── ACTION BUTTONS ──
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mascot.color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'TUYỆT VỜI, TIẾP TỤC!',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push(
                                '${RoutePaths.mascotShowcase}?id=${mascot.id}',
                              );
                            },
                            child: Text(
                              'Xem hồ sơ ${mascot.name} →',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: mascot.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter vẽ các hạt pháo hoa lấp lánh xung quanh dialog
class _ConfettiParticlesPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color accentColor;

  _ConfettiParticlesPainter({
    required this.progress,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final rnd = math.Random(42);

    final colors = [
      primaryColor,
      accentColor,
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];

    const count = 36;
    for (int i = 0; i < count; i++) {
      final angle = (i * (2 * math.pi / count)) + (rnd.nextDouble() * 0.2);
      final maxDist = 130 + rnd.nextDouble() * 80;
      final dist = maxDist * progress;

      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist;

      final paint = Paint()
        ..color = colors[i % colors.length]
            .withValues(alpha: (1.0 - progress * 0.7).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final particleSize = 3.5 + rnd.nextDouble() * 4.0;

      if (i % 3 == 0) {
        // Star particle
        canvas.drawCircle(Offset(x, y), particleSize * 0.7, paint);
      } else if (i % 3 == 1) {
        // Rect particle
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * math.pi);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particleSize * 1.6,
            height: particleSize * 0.9,
          ),
          paint,
        );
        canvas.restore();
      } else {
        // Dot particle
        canvas.drawCircle(Offset(x, y), particleSize * 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

