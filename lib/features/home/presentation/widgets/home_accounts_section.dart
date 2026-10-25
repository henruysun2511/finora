import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'section_header.dart';

class HomeAccountsSection extends StatelessWidget {
  const HomeAccountsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Tài khoản',
          actionText: 'Xem tất cả',
          onTap: () => context.push(RoutePaths.wallets),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => context.push(RoutePaths.wallets),
                child: _AccountCard(
                  isDark: isDark,
                  name: 'Tiền mặt',
                  balance: 2500000,
                  icon: Icons.account_balance_wallet_rounded,
                  chipText: 'Ví tiền mặt',
                  chipColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.push(RoutePaths.wallets),
                child: _AccountCard(
                  isDark: isDark,
                  name: 'Vietcombank',
                  balance: 18350000,
                  icon: Icons.account_balance_rounded,
                  chipText: 'Tài khoản NH',
                  chipColor: AppColors.primary,
                  isHighlighted: true,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.push(RoutePaths.wallets),
                child: _AccountCard(
                  isDark: isDark,
                  name: 'MoMo',
                  balance: 4000000,
                  icon: Icons.smartphone_rounded,
                  chipText: 'Ví điện tử',
                  chipColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final bool isDark;
  final String name;
  final double balance;
  final IconData icon;
  final String chipText;
  final Color chipColor;
  final bool isHighlighted;

  const _AccountCard({
    required this.isDark,
    required this.name,
    required this.balance,
    required this.icon,
    required this.chipText,
    required this.chipColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1.5,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: chipColor),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CurrencyFormatter.formatCompact(balance),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: chipColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      chipText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightFaint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
