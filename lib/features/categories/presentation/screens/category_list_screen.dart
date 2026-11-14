import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/category.dart';
import '../providers/category_list_provider.dart';
import '../widgets/category_empty_user_card.dart';
import '../widgets/category_form_sheet.dart';
import '../widgets/category_group_card.dart';
import '../widgets/category_section_header.dart';
import '../widgets/category_type_toggle.dart';

/// Màn hình Quản lý Danh mục thu chi chuẩn Solarn FinTech Style
/// Tách biệt rõ ràng: Danh mục người dùng tạo ở trên, Danh mục hệ thống ở dưới
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

    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa danh mục?',
      message:
          'Bạn có chắc chắn muốn xóa danh mục "${category.name}"? Các giao dịch liên quan sẽ được chuyển về Chưa phân loại.',
      confirmText: 'Xóa',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(categoryListProvider.notifier).deleteCategory(category.id);
      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Đã xóa danh mục thành công',
          type: ToastType.success,
        );
      }
    }
  }

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
              Flexible(
                  child: Text(
                'Thêm mới',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ),
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
      appBar: const PageHeader.subPage(
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
                    final userCategories =
                        items.where((c) => !c.isDefault).toList();
                    final systemCategories =
                        items.where((c) => c.isDefault).toList();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
                      children: [
                        // ── NHÓM 1: DANH MỤC CỦA BẠN (Ở TRÊN) ──
                        CategorySectionHeader(
                          title: 'Danh mục của bạn',
                          count: userCategories.length,
                          action: _buildAddButton(context, ref),
                        ),
                        if (userCategories.isEmpty)
                          CategoryEmptyUserCard(
                            onAdd: () => _openAddSheet(context, ref),
                          )
                        else
                          CategoryGroupCard(
                            items: userCategories,
                            onTapCategory: (cat) =>
                                _openEditSheet(context, cat),
                            onDeleteCategory: (cat) =>
                                _confirmDelete(context, ref, cat),
                          ),

                        const SizedBox(height: 24),

                        // ── NHÓM 2: DANH MỤC HỆ THỐNG (Ở DƯỚI) ──
                        if (systemCategories.isNotEmpty) ...[
                          CategorySectionHeader(
                            title: 'Danh mục hệ thống',
                            count: systemCategories.length,
                          ),
                          CategoryGroupCard(
                            items: systemCategories,
                            onTapCategory: (cat) =>
                                _openEditSheet(context, cat),
                            onDeleteCategory: (cat) =>
                                _confirmDelete(context, ref, cat),
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
