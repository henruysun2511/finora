import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';

/// Thanh cuộn ngang các chip lọc thể loại bài đăng Feed (.filter-scroll)
/// Tuân thủ nghiêm ngặt Quy chuẩn 2 của GEMINI.md và sử dụng Lucide React Icon
class FeedCategoryFilterBar extends StatelessWidget {
  const FeedCategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<({String key, String label, String icon})> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = selectedCategory == cat.key;

            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LucideIcon(
                    name: cat.icon,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : (dark ? AppColors.darkMuted : AppColors.lightMuted),
                    strokeWidth: 2.2,
                  ),
                  const SizedBox(width: 6),
                  Text(cat.label),
                ],
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onCategorySelected(cat.key),
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (dark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground),
              ),
              backgroundColor: dark ? AppColors.darkSurface : Colors.white,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (dark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
