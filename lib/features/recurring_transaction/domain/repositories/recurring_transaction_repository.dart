import '../models/recurring_transaction.dart';
import '../models/recurring_transaction_input.dart';
import '../models/recurring_transaction_filter.dart';

abstract class RecurringTransactionRepository {
  Future<List<RecurringTransaction>> getRecurringTransactions(
      RecurringTransactionFilter filter);
  Future<RecurringTransaction> getRecurringTransactionById(String id);
  Future<RecurringTransaction> createRecurringTransaction(
      RecurringTransactionInput input);
  Future<RecurringTransaction> updateRecurringTransaction(
      String id, RecurringTransactionInput input);
  Future<void> deleteRecurringTransaction(String id);
  Future<bool> togglePause(String id);
  Future<void> executeNow(String id);
}
