import 'package:finora_mb/features/loans/data/services/mock_loan_api_service.dart';
import 'package:finora_mb/features/loans/domain/models/loan.dart';
import 'package:finora_mb/features/loans/presentation/providers/loan_list_provider.dart';
import 'package:finora_mb/features/loans/presentation/providers/loan_providers.dart';
import 'package:finora_mb/features/loans/presentation/screens/create_loan_screen.dart';
import 'package:finora_mb/features/loans/presentation/screens/loan_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tạo khoản vay lưu được và trả kết quả về màn trước',
      (tester) async {
    final service = MockLoanApiService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loanApiServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: _LoanFormHost()),
      ),
    );

    await tester.tap(find.text('Mở tạo khoản nợ'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Nguyễn Lan Anh');
    await tester.enterText(find.byType(TextFormField).at(3), '2500000');
    final saveButton = find.text('Tạo và lưu vào sổ nợ');
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.textContaining('loan-100'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Khoản mới xuất hiện: true'), findsOneWidget);
  });

  testWidgets('chặn trả vượt nợ và tất toán khoản vay sau khi trả đủ',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanApiServiceProvider.overrideWithValue(MockLoanApiService()),
        ],
        child: const MaterialApp(
          home: LoanDetailScreen(loanId: 'loan-1'),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ghi nhận trả nợ'));
    await tester.pumpAndSettle();

    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '2000001');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Xác nhận'));
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();
    expect(
      find.text('Số tiền thanh toán không được vượt quá số nợ còn lại'),
      findsOneWidget,
    );

    await tester.enterText(amountField, '2000000');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Xác nhận'));
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.text('Khoản nợ đã tất toán'), findsOneWidget);
  });
}

class _LoanFormHost extends ConsumerStatefulWidget {
  const _LoanFormHost();

  @override
  ConsumerState<_LoanFormHost> createState() => _LoanFormHostState();
}

class _LoanFormHostState extends ConsumerState<_LoanFormHost> {
  String? _savedLoanId;

  @override
  Widget build(BuildContext context) {
    final loans = ref.watch(loanListProvider);
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<Loan>(
                MaterialPageRoute(
                  builder: (_) => const CreateLoanScreen(),
                ),
              );
              if (mounted) setState(() => _savedLoanId = result?.id);
            },
            child: const Text('Mở tạo khoản nợ'),
          ),
          if (_savedLoanId != null) Text('Đã lưu: $_savedLoanId'),
          loans.when(
            loading: () => const Text('Đang tải sổ nợ'),
            error: (error, _) => Text('Lỗi tải sổ nợ: $error'),
            data: (state) => Text(
              'Khoản mới xuất hiện: '
              '${state.items.any((loan) => loan.counterpartyName == 'Nguyễn Lan Anh')}',
            ),
          ),
        ],
      ),
    );
  }
}
