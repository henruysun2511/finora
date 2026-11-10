import '../../domain/models/recurring_transaction.dart';
import '../../domain/models/recurring_transaction_input.dart';
import '../../domain/models/recurring_transaction_filter.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../services/recurring_transaction_api_service.dart';
import '../mapper/recurring_transaction_mapper.dart';

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
  Future<RecurringTransaction> updateRecurringTransaction(
      String id, RecurringTransactionInput input) async {
    final req = RecurringTransactionMapper.toUpdateRequest(input);
    final res = await _api.updateRecurringTransaction(id, req);
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
