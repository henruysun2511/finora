import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/recurring-transaction-response.dart';
import '../dto/create-recurring-transaction-request.dart';

class RecurringTransactionApiService {
  RecurringTransactionApiService(this._dio);
  final Dio _dio;

  Future<List<RecurringTransactionResponse>> getRecurringTransactions(
      Map<String, dynamic> queryParams) async {
    final res = await _dio.get(
      ApiConstants.recurringTransactions,
      queryParameters: queryParams,
    );
    final responseData = res.data['data'];
    final List items = responseData is Map
        ? (responseData['items'] ?? responseData['data'] ?? [])
        : (responseData ?? []);
    return items
        .map((e) => RecurringTransactionResponse.fromJson(e))
        .toList();
  }

  Future<RecurringTransactionResponse> getRecurringTransactionById(
      String id) async {
    final res = await _dio.get(ApiConstants.recurringTransactionDetail(id));
    return RecurringTransactionResponse.fromJson(res.data['data']);
  }

  Future<RecurringTransactionResponse> createRecurringTransaction(
      CreateRecurringTransactionRequest req) async {
    final res = await _dio.post(
      ApiConstants.recurringTransactions,
      data: req.toJson(),
    );
    return RecurringTransactionResponse.fromJson(res.data['data']);
  }

  Future<void> executeNow(String id) async {
    await _dio.post(
        '${ApiConstants.recurringTransactions}/$id/execute-now');
  }

  Future<bool> togglePause(String id) async {
    final res = await _dio
        .patch('${ApiConstants.recurringTransactions}/$id/toggle-pause');
    final data = res.data['data'] as Map<String, dynamic>?;
    return data?['isPaused'] as bool? ?? false;
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _dio.delete(ApiConstants.recurringTransactionDetail(id));
  }
}