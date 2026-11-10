import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../domain/models/category.dart';

class CategoryGroupCard extends StatelessWidget {
  const CategoryGroupCard({
    super.key,
    required this.items,
    required this.onTapCategory,
    required this.onDeleteCategory,
  });

  final List<Category> items;
  final ValueChanged<Category> onTapCategory;
  final ValueChanged<Category> onDeleteCategory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final isFirst = index == 0;
          final isLast = index == items.length - 1;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTapCategory(item),
              borderRadius: isFirst && isLast
                  ? BorderRadius.circular(18)
                  : (isFirst
                      ? const BorderRadius.vertical(top: Radius.circular(18))
                      : (isLast
                          ? const BorderRadius.vertical(bottom: Radius.circular(18))
                          : BorderRadius.zero)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CategoryIcon(
                      icon: item.icon,
                      colorHex: item.color,
                      size: 38,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          if (item.transactionCount > 0)
                            Text(
                              '${item.transactionCount} giao dịch',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!item.isDefault)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: AppColors.danger,
                        ),
                        onPressed: () => onDeleteCategory(item),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Mặc định',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
