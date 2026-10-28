import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/errors/app_exception.dart';
import '../dto/loan_request.dart';
import '../dto/loan_response.dart';
import '../dto/loan_summary_response.dart';

/// Abstract interface và Dio implementation cho Loans API
abstract class LoanApiService {
  Future<List<LoanResponse>> getLoans({
    String? type,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  Future<LoanSummaryResponse> getLoanSummary();

  Future<LoanResponse> getLoanById(String id);

  Future<LoanResponse> createLoan(CreateLoanRequest request);

  Future<LoanResponse> updateLoan(String id, UpdateLoanRequest request);

  Future<void> deleteLoan(String id);

  Future<LoanPaymentResponse> recordPayment(
      String loanId, CreateLoanPaymentRequest request);

  Future<List<LoanPaymentResponse>> getLoanPayments(String loanId);

  Future<void> sendReminder(String loanId);

  Future<void> removeCounterparty(String loanId);
}

class DioLoanApiService implements LoanApiService {
  DioLoanApiService(this._dio);

  final Dio _dio;
  static const _path = '/loans';

  List<dynamic> _extractList(dynamic data) {
    dynamic current = data;
    for (var depth = 0; depth < 3; depth++) {
      if (current is List) return current;
      if (current is Map<String, dynamic>) {
        final items = current['items'] ?? current['results'];
        if (items is List) return items;
        if (!current.containsKey('data')) break;
        current = current['data'];
      } else {
        break;
      }
    }
    throw const AppException(
      'Dữ liệu danh sách khoản vay từ máy chủ không đúng định dạng.',
    );
  }

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
      'Dữ liệu khoản vay từ máy chủ không đúng định dạng.',
    );
  }

  @override
  Future<List<LoanResponse>> getLoans({
    String? type,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) =>
      _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          _path,
          queryParameters: {
            if (type != null) 'type': type,
            if (status != null) 'status': status,
            if (search != null) 'search': search,
            if (sortBy != null) 'sortBy': sortBy,
            if (sortOrder != null) 'sortOrder': sortOrder,
          },
        );
        final list = _extractList(res.data);
        return list
            .map((e) => LoanResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<LoanSummaryResponse> getLoanSummary() => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('$_path/summary');
        return LoanSummaryResponse.fromJson(_extractMap(res.data));
      });

  @override
  Future<LoanResponse> getLoanById(String id) => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('$_path/$id');
        return LoanResponse.fromJson(_extractMap(res.data));
      });

  @override
  Future<LoanResponse> createLoan(CreateLoanRequest request) =>
      _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          _path,
          data: request.toJson(),
        );
        return LoanResponse.fromJson(_extractMap(res.data));
      });

  @override
  Future<LoanResponse> updateLoan(String id, UpdateLoanRequest request) =>
      _guard(() async {
        final res = await _dio.put<Map<String, dynamic>>(
          '$_path/$id',
          data: request.toJson(),
        );
        return LoanResponse.fromJson(_extractMap(res.data));
      });

  @override
  Future<void> deleteLoan(String id) => _guard<void>(() async {
        await _dio.delete<void>('$_path/$id');
      });

  @override
  Future<LoanPaymentResponse> recordPayment(
    String loanId,
    CreateLoanPaymentRequest request,
  ) =>
      _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '$_path/$loanId/payments',
          data: request.toJson(),
        );
        return LoanPaymentResponse.fromJson(_extractMap(res.data));
      });

  @override
  Future<List<LoanPaymentResponse>> getLoanPayments(String loanId) =>
      _guard(() async {
        final res =
            await _dio.get<Map<String, dynamic>>('$_path/$loanId/payments');
        final list = _extractList(res.data);
        return list
            .map((e) => LoanPaymentResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<void> sendReminder(String loanId) => _guard<void>(() async {
        await _dio.post<void>('$_path/$loanId/remind');
      });

  @override
  Future<void> removeCounterparty(String loanId) => _guard<void>(() async {
        await _dio.delete<void>('$_path/$loanId/counterparty');
      });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    }
  }
}
