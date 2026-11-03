import '../models/recurring-transaction.dart';
import '../models/recurring-transaction-input.dart';
import '../models/recurring-transaction-filter.dart';
import '../models/recurring-enum.dart';

abstract class RecurringTransactionRepository {
  Future<List<RecurringTransaction>> getRecurringTransactions(RecurringTransactionFilter filter);
  Future<RecurringTransaction> getRecurringTransactionById(String id);
  Future<RecurringTransaction> createRecurringTransaction(RecurringTransactionInput input);
  Future<void> deleteRecurringTransaction(String id);
  Future<bool> togglePause(String id);
  Future<void> executeNow(String id);
}