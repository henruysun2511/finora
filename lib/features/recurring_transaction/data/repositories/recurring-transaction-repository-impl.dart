import '../../domain/models/recurring-transaction.dart';
import '../../domain/models/recurring-transaction-input.dart';
import '../../domain/models/recurring-transaction-filter.dart';
import '../../domain/repositories/recurring-transaction-repository.dart';
import '../services/recurring-transaction-api-service.dart';
import '../mapper/recurring-transaction-mapper.dart';

class RecurringTransactionRepositoryImpl implements RecurringTransactionRepository {
  RecurringTransactionRepositoryImpl(this._api);
  final RecurringTransactionApiService _api;

  @override
  Future<List<RecurringTransaction>> getRecurringTransactions(
      RecurringTransactionFilter filter) async {
    final dtos = await _api.getRecurringTransactions(filter.toQueryMap());
    return dtos.map(RecurringTransactionMapper.toDomain).toList();
  }

  @override
  Future<RecurringTransaction> getRecurringTransactionById(String id) async {
    final dto = await _api.getRecurringTransactionById(id);
    return RecurringTransactionMapper.toDomain(dto);
  }

  @override
  Future<RecurringTransaction> createRecurringTransaction(
      RecurringTransactionInput input) async {
    final req = RecurringTransactionMapper.toCreateRequest(input);
    final res = await _api.createRecurringTransaction(req);
    return RecurringTransactionMapper.toDomain(res);
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    await _api.deleteRecurringTransaction(id);
  }

  @override
  Future<bool> togglePause(String id) async {
    return _api.togglePause(id);
  }

  @override
  Future<void> executeNow(String id) async {
    await _api.executeNow(id);
  }
}