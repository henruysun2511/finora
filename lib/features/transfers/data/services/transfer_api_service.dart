import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../dto/convert_currency_request.dart';
import '../dto/create_transfer_request.dart';

abstract class TransferApiService {
  Future<Map<String, dynamic>> createTransfer(CreateTransferRequest request);
  Future<Map<String, dynamic>> convertPreview(ConvertCurrencyRequest request);
  Future<Map<String, dynamic>> getTransfers({
    String? accountId,
    String? fromAccountId,
    String? toAccountId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getTransferById(String id);
}

class DioTransferApiService implements TransferApiService {
  final Dio _dio;

  DioTransferApiService(this._dio);

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

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> createTransfer(
    CreateTransferRequest request,
  ) =>
      _guard(() async {
        final res = await _dio.post('/transfers', data: request.toJson());
        return _extractData(res.data);
      });

  @override
  Future<Map<String, dynamic>> convertPreview(
    ConvertCurrencyRequest request,
  ) =>
      _guard(() async {
        final res = await _dio.post('/transfers/convert', data: request.toJson());
        return _extractData(res.data);
      });

  @override
  Future<Map<String, dynamic>> getTransfers({
    String? accountId,
    String? fromAccountId,
    String? toAccountId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) =>
      _guard(() async {
        final query = <String, dynamic>{
          'page': page,
          'limit': limit,
          if (accountId != null && accountId.isNotEmpty) 'accountId': accountId,
          if (fromAccountId != null && fromAccountId.isNotEmpty)
            'fromAccountId': fromAccountId,
          if (toAccountId != null && toAccountId.isNotEmpty)
            'toAccountId': toAccountId,
          if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
          if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
        };
        final res = await _dio.get('/transfers', queryParameters: query);
        if (res.data is Map<String, dynamic>) {
          return res.data as Map<String, dynamic>;
        }
        return <String, dynamic>{};
      });

  @override
  Future<Map<String, dynamic>> getTransferById(String id) => _guard(() async {
        final res = await _dio.get('/transfers/$id');
        return _extractData(res.data);
      });
}
