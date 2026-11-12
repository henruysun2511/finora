import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';

class _MascotItem {
  final MascotData mascot;
  final String quote;
  final double scale;
  final double yOffset;
  final double phase;

  const _MascotItem({
    required this.mascot,
    required this.quote,
    required this.scale,
    required this.yOffset,
    required this.phase,
  });
}

// 7 Mascot dàn hàng ngang tự nhiên, đứng vững chãi trên cùng một mặt phẳng sân khấu
const List<_MascotItem> _kWelcomeMascots = [
  _MascotItem(
    mascot: MascotRegistry.ash,
    quote: 'Khoan đã! Bỏ ly trà sữa xuống ngay!',
    scale: 0.94,
    yOffset: 0.0,
    phase: -2.8,
  ),
  _MascotItem(
    mascot: MascotRegistry.penny,
    quote: 'Tích tiểu thành đại, từng đồng đều quý!',
    scale: 0.95,
    yOffset: 0.0,
    phase: -1.9,
  ),
  _MascotItem(
    mascot: MascotRegistry.sage,
    quote: 'Chi tiêu thông thái, mầm non sẽ lớn!',
    scale: 0.96,
    yOffset: 0.0,
    phase: -1.0,
  ),
  _MascotItem(
    mascot: MascotRegistry.nora,
    quote: 'Chào bạn! Cùng mình làm chủ tài chính nhé ✨',
    scale: 1.10,
    yOffset: -3.0,
    phase: 0.0,
  ),
  _MascotItem(
    mascot: MascotRegistry.jade,
    quote: 'Đầu tư sinh lời, vững vàng tương lai!',
    scale: 0.96,
    yOffset: 0.0,
    phase: -1.2,
  ),
  _MascotItem(
    mascot: MascotRegistry.ruby,
    quote: 'Tận hưởng cuộc sống, chi tiêu xứng đáng!',
    scale: 0.95,
    yOffset: 0.0,
    phase: -2.1,
  ),
  _MascotItem(
    mascot: MascotRegistry.bellingham,
    quote: 'Tầm nhìn lớn, tài sản không giới hạn!',
    scale: 0.94,
    yOffset: 0.0,
    phase: -3.0,
  ),
];

