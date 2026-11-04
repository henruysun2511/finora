import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/solarn_header.dart';
import '../../domain/models/category.dart';
import '../providers/category_list_provider.dart';
import '../widgets/category_form_sheet.dart';
import '../widgets/category_type_toggle.dart';

/// Màn hình Quản lý Danh mục thu chi chuẩn Solarn FinTech Style
/// Tách biệt rõ ràng: Danh mục người dùng tạo ở trên, Danh mục hệ thống ở dưới
/// Nút "Thêm mới" nền xanh dương chữ trắng, không đặt ở header.
class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    final currentType = ref.read(categoryFilterTypeProvider);
    CategoryFormSheet.show(context, type: currentType);
  }

  void _openEditSheet(BuildContext context, Category category) {
    CategoryFormSheet.show(context, category: category);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    if (category.isDefault) {
      AppToast.show(
        context,
        message: 'Không thể xóa danh mục mặc định của hệ thống',
        type: ToastType.warning,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Xóa danh mục?',
        message:
            'Bạn có chắc chắn muốn xóa danh mục "${category.name}"? Các giao dịch liên quan sẽ được chuyển về Chưa phân loại.',
        confirmText: 'Xóa',
        isDestructive: true,
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(categoryListProvider.notifier)
          .deleteCategory(category.id);
      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Đã xóa danh mục thành công',
          type: ToastType.success,
        );
      }
    }
  }

  /// Nút Thêm mới chuẩn nền xanh dương, chữ trắng
  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openAddSheet(context, ref),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                'Thêm mới',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required int count,
    Widget? action,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBorder
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
              ),
            ],
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildCategoryGroupCard({
    required BuildContext context,
    required WidgetRef ref,
    required List<Category> items,
    required bool isDark,
  }) {
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
              onTap: () => _openEditSheet(context, item),
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
                        onPressed: () => _confirmDelete(
                          context,
                          ref,
                          item,
                        ),
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

  Widget _buildEmptyUserCategoriesCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.6)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          LucideIcon(
            name: 'sparkles',
            size: 26,
            color: isDark ? AppColors.darkMuted : const Color(0xFF94A3B8),
            strokeWidth: 1.8,
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn chưa tạo danh mục tùy chỉnh nào',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _buildAddButton(context, ref),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedType = ref.watch(categoryFilterTypeProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      // Đã bỏ nút thêm ở Header theo đúng yêu cầu
      appBar: const SolarnHeader.subPage(
        title: 'Danh mục thu chi',
        subtitle: 'Cấu hình và phân loại giao dịch',
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(categoryListProvider.notifier).refresh(),
          child: Column(
            children: [
              // ── 1. Tab Toggle: Chi tiêu / Thu nhập Solarn Style ──
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: CategoryTypeToggle(
                  selectedType: selectedType,
                  onChanged: (type) {
                    ref.read(categoryFilterTypeProvider.notifier).state = type;
                  },
                ),
              ),

              // ── 2. Danh sách Danh mục phân tách 2 nhóm ──
              Expanded(
                child: categoriesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Đã có lỗi xảy ra: $e',
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ),
                  data: (items) {
                    // Phân nhóm: Người dùng tạo (isDefault == false) và Hệ thống (isDefault == true)
                    final userCategories =
                        items.where((c) => !c.isDefault).toList();
                    final systemCategories =
                        items.where((c) => c.isDefault).toList();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
                      children: [
                        // ── NHÓM 1: DANH MỤC CỦA BẠN (Ở TRÊN) ──
                        _buildSectionHeader(
                          context: context,
                          title: 'Danh mục của bạn',
                          count: userCategories.length,
                          action: _buildAddButton(context, ref),
                        ),
                        if (userCategories.isEmpty)
                          _buildEmptyUserCategoriesCard(context, ref, isDark)
                        else
                          _buildCategoryGroupCard(
                            context: context,
                            ref: ref,
                            items: userCategories,
                            isDark: isDark,
                          ),

                        const SizedBox(height: 24),

                        // ── NHÓM 2: DANH MỤC HỆ THỐNG (Ở DƯỚI) ──
                        if (systemCategories.isNotEmpty) ...[
                          _buildSectionHeader(
                            context: context,
                            title: 'Danh mục hệ thống',
                            count: systemCategories.length,
                          ),
                          _buildCategoryGroupCard(
                            context: context,
                            ref: ref,
                            items: systemCategories,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
