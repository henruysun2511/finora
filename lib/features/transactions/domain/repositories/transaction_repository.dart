import '../models/create_transaction_input.dart';
import '../models/monthly_transaction_summary.dart';
import '../models/transaction_item.dart';

abstract class TransactionRepository {
  /// Lấy sổ giao dịch gom nhóm theo ngày cho một tháng cụ thể (GET /transactions/daily-grid)
  Future<MonthlyTransactionSummary> getDailyGrid({
    required int month,
    required int year,
    String? walletId,
    String? accountId,
    String? categoryId,
    String? type,
  });

  /// Lấy danh sách giao dịch phân trang và bộ lọc (GET /transactions)
  Future<List<TransactionItem>> getTransactions({
    int page = 1,
    int limit = 20,
    String? accountId,
    String? categoryId,
    String? type,
    String? visibility,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Lấy thông tin chi tiết một giao dịch (GET /transactions/:id)
  Future<TransactionItem> getTransactionById(String id);

  /// Lấy chi tiết hóa đơn OCR đã quét (GET /transactions/receipts/:id)
  Future<Map<String, dynamic>> getReceiptById(String id);

  /// Tạo giao dịch Thu / Chi mới (POST /transactions)
  Future<TransactionItem> createTransaction(CreateTransactionInput input);

  /// Tạo giao dịch Chuyển khoản nội bộ (POST /transfers)
  Future<void> createTransfer(CreateTransactionInput input);

  /// Cập nhật thông tin giao dịch (PUT /transactions/:id)
  Future<TransactionItem> updateTransaction(String id, Map<String, dynamic> data);

  /// Xóa giao dịch tự động hoàn tác số dư (DELETE /transactions/:id)
  Future<void> deleteTransaction(String id);
}
