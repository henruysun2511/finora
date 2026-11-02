import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/budget_filter_provider.dart';

/// Ô tìm kiếm ngân sách có debounce 400ms để chống spam API và giật lag UI
class BudgetSearchBar extends ConsumerStatefulWidget {
  const BudgetSearchBar({super.key});

  @override
  ConsumerState<BudgetSearchBar> createState() => _BudgetSearchBarState();
}

class _BudgetSearchBarState extends ConsumerState<BudgetSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(budgetFilterProvider).searchQuery ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(budgetFilterProvider.notifier).setSearchQuery(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    ref.read(budgetFilterProvider.notifier).setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
      ),
      decoration: InputDecoration(
        hintText: 'Tìm ngân sách theo danh mục hoặc ví...',
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        ),
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.lightMuted),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.lightMuted),
                onPressed: _clear,
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
