import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';

/// Khung nhập tìm kiếm bài đăng Bảng tin nằm ngay trên phần lọc
class FeedSearchBar extends StatelessWidget {
  const FeedSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final mutedColor = dark ? AppColors.darkMuted : AppColors.lightMuted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: TextField(
        controller: controller,
        autofocus: false,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 13.5,
          color: dark ? AppColors.darkForeground : AppColors.lightForeground,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm theo bạn bè, địa điểm hoặc nội dung...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: mutedColor,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LucideIcon(
              name: 'search',
              size: 18,
              color: mutedColor,
              strokeWidth: 2.0,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 42,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: LucideIcon(
                    name: 'x',
                    size: 16,
                    color: mutedColor,
                    strokeWidth: 2.0,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
