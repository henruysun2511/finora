import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String? icon;
  final String? colorHex;
  final double size;

  const CategoryIcon({
    super.key,
    this.icon,
    this.colorHex,
    this.size = 44,
  });

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF1E5BD8);
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF1E5BD8);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _parseColor(colorHex);
    final isEmoji = icon != null &&
        icon!.runes.any((rune) => rune > 127 || rune == 0x200D);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
      alignment: Alignment.center,
      child: isEmoji
          ? Text(
              icon ?? '🏷️',
              style: TextStyle(fontSize: size * 0.5),
            )
          : Icon(
              Icons.category_outlined,
              size: size * 0.52,
              color: baseColor,
            ),
    );
  }
}
