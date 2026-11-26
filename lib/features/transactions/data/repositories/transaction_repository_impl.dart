import '../../domain/models/create_transaction_input.dart';
import '../../domain/models/daily_transaction_group.dart';
import '../../domain/models/monthly_transaction_summary.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../services/transaction_api_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._apiService);

  final TransactionApiService _apiService;

  @override
  Future<MonthlyTransactionSummary> getDailyGrid({
    required int month,
    required int year,
    String? walletId,
    String? accountId,
    String? categoryId,
    String? type,
  }) async {
    try {
      final dto = await _apiService.getDailyGrid(
        month: month,
        year: year,
        walletId: walletId,
        accountId: accountId,
        categoryId: categoryId,
        type: type,
      );
      return dto.toDomain();
    } catch (_) {
      // Trả về dữ liệu trống khi offline hoặc chưa có giao dịch
      return MonthlyTransactionSummary(
        month: month,
        year: year,
        totalIncome: 0,
        totalExpense: 0,
        netAmount: 0,
        totalTransactions: 0,
        days: const [],
      );
    }
  }

  @override
  Future<List<TransactionItem>> getTransactions({
    int page = 1,
    int limit = 20,
    String? accountId,
    String? categoryId,
    String? type,
    String? visibility,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final list = await _apiService.getTransactions(
        page: page,
        limit: limit,
        accountId: accountId,
        categoryId: categoryId,
        type: type,
        visibility: visibility,
        startDate: startDate,
        endDate: endDate,
      );
      return list.map((dto) => dto.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getReceiptById(String id) async {
    return _apiService.getReceiptById(id);
  }

  @override
  Future<TransactionItem> getTransactionById(String id) async {
    final dto = await _apiService.getTransactionById(id);
    return dto.toDomain();
  }

  @override
  Future<TransactionItem> createTransaction(
      CreateTransactionInput input) async {
    final dto =
        await _apiService.createTransaction(input.toTransactionJson());
    return dto.toDomain();
  }

  @override
  Future<void> createTransfer(CreateTransactionInput input) async {
    await _apiService.createTransfer(input.toTransferJson());
  }

  @override
  Future<TransactionItem> updateTransaction(
      String id, Map<String, dynamic> data) async {
    final dto = await _apiService.updateTransaction(id, data);
    return dto.toDomain();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _apiService.deleteTransaction(id);
  }
}

