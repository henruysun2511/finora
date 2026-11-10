import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/daily_grid_response_dto.dart';
import '../dto/transaction_response_dto.dart';

abstract class TransactionApiService {
  Future<DailyGridResponseDto> getDailyGrid({
    required int month,
    required int year,
    String? walletId,
    String? accountId,
    String? categoryId,
    String? type,
  });

  Future<TransactionResponseDto> getTransactionById(String id);

  Future<TransactionResponseDto> createTransaction(Map<String, dynamic> body);

  Future<TransactionResponseDto> updateTransaction(
      String id, Map<String, dynamic> body);

  Future<void> deleteTransaction(String id);

  Future<void> createTransfer(Map<String, dynamic> body);

  Future<List<TransactionResponseDto>> getTransactions({
    int page = 1,
    int limit = 20,
    String? accountId,
    String? categoryId,
    String? type,
    String? visibility,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Map<String, dynamic>> getReceiptById(String id);
}

class DioTransactionApiService implements TransactionApiService {
  DioTransactionApiService(this._dio);

  final Dio _dio;

  Map<String, dynamic> _extractMap(dynamic data) {
    dynamic current = data;
    for (var depth = 0; depth < 3; depth++) {
      if (current is! Map<String, dynamic>) break;
      if (current['data'] is Map<String, dynamic>) {
        current = current['data'];
        continue;
      }
      return current;
    }
    throw const AppException(
      'Dữ liệu giao dịch từ máy chủ không đúng định dạng.',
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  @override
  Future<DailyGridResponseDto> getDailyGrid({
    required int month,
    required int year,
    String? walletId,
    String? accountId,
    String? categoryId,
    String? type,
  }) =>
      _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/transactions/daily-grid',
          queryParameters: {
            'month': month,
            'year': year,
            if (walletId != null) 'walletId': walletId,
            if (accountId != null) 'accountId': accountId,
            if (categoryId != null) 'categoryId': categoryId,
            if (type != null) 'type': type,
          },
        );
        final map = _extractMap(res.data);
        return DailyGridResponseDto.fromJson(map);
      });

  @override
  Future<TransactionResponseDto> getTransactionById(String id) =>
      _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/transactions/$id');
        final map = _extractMap(res.data);
        return TransactionResponseDto.fromJson(map);
      });

  @override
  Future<TransactionResponseDto> createTransaction(
          Map<String, dynamic> body) =>
      _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/transactions',
          data: body,
        );
        final map = _extractMap(res.data);
        return TransactionResponseDto.fromJson(map);
      });

  @override
  Future<TransactionResponseDto> updateTransaction(
          String id, Map<String, dynamic> body) =>
      _guard(() async {
        final res = await _dio.put<Map<String, dynamic>>(
          '/transactions/$id',
          data: body,
        );
        final map = _extractMap(res.data);
        return TransactionResponseDto.fromJson(map);
      });

  @override
  Future<void> deleteTransaction(String id) => _guard(() async {
        await _dio.delete<dynamic>('/transactions/$id');
      });

  @override
  Future<void> createTransfer(Map<String, dynamic> body) => _guard(() async {
        await _dio.post<dynamic>(
          '/transfers',
          data: body,
        );
      });

  @override
  Future<List<TransactionResponseDto>> getTransactions({
    int page = 1,
    int limit = 20,
    String? accountId,
    String? categoryId,
    String? type,
    String? visibility,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _guard(() async {
        final res = await _dio.get<dynamic>(
          '/transactions',
          queryParameters: {
            'page': page,
            'limit': limit,
            if (accountId != null) 'accountId': accountId,
            if (categoryId != null) 'categoryId': categoryId,
            if (type != null) 'type': type,
            if (visibility != null) 'visibility': visibility,
            if (startDate != null) 'startDate': startDate.toIso8601String(),
            if (endDate != null) 'endDate': endDate.toIso8601String(),
          },
        );

        final data = res.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic>) {
          if (data['items'] is List) {
            list = data['items'] as List<dynamic>;
          } else if (data['data'] is Map && data['data']['items'] is List) {
            list = data['data']['items'] as List<dynamic>;
          } else if (data['data'] is List) {
            list = data['data'] as List<dynamic>;
          }
        } else if (data is List) {
          list = data;
        }

        return list
            .whereType<Map<String, dynamic>>()
            .map(TransactionResponseDto.fromJson)
            .toList();
      });

  @override
  Future<Map<String, dynamic>> getReceiptById(String id) => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/transactions/receipts/$id');
        return _extractMap(res.data);
      });
}