/// Màn hình Mở đầu / Chào mừng (Welcome Screen)
/// Khớp 100% pixel-perfect với bản thiết kế `static-ui/device-preview/screens/auth/welcome.html`
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  int _selectedMascotIndex = 3; // Nora ở giữa mặc định
  bool _showBubble = false; // Mặc định ẩn, khi click mascot mới hiện
  Timer? _bubbleTimer;

  late AnimationController _waveController;
  late AnimationController _bounceController;
  int? _bouncingIndex;

  @override
  void initState() {
    super.initState();

    // Hiệu ứng bay bồng bềnh nhẹ nhàng (Floating continuous wave)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();

    // Hiệu ứng nảy (bounce) khi người dùng chạm vào mascot
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    _waveController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTapMascot(int index) {
    setState(() {
      _selectedMascotIndex = index;
      _showBubble = true;
      _bouncingIndex = index;
    });

    _bounceController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _bouncingIndex = null);
    });

    _bubbleTimer?.cancel();
    _bubbleTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _showBubble = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeIndex = (_selectedMascotIndex >= 0 && _selectedMascotIndex < _kWelcomeMascots.length)
        ? _selectedMascotIndex
        : 3;
    final active = _kWelcomeMascots[activeIndex];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ── 1. Vòng tròn đồng tâm viền rõ nét & Soft Glow (khớp welcome.html ::before & ::after) ──
          Positioned(
            top: -85,
            right: -75,
            child: IgnorePointer(
              child: Container(
                width: 330,
                height: 330,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0072D5).withValues(alpha: 0.25),
                    width: 2,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0072D5).withValues(alpha: 0.09),
                      const Color(0xFF0072D5).withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65, 0.8],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0072D5).withValues(alpha: 0.08),
                      blurRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.24,
            left: -65,
            child: IgnorePointer(
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF8A933).withValues(alpha: 0.32),
                    width: 2,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF8A933).withValues(alpha: 0.11),
                      const Color(0xFFF8A933).withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65, 0.8],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF8A933).withValues(alpha: 0.09),
                      blurRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 2. Nội dung chính toàn màn hình ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Top Brand Section ──
                  Column(
                    children: [
                      const SizedBox(height: 18),
                      // Badge Pill FINORA (.badge-pill)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0072D5).withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'FINORA',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: const Color(0xFF0072D5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tiêu đề (.brand-title): Tài chính thông minh
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                            height: 1.15,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Tài chính ',
                              style: TextStyle(color: Color(0xFF0072D5)),
                            ),
                            TextSpan(
                              text: 'thông minh',
                              style: TextStyle(color: Color(0xFFF8A933)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Mô tả phụ (.brand-desc)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Đồng hành cùng dàn trợ lý AI cá nhân hóa theo từng cấp bậc tài chính của bạn',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Middle Mascot Stage Section ──
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bong bóng hội thoại (.mascot-bubble) - Chỉ hiện khi click mascot
                      AnimatedOpacity(
                        opacity: _showBubble ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 240),
                        child: AnimatedSlide(
                          offset: _showBubble ? Offset.zero : const Offset(0, 0.25),
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutBack,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color: isDark ? AppColors.darkForeground : const Color(0xFF0F172A),
                                      height: 1.3,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${active.mascot.name}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0072D5),
                                        ),
                                      ),
                                      TextSpan(
                                        text: active.quote,
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Mũi nhọn hướng xuống mascot (.mascot-bubble::after)
                              CustomPaint(
                                size: const Size(14, 7),
                                painter: _BubbleArrowPainter(
                                  color: isDark ? AppColors.darkSurface : Colors.white,
                                  borderColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sân khấu lineup 7 Mascot dàn hàng ngang tự nhiên
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final centerX = constraints.maxWidth / 2;
                          const step = 39.0;
                          final offsets = [
                            -3 * step, // 0. Ash: -117
                            -2 * step, // 1. Penny: -78
                            -1 * step, // 2. Sage: -39
                            0.0,       // 3. Nora: 0
                            1 * step,  // 4. Jade: +39
                            2 * step,  // 5. Ruby: +78
                            3 * step,  // 6. Bellingham: +117
                          ];

                          // Thứ tự xếp lớp: Ngoài cùng phía sau, Nora trung tâm phía trước nhất
                          final orderedIndices = [0, 6, 1, 5, 2, 4, 3];
                          if (activeIndex != 3 && orderedIndices.contains(activeIndex)) {
                            orderedIndices.remove(activeIndex);
                            orderedIndices.add(activeIndex);
                          }

                          return SizedBox(
                            height: 130,
                            width: constraints.maxWidth,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Sàn phát sáng (.stage-floor)
                                Positioned(
                                  bottom: 16,
                                  child: Container(
                                    width: 310,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(99),
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF0072D5).withValues(alpha: 0.16),
                                          const Color(0xFFF8A933).withValues(alpha: 0.12),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.5, 0.8],
                                      ),
                                    ),
                                  ),
                                ),

                                // Dàn 7 Mascot
                                ...orderedIndices.map((idx) {
                                  final item = _kWelcomeMascots[idx];
                                  final isNora = item.mascot.id == 'nora';
                                  final isSelected = idx == activeIndex;
                                  final isBouncing = idx == _bouncingIndex;

                                  final baseWidth = 66.0;
                                  final baseHeight = 74.0;
                                  final xPos = centerX + offsets[idx] - (baseWidth / 2);

                                  return Positioned(
                                    left: xPos,
                                    bottom: 0,
                                    child: AnimatedBuilder(
                                      animation: _waveController,
                                      builder: (context, child) {
                                        // Sóng bồng bềnh êm dịu, không làm méo mặt bằng chân
                                        final waveProgress = _waveController.value * 2 * math.pi;
                                        final waveY = math.sin(waveProgress + item.phase) * 2.2;
                                        final currentY = item.yOffset + waveY;

                                        double bounceScale = 1.0;
                                        double bounceY = 0.0;
                                        if (isBouncing && _bounceController.isAnimating) {
                                          final t = _bounceController.value;
                                          final curveVal = math.sin(t * math.pi);
                                          bounceScale = 1.0 + (curveVal * 0.20);
                                          bounceY = -curveVal * 12.0;
                                        }

                                        return Transform.translate(
                                          offset: Offset(0, currentY + bounceY),
                                          child: Transform.scale(
                                            scale: item.scale * bounceScale,
                                            alignment: Alignment.bottomCenter,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: GestureDetector(
                                        onTap: () => _onTapMascot(idx),
                                        behavior: HitTestBehavior.opaque,
                                        child: SizedBox(
                                          width: baseWidth,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                clipBehavior: Clip.none,
                                                children: [
                                                  // Vầng sáng xanh của Nora (.hero-halo)
                                                  if (isNora)
                                                    Positioned(
                                                      top: -10,
                                                      child: Container(
                                                        width: 96,
                                                        height: 96,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          gradient: RadialGradient(
                                                            colors: [
                                                              const Color(0xFF0072D5).withValues(alpha: 0.32),
                                                              const Color(0xFF0072D5).withValues(alpha: 0.10),
                                                              Colors.transparent,
                                                            ],
                                                            stops: const [0.0, 0.52, 0.74],
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                  // Mascot SVG Body (.mascot-svg-wrap)
                                                  SizedBox(
                                                    width: baseWidth,
                                                    height: baseHeight,
                                                    child: SvgPicture.string(
                                                      item.mascot.svg,
                                                      fit: BoxFit.contain,
                                                      alignment: Alignment.bottomCenter,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Bóng đổ dưới chân từng mascot (.char-shadow)
                                              Container(
                                                width: 44,
                                                height: 6,
                                                margin: const EdgeInsets.only(top: 1),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(99),
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      Colors.black.withValues(alpha: 0.22),
                                                      Colors.black.withValues(alpha: 0.06),
                                                      Colors.transparent,
                                                    ],
                                                    stops: const [0.0, 0.45, 0.8],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),

                                              // Tên Mascot (.char-name)
                                              Text(
                                                item.mascot.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.visible,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                  fontSize: isNora ? 13 : 11,
                                                  fontWeight: (isNora || isSelected)
                                                      ? FontWeight.w900
                                                      : FontWeight.w800,
                                                  color: (isNora || isSelected)
                                                      ? const Color(0xFF0072D5)
                                                      : const Color(0xFF94A3B8),
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // ── Bottom Action Buttons (.action-group) ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nút Đăng nhập (.btn-main .btn-login)
                      InkWell(
                        onTap: () => context.push(RoutePaths.login),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0072D5),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0072D5).withValues(alpha: 0.32),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Đăng nhập',
                            style: GoogleFonts.inter(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nút Đăng ký tài khoản (.btn-main .btn-register)
                      InkWell(
                        onTap: () => context.push(RoutePaths.register),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Đăng ký tài khoản',
                            style: GoogleFonts.inter(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkForeground : const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vẽ mũi tên nhọn trỏ xuống cho bong bóng hội thoại (.mascot-bubble::after)
class _BubbleArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  const _BubbleArrowPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawLine(Offset.zero, Offset(size.width / 2, size.height), borderPaint);
    canvas.drawLine(Offset(size.width / 2, size.height), Offset(size.width, 0), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) =>
      color != oldDelegate.color || borderColor != oldDelegate.borderColor;
}
