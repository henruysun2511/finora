import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../wallets/domain/models/account_item_model.dart';

class TransactionAccountSelector extends StatelessWidget {
  const TransactionAccountSelector({
    super.key,
    required this.accounts,
    required this.selectedId,
    required this.onSelect,
  });

  final List<AccountItemModel> accounts;
  final String? selectedId;
  final ValueChanged<AccountItemModel> onSelect;

  static const List<AccountItemModel> defaultFallbackAccounts = [
    AccountItemModel(
      id: 'acc-cash',
      name: 'Tiền mặt (Ví da)',
      type: 'cash',
      balance: 2500000,
      currency: 'VND',
    ),
    AccountItemModel(
      id: 'acc-vcb',
      name: 'Vietcombank Digibank',
      type: 'bank',
      balance: 18250000,
      currency: 'VND',
      accountNumberLast4: '6789',
    ),
    AccountItemModel(
      id: 'acc-momo',
      name: 'Ví điện tử MoMo',
      type: 'ewallet',
      balance: 850000,
      currency: 'VND',
    ),
    AccountItemModel(
      id: 'acc-tcb',
      name: 'Techcombank Visa Debit',
      type: 'bank',
      balance: 5400000,
      currency: 'VND',
      accountNumberLast4: '3456',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final displayAccounts =
        accounts.isNotEmpty ? accounts : defaultFallbackAccounts;

    return Column(
      children: displayAccounts.map((acc) {
        final isSelected = selectedId == acc.id;
        final formattedBalance =
            NumberFormat('#,###', 'vi_VN').format(acc.balance.round());

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onSelect(acc),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? Colors.white10
                              : AppColors.primary.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      acc.defaultIcon,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                acc.name,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : foreground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (acc.accountNumberLast4 != null &&
                                acc.accountNumberLast4!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: border.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '•••• ${acc.accountNumberLast4}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: muted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              acc.typeLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: muted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('•',
                                style: TextStyle(fontSize: 10, color: muted)),
                            const SizedBox(width: 6),
                            Text(
                              'Số dư: $formattedBalance ₫',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    isSelected ? AppColors.primary : foreground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? AppColors.primary
                        : muted.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
