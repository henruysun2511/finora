import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';

/// Khung Header & Banner chung theo chuẩn thiết kế Hero Banner (`static-ui/device-preview/screens/wallets/list.html`).
///
/// Cấu trúc khung thống nhất bao gồm:
/// - Nền gradient tùy biến với hiệu ứng vòng tròn mờ trang trí phía trên bên phải.
/// - Thanh điều hướng (Nav bar): Nút quay lại kính mờ 36x36 (.acc-nav-btn), Tiêu đề chữ trắng đậm, và Tác vụ bên phải.
/// - Phần nội dung bên trong Banner ([child]): Nhận các khối thông tin, số liệu tài sản / nợ ròng tùy từng màn hình.
class BannerHeader extends StatelessWidget {
  const BannerHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBack,
    this.leading,
    this.action,
    this.gradient,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.boxShadow,
    required this.child,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? leading;
  final Widget? action;
  final Gradient? gradient;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final Widget child;

  /// Helper tạo nút bấm kính mờ vuông 36x36 chuẩn `.acc-nav-btn` của banner
  static Widget glassButton({
    required Widget icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? backgroundColor,
    BoxBorder? border,
  }) {
    Widget btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
    if (tooltip != null) {
      btn = Tooltip(message: tooltip, child: btn);
    }
    return btn;
  }

  /// Nút bấm màu xanh dương thương hiệu hệ thống (AppColors.primary) không outline
  static Widget primaryButton({
    required Widget icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    Widget btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
    if (tooltip != null) {
      btn = Tooltip(message: tooltip, child: btn);
    }
    return btn;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ??
        const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        );

    final effectiveGradient = gradient ??
        const LinearGradient(
          colors: [
            Color(0xFF0F4B92),
            AppColors.primary,
            Color(0xFFF5B53F),
          ],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final hasRadius = effectiveBorderRadius != BorderRadius.zero;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor == null ? effectiveGradient : null,
        borderRadius: effectiveBorderRadius,
        boxShadow: boxShadow ??
            (hasRadius
                ? [
                    BoxShadow(
                      color: (backgroundColor ?? AppColors.primary)
                          .withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null),
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Stack(
          children: [
            // ── Vòng tròn mờ trang trí phía trên bên phải (theo .acc-hero::after) ──
            Positioned(
              top: -50,
              right: -30,
              child: IgnorePointer(
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),

            // ── Nội dung chính của Header & Banner ──
            SafeArea(
              bottom: false,
              child: Padding(
                padding: padding ??
                    const EdgeInsets.fromLTRB(18, 12, 18, 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Thanh điều hướng Nav Bar (.acc-nav-bar) ──
                    Row(
                      children: [
                        if (showBackButton)
                          glassButton(
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            onTap: onBack ??
                                () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go(RoutePaths.home);
                                  }
                                },
                            tooltip: 'Quay lại',
                          )
                        else if (leading != null)
                          leading!
                        else if (centerTitle)
                          const SizedBox(width: 36),

                        const SizedBox(width: 12),

                        // Tiêu đề (.acc-nav-title)
                        Expanded(
                          child: titleWidget ??
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: centerTitle
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      color: Colors.white,
                                    ),
                                    textAlign: centerTitle
                                        ? TextAlign.center
                                        : TextAlign.start,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (subtitle != null &&
                                      subtitle!.isNotEmpty) ...[
                                    const SizedBox(height: 1),
                                    Text(
                                      subtitle!,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white
                                            .withValues(alpha: 0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                        ),

                        const SizedBox(width: 12),

                        // Action bên phải (nếu có)
                        if (action != null)
                          action!
                        else if (showBackButton && centerTitle)
                          const SizedBox(width: 36)
                        else
                          const SizedBox.shrink(),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── Nội dung thành phần bên trong Banner ──
                    child,
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

