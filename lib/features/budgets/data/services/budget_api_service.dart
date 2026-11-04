import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../dto/budget_period_response.dart';
import '../dto/budget_response.dart';
import '../dto/budget_status_response.dart';
import '../dto/create_budget_request.dart';
import '../dto/update_budget_request.dart';

abstract class BudgetApiService {
  Future<List<BudgetResponse>> getBudgets({String? walletId, String? periodType});
  Future<BudgetResponse> getBudgetById(String id);
  Future<BudgetStatusResponse> getBudgetStatus(String id);
  Future<List<BudgetPeriodResponse>> getBudgetHistory(String id);
  Future<BudgetResponse> createBudget(CreateBudgetRequest request);
  Future<BudgetResponse> updateBudget(String id, UpdateBudgetRequest request);
  Future<void> deleteBudget(String id);
  Future<BudgetResponse> resetBudgetPeriod(String id);
}

class DioBudgetApiService implements BudgetApiService {
  DioBudgetApiService(this._dio);

  final Dio _dio;
  static const _basePath = '/budgets';

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      String? message;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? data['error'] as String?;
      }
      throw AppException(
        message ?? e.message ?? 'Đã xảy ra lỗi khi kết nối máy chủ',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    }
    return responseData;
  }

  @override
  Future<List<BudgetResponse>> getBudgets({String? walletId, String? periodType}) =>
      _guard(() async {
        final query = <String, dynamic>{
          'limit': 100, // Lấy toàn bộ ngân sách thay vì chỉ 10 mục mặc định
        };
        if (walletId != null && walletId.isNotEmpty) query['walletId'] = walletId;
        if (periodType != null && periodType.isNotEmpty) {
          // Chỉ gửi query 'period' khớp với RecurrencePeriod trong NestJS DTO
          query['period'] = periodType.toLowerCase();
        }

        final res = await _dio.get<dynamic>(_basePath, queryParameters: query);
        final raw = _extractData(res.data);

        List<dynamic> items = [];
        if (raw is List) {
          items = raw;
        } else if (raw is Map<String, dynamic>) {
          if (raw['items'] is List) {
            items = raw['items'] as List;
          } else if (raw['data'] is Map<String, dynamic> && raw['data']['items'] is List) {
            items = raw['data']['items'] as List;
          } else if (raw['data'] is List) {
            items = raw['data'] as List;
          }
        }

        return items
            .map((e) => BudgetResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<BudgetResponse> getBudgetById(String id) => _guard(() async {
        final res = await _dio.get<dynamic>('$_basePath/$id');
        final raw = _extractData(res.data);
        return BudgetResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<BudgetStatusResponse> getBudgetStatus(String id) => _guard(() async {
        final res = await _dio.get<dynamic>('$_basePath/$id/status');
        final raw = _extractData(res.data);
        return BudgetStatusResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<List<BudgetPeriodResponse>> getBudgetHistory(String id) => _guard(() async {
        // Backend NestJS trả về danh sách periods ngay trong GET /budgets/:id
        final budget = await getBudgetById(id);
        if (budget.periods != null && budget.periods!.isNotEmpty) {
          return budget.periods!;
        }
        return <BudgetPeriodResponse>[];
      });

  @override
  Future<BudgetResponse> createBudget(CreateBudgetRequest request) => _guard(() async {
        final res = await _dio.post<dynamic>(_basePath, data: request.toJson());
        final raw = _extractData(res.data);
        return BudgetResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<BudgetResponse> updateBudget(String id, UpdateBudgetRequest request) =>
      _guard(() async {
        final res = await _dio.put<dynamic>('$_basePath/$id', data: request.toJson());
        final raw = _extractData(res.data);
        return BudgetResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<void> deleteBudget(String id) => _guard(() async {
        await _dio.delete<dynamic>('$_basePath/$id');
      });

  @override
  Future<BudgetResponse> resetBudgetPeriod(String id) => _guard(() async {
        final res = await _dio.post<dynamic>('$_basePath/$id/reset-period');
        final raw = _extractData(res.data);
        return BudgetResponse.fromJson(raw as Map<String, dynamic>);
      });
}
