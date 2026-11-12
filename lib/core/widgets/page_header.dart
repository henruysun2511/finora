import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';

/// Header thống nhất cho toàn bộ ứng dụng chuẩn FinTech Style (`static-ui/ui-sample-3`).
///
/// Hỗ trợ 2 kiểu giao diện:
/// 1. [PageHeader.page]: Dành cho các màn hình chính (Tabs) có tiêu đề lớn + nút tác vụ (`.page-hdr`).
/// 2. [PageHeader.subPage]: Dành cho các màn hình con/form/chi tiết có nút Back bo góc mềm (`.tx-hdr`).
class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final VoidCallback? onBack;
  final bool isSubPage;
  final bool showBottomBorder;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const PageHeader.page({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.bottom,
  })  : isSubPage = false,
        onBack = null,
        showBottomBorder = false,
        backgroundColor = null;

  const PageHeader.subPage({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onBack,
    this.showBottomBorder = true,
    this.backgroundColor,
    this.bottom,
  }) : isSubPage = true;

  @override
  Size get preferredSize =>
      Size.fromHeight((isSubPage ? 56.0 : 64.0) + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isSubPage) {
      // ── 1. Root Page Header (.page-hdr) ──
      final bgColor = backgroundColor ??
          (isDark ? AppColors.darkSurface : Colors.white);
      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: showBottomBorder && bottom == null
              ? Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.8,
                  ),
                )
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (action != null) action!,
                  ],
                ),
              ),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      );
    }

    // ── 2. Sub-page Header với Nút Back mềm mại (.tx-hdr) ──
    final bgColor = backgroundColor ??
        (isDark ? AppColors.darkSurface : Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: showBottomBorder && bottom == null
            ? Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Nút Back chuẩn .tx-back bo góc mềm 12px
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (onBack != null) {
                          onBack!();
                        } else if (context.canPop()) {
                          context.pop();
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBorder.withValues(alpha: 0.5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 22,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Tiêu đề (.tx-hdr-title)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action bên phải (nếu có)
                  if (action != null) action!,
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}

/// Alias tương thích ngược
typedef SolarnHeader = PageHeader;

