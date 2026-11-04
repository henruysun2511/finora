import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';

/// Danh sách biểu tượng Lucide vector chuẩn FinTech
const List<String> kAvailableCategoryIcons = [
  'utensils',
  'shopping-bag',
  'car',
  'zap',
  'home',
  'building-2',
  'coffee',
  'gamepad-2',
  'banknote',
  'plane',
  'pill',
  'graduation-cap',
  'heart',
  'smartphone',
  'gift',
  'credit-card',
  'piggy-bank',
  'trending-up',
  'wifi',
  'camera',
  'dumbbell',
  'briefcase',
  'coins',
  'receipt',
];

const List<String> kAvailableCategoryColors = [
  '#1E5BD8', // Solarn Primary Blue
  '#F97316', // Orange / Warn
  '#EC4899', // Pink
  '#8B5CF6', // Violet
  '#10B981', // Emerald Success
  '#06B6D4', // Cyan
  '#F59E0B', // Amber
  '#EF4444', // Danger Red
  '#64748B', // Slate Grey
];

class IconColorPickerGrid extends StatelessWidget {
  const IconColorPickerGrid({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  final String selectedIcon;
  final String selectedColor;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<String> onColorSelected;

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = _parseHex(selectedColor);
    final normalizedSelected = LucideIcon.normalizeIconName(selectedIcon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Chọn Icon ──
        Text(
          'Biểu tượng:',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kAvailableCategoryIcons.map((ic) {
            final isSelected = ic == normalizedSelected;
            return GestureDetector(
              onTap: () => onIconSelected(ic),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.16)
                      : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? activeColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: LucideIcon(
                  name: ic,
                  size: 22,
                  color: isSelected
                      ? activeColor
                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  strokeWidth: 2.0,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // ── 2. Chọn Màu sắc ──
        Text(
          'Màu sắc:',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: kAvailableCategoryColors.map((colorHex) {
            final c = _parseHex(colorHex);
            final isSelected =
                colorHex.toUpperCase() == selectedColor.toUpperCase();
            return GestureDetector(
              onTap: () => onColorSelected(colorHex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: isDark ? Colors.white : Colors.black87,
                          width: 2.5,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: c.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
