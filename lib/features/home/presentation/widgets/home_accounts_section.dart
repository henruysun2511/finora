import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/domain/models/dashboard_overview_model.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'section_header.dart';

class HomeAccountsSection extends ConsumerWidget {
  const HomeAccountsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overviewAsync = ref.watch(dashboardOverviewProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Tài khoản & Nguồn tiền',
          actionText: 'Xem tất cả',
          onTap: () => context.go(RoutePaths.wallets),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: overviewAsync.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => _AccountCardSkeleton(isDark: isDark),
            ),
            error: (err, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Không thể tải tài khoản',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(dashboardOverviewProvider),
                    child: Text(
                      'Thử lại',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            data: (data) {
              final accounts = data.accountsSummary;

              if (accounts.isEmpty) {
                return GestureDetector(
                  onTap: () => context.push(RoutePaths.wallets),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_card_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chưa có tài khoản',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForeground
                                      : AppColors.lightForeground,
                                ),
                              ),
                              Text(
                                'Bấm để thêm tài khoản hoặc ví',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.lightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: accounts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final acc = accounts[index];
                  final isBank = acc.type == 'BANK';
                  final isEWallet = acc.type == 'E_WALLET';

                  return GestureDetector(
                    onTap: () => context.push(RoutePaths.wallets),
                    child: _AccountCard(
                      isDark: isDark,
                      name: acc.name,
                      balance: acc.balance,
                      icon: isBank
                          ? Icons.account_balance_rounded
                          : (isEWallet
                              ? Icons.smartphone_rounded
                              : Icons.account_balance_wallet_rounded),
                      chipText: isBank
                          ? 'Ngân hàng'
                          : (isEWallet ? 'Ví điện tử' : 'Ví tiền mặt'),
                      chipColor: isBank
                          ? AppColors.primary
                          : (isEWallet
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF0284C7)),
                      isHighlighted: isBank,
                    ),
                  );
                },
              );
            },
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

class _AccountCardSkeleton extends StatelessWidget {
  final bool isDark;

  const _AccountCardSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
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
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 10,
                width: 50,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
