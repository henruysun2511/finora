import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/convert_currency_response_dto.dart';
import '../dto/exchange_rate_response_dto.dart';

abstract class ExchangeRateApiService {
  Future<ExchangeRateResponseDto> getExchangeRate(String from, String to);

  Future<ConvertCurrencyResponseDto> convertCurrency({
    required String from,
    required String to,
    required double amount,
  });
}

class DioExchangeRateApiService implements ExchangeRateApiService {
  DioExchangeRateApiService(this._dio);

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
      'Dữ liệu tỷ giá từ máy chủ không đúng định dạng.',
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
  Future<ExchangeRateResponseDto> getExchangeRate(String from, String to) =>
      _guard(() async {
        final path = ApiConstants.exchangeRate(from, to);
        final response = await _dio.get<Map<String, dynamic>>(path);
        final map = _extractMap(response.data);
        return ExchangeRateResponseDto.fromJson(map);
      });

  @override
  Future<ConvertCurrencyResponseDto> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) =>
      _guard(() async {
        final path = ApiConstants.exchangeRate(from, to);
        final response = await _dio.get<Map<String, dynamic>>(
          path,
          queryParameters: {'amount': amount},
        );
        final map = _extractMap(response.data);
        return ConvertCurrencyResponseDto.fromJson(map);
      });
}

