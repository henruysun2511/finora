import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/wallet_providers.dart';

class WalletFilterTabs extends ConsumerWidget {
  final int totalCount;
  final int personalCount;
  final int sharedCount;

  const WalletFilterTabs({
    super.key,
    required this.totalCount,
    required this.personalCount,
    required this.sharedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(walletFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Tất cả ($totalCount)',
            isSelected: currentTab == WalletFilterTab.all,
            onTap: () {
              ref.read(walletFilterProvider.notifier).state =
                  WalletFilterTab.all;
            },
          ),
          _TabItem(
            label: 'Cá nhân ($personalCount)',
            isSelected: currentTab == WalletFilterTab.personal,
            onTap: () {
              ref.read(walletFilterProvider.notifier).state =
                  WalletFilterTab.personal;
            },
          ),
          _TabItem(
            label: 'Ví chung ($sharedCount)',
            isSelected: currentTab == WalletFilterTab.shared,
            onTap: () {
              ref.read(walletFilterProvider.notifier).state =
                  WalletFilterTab.shared;
            },
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
            ),
          ),
        ),
      ),
    );
  }
}

