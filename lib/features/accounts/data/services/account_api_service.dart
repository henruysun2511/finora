import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../dto/adjust_balance_request.dart';
import '../dto/create_account_request.dart';
import '../dto/update_account_request.dart';

abstract class AccountApiService {
  Future<List<Map<String, dynamic>>> getAccounts({
    String? walletId,
    int page = 1,
    int limit = 50,
  });
  Future<Map<String, dynamic>> getAccountById(String id);
  Future<Map<String, dynamic>> getAccountBalance(String id);
  Future<Map<String, dynamic>> createAccount(
    CreateAccountRequest request, {
    String? idempotencyKey,
  });
  Future<Map<String, dynamic>> updateAccount(
    String id,
    UpdateAccountRequest request,
  );
  Future<Map<String, dynamic>> archiveAccount(String id);
  Future<Map<String, dynamic>> unarchiveAccount(String id);
  Future<void> deleteAccount(String id);
  Future<Map<String, dynamic>> adjustBalance(
    String id,
    AdjustBalanceRequest request, {
    required String idempotencyKey,
  });
}

class DioAccountApiService implements AccountApiService {
  final Dio _dio;

  DioAccountApiService(this._dio);

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
    }
    return responseData;
  }

  @override
  Future<List<Map<String, dynamic>>> getAccounts({
    String? walletId,
    int page = 1,
    int limit = 50,
  }) => _guard(() async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (walletId != null && walletId.isNotEmpty) {
      query['walletId'] = walletId;
    }
    final res = await _dio.get('/accounts', queryParameters: query);
    final data = _extractData(res.data);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    } else if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  });

  @override
  Future<Map<String, dynamic>> getAccountById(String id) => _guard(() async {
    final res = await _dio.get('/accounts/$id');
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> getAccountBalance(String id) => _guard(() async {
    final res = await _dio.get('/accounts/$id/balance');
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> createAccount(
    CreateAccountRequest request, {
    String? idempotencyKey,
  }) => _guard(() async {
    final options = Options();
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      options.headers = {'Idempotency-Key': idempotencyKey};
    }
    final res = await _dio.post(
      '/accounts',
      data: request.toJson(),
      options: options,
    );
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> updateAccount(
    String id,
    UpdateAccountRequest request,
  ) => _guard(() async {
    final res = await _dio.patch('/accounts/$id', data: request.toJson());
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> archiveAccount(String id) => _guard(() async {
    final res = await _dio.post('/accounts/$id/archive');
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> unarchiveAccount(String id) => _guard(() async {
    final res = await _dio.post('/accounts/$id/unarchive');
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<void> deleteAccount(String id) => _guard(() async {
    await _dio.delete('/accounts/$id');
  });

  @override
  Future<Map<String, dynamic>> adjustBalance(
    String id,
    AdjustBalanceRequest request, {
    required String idempotencyKey,
  }) => _guard(() async {
    final options = Options(headers: {'Idempotency-Key': idempotencyKey});
    final res = await _dio.post(
      '/accounts/$id/balance-adjustments',
      data: request.toJson(),
      options: options,
    );
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });
}

