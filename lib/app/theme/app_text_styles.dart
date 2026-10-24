import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hệ thống Typography đôi SOLARN chuẩn:
/// - `Outfit`: Dùng cho số dư lớn, số tiền giao dịch, tỷ lệ % và tiêu đề trang trọng.
/// - `Inter`: Dùng cho nội dung đọc, nhãn, nút bấm, ghi chú và danh mục.
class AppTextStyles {
  AppTextStyles._();

  // ── Outfit (Số tiền & Tiêu đề lớn) ──────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) => GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: color,
      );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle amountHero({Color? color}) => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
        color: color,
      );

  static TextStyle amountCard({Color? color}) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle amountItem({Color? color}) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  // ── Inter (Nội dung & Tương tác giao diện) ──────────────────────────────────
  static TextStyle titleLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: color,
      );

  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: color,
      );

  // ── Semantic Getters cho Layout & Screen Components ─────────────────────────
  static TextStyle get h1 => displayLarge();
  static TextStyle get h2 => titleLarge();
  static TextStyle get h3 => titleMedium();
  static TextStyle get h4 => titleSmall();

  static TextStyle get body => bodyMedium();
  static TextStyle get caption => bodySmall();
  static TextStyle get label => labelLarge();
  static TextStyle get badge => labelSmall();
  static TextStyle get amountSmall => amountItem();
}
