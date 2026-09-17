import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/dashboard_data.dart';

class AccountsScroll extends StatefulWidget {
  final List<AccountItem> accounts;
  final ValueChanged<AccountItem>? onAccountSelected;

  const AccountsScroll({
    super.key,
    this.accounts = AccountItem.sampleAccounts,
    this.onAccountSelected,
  });

  @override
  State<AccountsScroll> createState() => _AccountsScrollState();
}

class _AccountsScrollState extends State<AccountsScroll> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    final defaultSelected = widget.accounts.firstWhere(
      (a) => a.isSelected,
      orElse: () => widget.accounts.first,
    );
    _selectedId = defaultSelected.id;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.accounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final acc = widget.accounts[index];
          final isSelected = acc.id == _selectedId;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedId = acc.id);
              widget.onAccountSelected?.call(acc);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 160,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top: Icon + Name
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          acc.icon,
                          size: 16,
                          color: isDark ? AppColors.darkForeground : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          acc.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Balance
                  Text(
                    CurrencyFormatter.formatVnd(acc.balance),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),

                  // Chip tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: acc.badgeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          acc.typeName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkMuted : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
