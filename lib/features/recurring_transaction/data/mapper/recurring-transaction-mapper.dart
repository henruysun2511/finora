import '../../domain/models/recurring-transaction.dart';
import '../../domain/models/recurring-transaction-input.dart';
import '../../domain/models/recurring-enum.dart';
import '../dto/recurring-transaction-response.dart';
import '../dto/create-recurring-transaction-request.dart';

class RecurringTransactionMapper {
  /// Chuyển DTO → Domain Entity
  static RecurringTransaction toDomain(RecurringTransactionResponse dto) {
    return RecurringTransaction(
      id: dto.id,
      name: dto.name,
      amount: dto.amount.toDouble(),
      type: TransactionType.fromBackend(dto.type),
      frequency: RecurringFrequency.fromBackend(dto.frequency),
      currency: dto.currency,
      isPaused: dto.isPaused,
      nextRunDate: _parseDate(dto.nextRunDate),
      createdAt: _parseDate(dto.createdAt),
      accountName: dto.accountName,
      categoryId: dto.category?.id,
      categoryName: dto.category?.name,
      categoryIcon: dto.category?.icon,
      endDate: dto.endDate != null ? DateTime.tryParse(dto.endDate!) : null,
      // Detail fields
      totalExecutedTimes: dto.totalExecutedTimes,
      totalAmountSpent: dto.totalAmountSpent?.toDouble(),
      executionHistory: dto.executionHistory
          ?.map((e) => RecurringExecutionHistory(
                transactionId: e.transactionId,
                amount: e.amount.toDouble(),
                date: _parseDate(e.date),
              ))
          .toList(),
    );
  }

  /// Chuyển Input → Create Request DTO
  static CreateRecurringTransactionRequest toCreateRequest(
      RecurringTransactionInput input) {
    return CreateRecurringTransactionRequest(
      walletId: input.walletId,
      accountId: input.accountId,
      categoryId: input.categoryId,
      name: input.name,
      type: input.type.backendValue,
      amount: input.amount,
      frequency: input.frequency.backendValue,
      startDate: input.startDate.toIso8601String(),
      currency: input.currency,
      endDate: input.endDate?.toIso8601String(),
      executeImmediately: input.executeImmediately,
    );
  }

  static DateTime _parseDate(String isoString) {
    return DateTime.tryParse(isoString) ?? DateTime.now();
  }
}