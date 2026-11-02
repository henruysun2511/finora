import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/budgets/data/dto/budget_period_response.dart';
import 'package:finora_mb/features/budgets/data/dto/budget_response.dart';
import 'package:finora_mb/features/budgets/data/mappers/budget_mapper.dart';
import 'package:finora_mb/features/budgets/domain/models/budget_enums.dart';
import 'package:finora_mb/features/budgets/domain/models/budget_input.dart';

void main() {
  group('BudgetMapper - toDomain', () {
    test('chuyển đổi đúng từ BudgetResponse sang Budget domain entity', () {
      final now = DateTime(2026, 10, 1);
      final dto = BudgetResponse(
        id: 'budget-1',
        walletId: 'wallet-1',
        categoryId: 'cat-1',
        limitAmount: 5000000,
        spentAmount: 3500000,
        rolloverAmount: 200000,
        periodType: 'MONTHLY',
        startDate: now,
        endDate: DateTime(2026, 10, 31),
        isRolloverEnabled: true,
        walletName: 'Ví Cá Nhân',
        categoryName: 'Ăn uống',
        categoryIcon: 'food',
      );

      final domain = BudgetMapper.toDomain(dto);

      expect(domain.id, 'budget-1');
      expect(domain.limitAmount, 5000000.0);
      expect(domain.spentAmount, 3500000.0);
      expect(domain.rolloverAmount, 200000.0);
      expect(domain.effectiveLimit, 5200000.0);
      expect(domain.remainingAmount, 1700000.0);
      expect(domain.periodType, BudgetPeriodType.monthly);
      expect(domain.status, BudgetProgressStatus.safe);
    });

    test('tự động nhận diện trạng thái WARNING và EXCEEDED', () {
      final now = DateTime(2026, 10, 1);
      final warningDto = BudgetResponse(
        id: 'budget-2',
        walletId: 'w-1',
        categoryId: 'c-1',
        limitAmount: 2000000,
        spentAmount: 1700000, // 85%
        startDate: now,
      );
      expect(BudgetMapper.toDomain(warningDto).status, BudgetProgressStatus.warning);

      final exceededDto = BudgetResponse(
        id: 'budget-3',
        walletId: 'w-1',
        categoryId: 'c-1',
        limitAmount: 1000000,
        spentAmount: 1200000, // 120%
        startDate: now,
      );
      expect(BudgetMapper.toDomain(exceededDto).status, BudgetProgressStatus.exceeded);
    });
  });

  group('BudgetMapper - toPeriodDomain', () {
    test('chuyển đổi đúng từ BudgetPeriodResponse sang BudgetPeriod', () {
      final start = DateTime(2026, 9, 1);
      final end = DateTime(2026, 9, 30);
      final dto = BudgetPeriodResponse(
        id: 'period-1',
        budgetId: 'budget-1',
        startDate: start,
        endDate: end,
        limitAmount: 5000000,
        spentAmount: 4800000,
        rolloverAmount: 0,
        isClosed: true,
      );

      final period = BudgetMapper.toPeriodDomain(dto);
      expect(period.id, 'period-1');
      expect(period.effectiveLimit, 5000000);
      expect(period.varianceAmount, 200000); // Tiết kiệm được +200k
    });
  });

  group('BudgetMapper - toCreateRequest & toUpdateRequest', () {
    test('chuyển đổi đúng từ BudgetInput sang DTO requests', () {
      final input = BudgetInput(
        walletId: 'wallet-99',
        categoryId: 'cat-99',
        limitAmount: 3000000,
        periodType: BudgetPeriodType.weekly,
        startDate: DateTime(2026, 10, 5),
        isRolloverEnabled: true,
      );

      final createReq = BudgetMapper.toCreateRequest(input);
      expect(createReq.walletId, 'wallet-99');
      expect(createReq.periodType, 'WEEKLY');
      expect(createReq.limitAmount, 3000000);

      final updateReq = BudgetMapper.toUpdateRequest(input);
      expect(updateReq.periodType, 'WEEKLY');
      expect(updateReq.limitAmount, 3000000);
    });
  });
}

