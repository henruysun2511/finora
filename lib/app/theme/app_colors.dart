import 'package:flutter/material.dart';

/// Bảng màu SOLARN trích xuất từ `static-ui/ui-sample-3`.
/// Hệ màu hiện đại phong cách Next.js shadcn/ui + Tailwind:
/// - Primary: Royal Cobalt Blue
/// - Secondary: Amber Gold
/// - Accents: Teal, Orange, Violet, Pink
class AppColors {
  AppColors._();

  // Primary & Gradient
  static const Color primary = Color(0xFF1E5BD8);
  static const Color primaryDark = Color(0xFF1446A8);
  static const Color primaryLight = Color(0xFFEBF2FE);
  static const Color primaryGradientStart = Color(0xFF1E5BD8);
  static const Color primaryGradientEnd = Color(0xFF2563EB);

  // Balance Card Gradient Colors (SOLARN: oklch 0.5 0.17 250 -> oklch 0.42 0.15 250 -> orange)
  static const Color balanceGradStart = Color(0xFF1E5BD8);
  static const Color balanceGradMid = Color(0xFF1941A5);
  static const Color balanceGradEnd = Color(0xFFF97316);

  // Accents (Quick Actions & Categories)
  static const Color secondary = Color(0xFFF59E0B); // Amber
  static const Color orange = Color(0xFFF97316);
  static const Color teal = Color(0xFF14B8A6);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Light Mode Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightForeground = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Mode Surfaces
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkForeground = Color(0xFFF8FAFC);
  static const Color darkMuted = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E293B);

  // Radii tokens (SOLARN heavy radii)
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
}
