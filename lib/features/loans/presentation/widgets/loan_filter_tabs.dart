import 'package:flutter/material.dart';

import '../../domain/models/loan_filter.dart';
import '../../domain/models/loan_status.dart';
import '../../domain/models/loan_type.dart';
import 'loan_filter_row.dart';

enum LoanTab { all, lent, borrowed, installment, settled }

class LoanFilterTabs extends StatelessWidget {
  const LoanFilterTabs({
    super.key,
    required this.filter,
    required this.onTabSelected,
  });

  final LoanFilter filter;
  final ValueChanged<LoanTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final selectedTab = filter.status == LoanStatus.settled
        ? LoanTab.settled
        : switch (filter.type) {
            LoanType.lent => LoanTab.lent,
            LoanType.borrowed => LoanTab.borrowed,
            LoanType.installment => LoanTab.installment,
            null => LoanTab.all,
          };

    return SizedBox(
      height: 52,
      child: LoanFilterRow<LoanTab>(
        options: const [
          FilterOption(
            label: 'Tất cả',
            value: LoanTab.all,
            icon: Icons.layers_outlined,
          ),
          FilterOption(
            label: 'Cho vay',
            value: LoanTab.lent,
            icon: Icons.arrow_outward_rounded,
          ),
          FilterOption(
            label: 'Đi vay',
            value: LoanTab.borrowed,
            icon: Icons.south_west_rounded,
          ),
          FilterOption(
            label: 'Trả góp',
            value: LoanTab.installment,
            icon: Icons.credit_card_rounded,
          ),
          FilterOption(
            label: 'Đã xong',
            value: LoanTab.settled,
            icon: Icons.task_alt_rounded,
          ),
        ],
        selected: selectedTab,
        onSelected: onTabSelected,
      ),
    );
  }
}
