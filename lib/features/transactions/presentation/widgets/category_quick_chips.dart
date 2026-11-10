import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../categories/domain/models/category.dart';
import '../../../categories/domain/models/category_type.dart';
import '../../../categories/presentation/providers/category_providers.dart';

class CategoryQuickChips extends ConsumerWidget {
  const CategoryQuickChips({
    super.key,
    required this.selectedCategoryId,
    required this.isExpense,
    required this.onSelectCategory,
  });

  final String? selectedCategoryId;
  final bool isExpense;
  final void Function(Category category) onSelectCategory;

  void _openFullCategoryPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FullCategoryPickerSheet(
        selectedCategoryId: selectedCategoryId,
        isExpense: isExpense,
        onSelect: (cat) {
          Navigator.pop(ctx);
          onSelectCategory(cat);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = isExpense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DANH MỤC ${isExpense ? 'CHI TIÊU' : 'THU NHẬP'} (*)',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () => _openFullCategoryPicker(context, ref),
              child: Text(
                'Xem tất cả >',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Hàng 4 danh mục phổ biến
        categoriesAsync.when(
          loading: () => const SizedBox(
            height: 72,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          error: (_, __) => _buildFallbackChips(isDark, foreground, muted, border),
          data: (categories) {
            if (categories.isEmpty) {
              return _buildFallbackChips(isDark, foreground, muted, border);
            }

            final top4 = categories.take(4).toList();

            return Row(
              children: top4.map((cat) {
                final isSelected = cat.id == selectedCategoryId;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => onSelectCategory(cat),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            CategoryIcon(
                              icon: cat.icon,
                              colorHex: cat.color,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat.name,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFallbackChips(
      bool isDark, Color foreground, Color muted, Color border) {
    final fallbacks = isExpense
        ? [
            ('cat-1', 'Ăn uống', 'utensils', '#EF4444'),
            ('cat-2', 'Mua sắm', 'shopping-cart', '#3B82F6'),
            ('cat-3', 'Cà phê', 'coffee', '#F59E0B'),
            ('cat-4', 'Di chuyển', 'car', '#10B981'),
          ]
        : [
            ('cat-inc-1', 'Lương', 'wallet', '#10B981'),
            ('cat-inc-2', 'Thưởng', 'gift', '#F59E0B'),
            ('cat-inc-3', 'Đầu tư', 'trending-up', '#3B82F6'),
            ('cat-inc-4', 'Khác', 'plus-circle', '#8B5CF6'),
          ];

    return Row(
      children: fallbacks.map((f) {
        final isSelected = f.$1 == selectedCategoryId;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelectCategory(
                Category(
                  id: f.$1,
                  name: f.$2,
                  icon: f.$3,
                  color: f.$4,
                  type: isExpense ? CategoryType.expense : CategoryType.income,
                ),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    CategoryIcon(
                      icon: f.$3,
                      colorHex: f.$4,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      f.$2,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FullCategoryPickerSheet extends ConsumerWidget {
  const _FullCategoryPickerSheet({
    required this.selectedCategoryId,
    required this.isExpense,
    required this.onSelect,
  });

  final String? selectedCategoryId;
  final bool isExpense;
  final ValueChanged<Category> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = isExpense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn danh mục ${isExpense ? 'chi tiêu' : 'thu nhập'}',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: muted),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: border),
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (categories) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat.id == selectedCategoryId;

                    return InkWell(
                      onTap: () => onSelect(cat),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : (isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CategoryIcon(
                              icon: cat.icon,
                              colorHex: cat.color,
                              size: 40,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : foreground,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

