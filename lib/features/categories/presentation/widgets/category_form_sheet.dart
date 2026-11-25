import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../domain/models/category.dart';
import '../../domain/models/category_input.dart';
import '../../domain/models/category_type.dart';
import '../../domain/validators/category_validators.dart';
import '../providers/category_form_provider.dart';
import 'category_type_toggle.dart';
import 'icon_color_picker_grid.dart';

class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({
    super.key,
    this.initialCategory,
    this.initialType = CategoryType.expense,
  });

  final Category? initialCategory;
  final CategoryType initialType;

  static Future<Category?> show(
    BuildContext context, {
    Category? category,
    CategoryType? type,
  }) {
    return showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryFormSheet(
        initialCategory: category,
        initialType: type ?? category?.type ?? CategoryType.expense,
      ),
    );
  }

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CategoryType _selectedType;
  late String _selectedIcon;
  late String _selectedColor;

  bool get isEditing => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    _nameController = TextEditingController(text: cat?.name ?? '');
    _selectedType = cat?.type ?? widget.initialType;
    _selectedIcon = cat?.icon ?? 'utensils';
    _selectedColor = cat?.color ?? '#1E5BD8';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final input = CategoryInput(
      name: _nameController.text.trim(),
      type: _selectedType,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    final res = await ref.read(categoryFormProvider.notifier).submit(
          categoryId: widget.initialCategory?.id,
          input: input,
        );

    if (res != null && mounted) {
      AppToast.show(
        context,
        message: isEditing
            ? 'Đã cập nhật danh mục thành công'
            : 'Đã tạo danh mục mới thành công',
        type: ToastType.success,
      );
      Navigator.pop(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.watch(categoryFormProvider);
    final isLoading = formState.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 12,
        left: 20,
        right: 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBorder
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Tiêu đề Sheet
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? 'Sửa danh mục' : 'Thêm danh mục mới',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preview Icon & Tên
                Center(
                  child: CategoryIcon(
                    icon: _selectedIcon,
                    colorHex: _selectedColor,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),

                // Chọn loại nếu tạo mới
                if (!isEditing) ...[
                  CategoryTypeToggle(
                    selectedType: _selectedType,
                    onChanged: (t) => setState(() => _selectedType = t),
                  ),
                  const SizedBox(height: 16),
                ],

                // Nhập tên
                Text(
                  'Tên danh mục *',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: CategoryValidators.validateName,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Ăn uống, Mua sắm, v.v.',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkBackground
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Bảng chọn Icon và Màu sắc
                IconColorPickerGrid(
                  selectedIcon: _selectedIcon,
                  selectedColor: _selectedColor,
                  onIconSelected: (ic) => setState(() => _selectedIcon = ic),
                  onColorSelected: (col) => setState(() => _selectedColor = col),
                ),
                const SizedBox(height: 24),

                // Nút Lưu
                AppButton(
                  label: isEditing ? 'Lưu thay đổi' : 'Tạo danh mục',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

