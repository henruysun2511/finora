import '../../domain/models/budget.dart';
import '../../domain/models/budget_enums.dart';
import '../../domain/models/budget_input.dart';
import '../../domain/models/budget_live_status.dart';
import '../../domain/models/budget_period.dart';
import '../dto/budget_period_response.dart';
import '../dto/budget_response.dart';
import '../dto/budget_status_response.dart';
import '../dto/create_budget_request.dart';
import '../dto/update_budget_request.dart';

/// Mapper chuyển đổi qua lại giữa DTO (mạng/JSON) và Entity (Domain).
/// Đây là nơi duy nhất hiểu cả hai tầng.
class BudgetMapper {
  BudgetMapper._();

  /// Chuyển đổi BudgetResponse (DTO) sang Budget (Domain Entity)
  static Budget toDomain(BudgetResponse dto) {
    return Budget(
      id: dto.id,
      walletId: dto.walletId,
      categoryId: dto.categoryId,
      limitAmount: dto.limitAmount,
      spentAmount: dto.spentAmount,
      rolloverAmount: dto.rolloverAmount,
      periodType: BudgetPeriodType.fromValue(dto.periodType),
      startDate: dto.startDate,
      endDate: dto.endDate,
      isRolloverEnabled: dto.isRolloverEnabled,
      walletName: dto.walletName,
      categoryName: dto.categoryName,
      categoryIcon: dto.categoryIcon,
      categoryColor: dto.categoryColor,
      historyPeriods: dto.periods?.map(toPeriodDomain).toList() ?? const [],
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Chuyển đổi BudgetPeriodResponse (DTO) sang BudgetPeriod (Domain Entity)
  static BudgetPeriod toPeriodDomain(BudgetPeriodResponse dto) {
    return BudgetPeriod(
      id: dto.id,
      budgetId: dto.budgetId,
      startDate: dto.startDate,
      endDate: dto.endDate,
      limitAmount: dto.limitAmount,
      spentAmount: dto.spentAmount,
      rolloverAmount: dto.rolloverAmount,
      isClosed: dto.isClosed,
    );
  }

  /// Chuyển đổi BudgetStatusResponse (DTO) sang BudgetLiveStatus (Domain Entity)
  static BudgetLiveStatus toStatusDomain(BudgetStatusResponse dto) {
    return BudgetLiveStatus(
      budgetId: dto.budgetId,
      effectiveLimit: dto.effectiveLimit,
      spentAmount: dto.spentAmount,
      remainingAmount: dto.remainingAmount,
      percentage: dto.percentage,
      dailyBudgetRemaining: dto.dailyBudgetRemaining,
      daysRemaining: dto.daysRemaining,
      status: BudgetProgressStatus.fromCode(dto.statusCode),
      rolloverAmount: dto.rolloverAmount,
      limitAmount: dto.limitAmount,
    );
  }

  /// Chuyển đổi BudgetInput (Domain) sang CreateBudgetRequest (DTO)
  static CreateBudgetRequest toCreateRequest(BudgetInput input) {
    return CreateBudgetRequest(
      walletId: input.walletId,
      categoryId: input.categoryId,
      limitAmount: input.limitAmount,
      periodType: input.periodType.value,
      startDate: input.startDate,
      isRolloverEnabled: input.isRolloverEnabled,
    );
  }

  /// Chuyển đổi BudgetInput (Domain) sang UpdateBudgetRequest (DTO)
  static UpdateBudgetRequest toUpdateRequest(BudgetInput input) {
    return UpdateBudgetRequest(
      limitAmount: input.limitAmount,
      periodType: input.periodType.value,
      isRolloverEnabled: input.isRolloverEnabled,
    );
  }
}
