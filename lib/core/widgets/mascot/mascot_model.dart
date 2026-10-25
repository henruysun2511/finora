import 'package:flutter/material.dart';

/// Data model representing a Finora AI Mascot with all design system attributes,
/// financial tier constraints, quotes, and vector SVG definition.
class MascotData {
  final String id;
  final String name;
  final String role;
  final String tier;
  final String range;
  final double min;
  final double max;
  final String colorHex;
  final String blobColorHex;
  final String accentHex;
  final String personality;
  final String finance;
  final String advice;
  final String q1;
  final String q2;
  final String bubble;
  final String svg;

  const MascotData({
    required this.id,
    required this.name,
    required this.role,
    required this.tier,
    required this.range,
    required this.min,
    required this.max,
    required this.colorHex,
    required this.blobColorHex,
    required this.accentHex,
    required this.personality,
    required this.finance,
    required this.advice,
    required this.q1,
    required this.q2,
    required this.bubble,
    required this.svg,
  });

  /// Primary theme color
  Color get color => parseHex(colorHex);

  /// Background ambient blob color (used in cards / profile spotlight)
  Color get blobColor => parseHex(blobColorHex);

  /// Border / accent color
  Color get accent => parseHex(accentHex);

  /// List of characteristic quotes
  List<String> get quotes => [q1, q2].where((q) => q.isNotEmpty).toList();

  /// Parse hex color string (e.g. "#0072d5" or "0072d5") into Flutter [Color].
  static Color parseHex(String hex, [Color fallback = const Color(0xFF0072D5)]) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      } else if (clean.length == 3) {
        final r = clean[0];
        final g = clean[1];
        final b = clean[2];
        return Color(int.parse('FF$r$r$g$g$b$b', radix: 16));
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }
}
