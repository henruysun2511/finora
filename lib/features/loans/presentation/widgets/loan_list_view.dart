import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_filter.dart';
import '../../domain/models/loan_status.dart';
import '../providers/loan_list_state.dart';
import 'loan_card.dart';
import 'loan_empty_state.dart';
import 'nora_overdue_card.dart';

class LoanListView extends StatelessWidget {
  const LoanListView({
    super.key,
    required this.state,
    required this.filter,
  });

  final LoanListState state;
  final LoanFilter filter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Loan? overdueLoan;
    for (final loan in state.items) {
      if (loan.effectiveStatus == LoanStatus.overdue) {
        overdueLoan = loan;
        break;
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        if (overdueLoan != null) ...[
          NoraOverdueCard(
            loan: overdueLoan,
            onTap: () => context.pushNamed(
              RouteNames.loanDetail,
              pathParameters: {'id': overdueLoan!.id},
            ),
          ),
        ],
        if (state.items.isEmpty)
          LoanEmptyState(
            filter: filter,
            isDark: isDark,
            onAdd: () => context.push(RoutePaths.createLoan),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
            child: Text(
              '${state.items.length} khoản nợ',
              style: AppTextStyles.titleMedium(
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
          ),
          for (final loan in state.items)
            LoanCard(
              loan: loan,
              onTap: () => context.pushNamed(
                RouteNames.loanDetail,
                pathParameters: {'id': loan.id},
              ),
            ),
        ],
      ],
    );
  }
}
