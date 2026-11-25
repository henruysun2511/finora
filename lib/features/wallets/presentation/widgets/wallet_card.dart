import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/domain/models/account_model.dart';
import '../providers/wallet_providers.dart';
import '../providers/wallets_overview_provider.dart';

class WalletCard extends ConsumerWidget {
  final WalletItemState item;
  final VoidCallback onTap;

  const WalletCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHidden = ref.watch(isBalanceHiddenProvider);
    final wallet = item.wallet;
    final balance = item.balance;
    final accounts = item.accountsPreview;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Icon + Name + Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon / Emoji
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        wallet.icon != null && wallet.icon!.isNotEmpty
                            ? wallet.icon!
                            : (wallet.isShared ? '🏠' : '💼'),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  wallet.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (wallet.isShared) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.group_rounded,
                                        size: 11,
                                        color: Color(0xFF6366F1),
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                          child: Text(
                                        'Shared',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6366F1),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            wallet.isShared
                                ? 'Ví dùng chung'
                                : 'Không gian cá nhân',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: wallet.currentUserRole.badgeColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        wallet.currentUserRole.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: wallet.currentUserRole.badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Balance summary row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số dư khả dụng',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isHidden
                                ? '•••••••• VND'
                                : CurrencyFormatter.format(
                                    balance.totalBalance,
                                    currency: wallet.defaultCurrency,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          '${balance.accountsCount} Tài khoản',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ],
                ),

                // Preview Accounts list (if any)
                if (accounts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color:
                        isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 10),
                  ...accounts.map(
                    (acc) => _AccountPreviewTile(
                      account: acc,
                      isHidden: isHidden,
                      isDark: isDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountPreviewTile extends StatelessWidget {
  final AccountModel account;
  final bool isHidden;
  final bool isDark;

  const _AccountPreviewTile({
    required this.account,
    required this.isHidden,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Small Icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: account.displayColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              account.displayIcon,
              size: 14,
              color: account.displayColor,
            ),
          ),
          const SizedBox(width: 8),

          // Name & last 4 digits
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    account.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (account.accountNumberLast4 != null &&
                    account.accountNumberLast4!.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Text(
                    '••••${account.accountNumberLast4}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Balance
          Text(
            isHidden
                ? '••••••'
                : CurrencyFormatter.format(
                    account.balance,
                    currency: account.currency,
                  ),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
        ],
      ),
    );
  }
}
