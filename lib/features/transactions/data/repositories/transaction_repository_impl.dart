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
      // Fallback sample data nếu offline/lỗi mạng
      return _getSampleDailyGrid(month, year);
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
    try {
      final dto = await _apiService.getTransactionById(id);
      return dto.toDomain();
    } catch (_) {
      // Fallback
      return TransactionItem(
        id: id,
        accountId: 'acc-1',
        accountName: 'Vietcombank Digibank',
        categoryId: 'cat-food',
        categoryName: 'Ăn uống',
        categoryIcon: 'utensils',
        categoryColor: '#EF4444',
        type: TransactionType.expense,
        amount: 125000,
        currency: 'VND',
        name: 'Ăn trưa văn phòng cùng đồng nghiệp',
        note: 'Cơm trưa văn phòng',
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        balanceAfter: 34875000,
      );
    }
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

  MonthlyTransactionSummary _getSampleDailyGrid(int month, int year) {
    final now = DateTime.now();
    final today = DateTime(year, month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return MonthlyTransactionSummary(
      month: month,
      year: year,
      totalIncome: 25000000,
      totalExpense: 12450000,
      netAmount: 12550000,
      totalTransactions: 4,
      days: [
        DailyTransactionGroup(
          dateString: today.toIso8601String().substring(0, 10),
          date: today,
          dayOfWeek: 'Hôm nay',
          totalIncome: 0,
          totalExpense: 175000,
          netAmount: -175000,
          transactions: [
            TransactionItem(
              id: 'tx-1',
              accountId: 'acc-1',
              accountName: 'Vietcombank Digibank',
              categoryId: 'cat-food',
              categoryName: 'Ăn uống',
              categoryIcon: 'utensils',
              categoryColor: '#EF4444',
              type: TransactionType.expense,
              amount: 50000,
              currency: 'VND',
              name: 'Phở bò Cầu Giấy',
              note: 'Ăn trưa',
              transactionDate: today,
              createdAt: today,
            ),
            TransactionItem(
              id: 'tx-2',
              accountId: 'acc-2',
              accountName: 'Ví MoMo Family',
              categoryId: 'cat-coffee',
              categoryName: 'Cà phê & Đồ uống',
              categoryIcon: 'coffee',
              categoryColor: '#F59E0B',
              type: TransactionType.expense,
              amount: 125000,
              currency: 'VND',
              name: 'Highlands Coffee',
              note: 'Gặp gỡ khách hàng',
              transactionDate: today,
              createdAt: today,
            ),
          ],
        ),
        DailyTransactionGroup(
          dateString: yesterday.toIso8601String().substring(0, 10),
          date: yesterday,
          dayOfWeek: 'Hôm qua',
          totalIncome: 25000000,
          totalExpense: 850000,
          netAmount: 24150000,
          transactions: [
            TransactionItem(
              id: 'tx-3',
              accountId: 'acc-1',
              accountName: 'Vietcombank Digibank',
              categoryId: 'cat-salary',
              categoryName: 'Lương thưởng',
              categoryIcon: 'wallet',
              categoryColor: '#10B981',
              type: TransactionType.income,
              amount: 25000000,
              currency: 'VND',
              name: 'Nhận lương công ty FSI',
              note: 'Lương tháng',
              transactionDate: yesterday,
              createdAt: yesterday,
            ),
            TransactionItem(
              id: 'tx-4',
              accountId: 'acc-cash',
              accountName: 'Tiền mặt ví da',
              categoryId: 'cat-fuel',
              categoryName: 'Xăng xe & Di chuyển',
              categoryIcon: 'gas-pump',
              categoryColor: '#3B82F6',
              type: TransactionType.expense,
              amount: 85000,
              currency: 'VND',
              name: 'Đổ xăng Petrolimex',
              note: 'Đổ đầy bình',
              transactionDate: yesterday,
              createdAt: yesterday,
            ),
          ],
        ),
      ],
    );
  }
}

