import '../models/budget.dart';
import '../models/budget_filter.dart';
import '../models/budget_input.dart';
import '../models/budget_live_status.dart';
import '../models/budget_period.dart';
import '../models/budget_summary.dart';

/// Hợp đồng dữ liệu nghiệp vụ (Repository Interface) cho tính năng Ngân sách.
/// Tầng Presentation chỉ biết Interface này, không phụ thuộc vào nguồn dữ liệu API hay Database.
abstract class BudgetRepository {
  /// Lấy danh sách ngân sách theo bộ lọc
  Future<List<Budget>> getBudgets(BudgetFilter filter);

  /// Lấy tổng quan ngân sách trong kỳ hiện tại
  Future<BudgetSummary> getBudgetSummary({String? walletId});

  /// Lấy chi tiết một ngân sách theo ID
  Future<Budget> getBudgetById(String id);

  /// Lấy tiến độ chi tiêu theo thời gian thực: GET /api/v1/budgets/:id/status
  Future<BudgetLiveStatus> getBudgetStatus(String id);

  /// Lấy lịch sử các chu kỳ trước của một ngân sách
  Future<List<BudgetPeriod>> getBudgetHistory(String id);

  /// Tạo mới ngân sách
  Future<Budget> createBudget(BudgetInput input);

  /// Cập nhật hạn mức / thiết lập ngân sách
  Future<Budget> updateBudget(String id, BudgetInput input);

  /// Xóa ngân sách
  Future<void> deleteBudget(String id);

  /// Chốt kỳ sang kỳ mới sớm (reset period)
  Future<Budget> resetBudgetPeriod(String id);
}
