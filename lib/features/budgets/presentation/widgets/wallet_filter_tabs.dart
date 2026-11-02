import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

class WalletFilterTabs extends StatelessWidget {
  const WalletFilterTabs({
    super.key,
    required this.selectedWalletId,
    required this.onSelected,
  });

  final String? selectedWalletId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final options = [
      {'id': null, 'label': 'Tất cả các ví'},
      {'id': 'personal', 'label': 'Cá nhân'},
      {'id': 'family', 'label': 'Gia đình'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = selectedWalletId == opt['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                opt['label']!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              onSelected: (_) => onSelected(opt['id']),
            ),
          );
        }).toList(),
      ),
    );
  }
}

