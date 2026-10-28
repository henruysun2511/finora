import 'package:finora_mb/features/loans/data/services/mock_loan_api_service.dart';
import 'package:finora_mb/features/loans/domain/models/loan_filter.dart';
import 'package:finora_mb/features/loans/domain/models/loan_status.dart';
import 'package:finora_mb/features/loans/domain/models/loan_type.dart';
import 'package:finora_mb/features/loans/presentation/providers/loan_filter_provider.dart';
import 'package:finora_mb/features/loans/presentation/providers/loan_providers.dart';
import 'package:finora_mb/features/loans/presentation/screens/loans_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hiển thị các khoản vay từ repository thay cho placeholder',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanApiServiceProvider.overrideWithValue(MockLoanApiService()),
        ],
        child: const MaterialApp(home: LoansScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('VỊ THẾ NỢ RÒNG'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Hoàng Long'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Hoàng Long'), findsOneWidget);
    expect(find.text('Sổ ghi nợ'), findsOneWidget);
    expect(find.textContaining('Ghi chép minh bạch'), findsNothing);
  });

  testWidgets('tab Đã xong lọc khoản đã tất toán, không giữ loại vay cũ',
      (tester) async {
    LoanFilter? currentFilter;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanApiServiceProvider.overrideWithValue(MockLoanApiService()),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              currentFilter = ref.watch(loanFilterProvider);
              return const LoansScreen();
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.text('🤝 Cho vay').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(currentFilter?.type, LoanType.lent);

    await tester.tap(find.text('✅ Đã xong'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Thanh Hà'), findsOneWidget);
    expect(find.text('Hoàng Long'), findsNothing);
    expect(currentFilter?.type, isNull);
    expect(currentFilter?.status, LoanStatus.settled);
  });
}
