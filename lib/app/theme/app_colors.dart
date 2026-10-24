import 'package:flutter/material.dart';

/// Bảng màu SOLARN FinTech trích xuất CHUẨN XÁC 1:1 từ `static-ui/ui-sample-3/styles.css`.
/// Giá trị OKLCH được chuyển đổi chính xác sang sRGB:
/// - Primary: oklch(0.55 0.18 250) = rgb(0, 114, 213) = #0072D5
/// - Secondary: oklch(0.78 0.16 65) = #FC9F30
/// - Orange: oklch(0.7 0.19 45) = #FA6E1D
/// - Dash-bg: oklch(0.97 0.01 240) = #EFF6FB
class AppColors {
  AppColors._();

  // ── Primary (oklch(0.55 0.18 250) = rgb(0, 114, 213)) ─────────────────────
  static const Color primary = Color(0xFF0072D5); // Nora Solarn Blue
  static const Color primaryDark = Color(0xFF0058A8);
  static const Color primaryLight = Color(0xFFEAF3FF); // rgba(0, 114, 213, 0.12)
  static const Color primaryGlow = Color(0x470072D5);
  static const Color primaryGradientStart = Color(0xFF0072D5);
  static const Color primaryGradientEnd = Color(0xFF005BB5);

  // ── Hero Balance Card Gradient (oklch 0.5 0.17 250 -> 0.42 0.15 250 -> orange)
  static const Color balanceGradStart = Color(0xFF0064BE);
  static const Color balanceGradMid = Color(0xFF004D9A);
  static const Color balanceGradEnd = Color(0xFFFA6E1D); // oklch(0.7 0.19 45)

  // ── Solarn Accent Colors (trích xuất 100% từ styles.css) ────────────────────
  static const Color secondary = Color(0xFFFC9F30); // oklch(0.78 0.16 65)
  static const Color orange = Color(0xFFFA6E1D);    // oklch(0.7 0.19 45)
  static const Color violet = Color(0xFF6B55DF);    // oklch(0.55 0.2 285)
  static const Color teal = Color(0xFF00A19B);      // oklch(0.63 0.13 190)
  static const Color pink = Color(0xFFDF4B9D);      // oklch(0.64 0.2 350)

  // ── Status Colors ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00B764);   // oklch(0.68 0.18 155)
  static const Color warning = Color(0xFFE6AD00);   // oklch(0.78 0.16 85)
  static const Color danger = Color(0xFFEE343B);    // oklch(0.62 0.22 25)

  // ── Surfaces (Light Mode chuẩn styles.css) ─────────────────────────────────
  static const Color lightBackground = Color(0xFFEFF6FB); // var(--dash-bg)
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightForeground = Color(0xFF00243B); // var(--foreground) deep ink navy
  static const Color lightMuted = Color(0xFF76828B);      // var(--ink-soft)
  static const Color lightFaint = Color(0xFFA3B0BA);      // var(--ink-faint)
  static const Color lightBorder = Color(0xFFDFE6EB);     // var(--border)

  // ── Surfaces (Dark Mode) ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF07141E);
  static const Color darkSurface = Color(0xFF0E2232);
  static const Color darkForeground = Color(0xFFF5FDFF);
  static const Color darkMuted = Color(0xFF8899A6);
  static const Color darkBorder = Color(0xFF1B3549);

  // ── Radii Tokens (SOLARN Heavy Radii) ──────────────────────────────────────
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
}
