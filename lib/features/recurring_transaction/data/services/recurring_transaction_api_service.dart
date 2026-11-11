import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/recurring_transaction_response.dart';
import '../dto/create_recurring_transaction_request.dart';
import '../dto/update_recurring_transaction_request.dart';

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
        .map((e) => RecurringTransactionResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RecurringTransactionResponse> getRecurringTransactionById(
      String id) async {
    final res = await _dio.get(ApiConstants.recurringTransactionDetail(id));
    return RecurringTransactionResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<RecurringTransactionResponse> createRecurringTransaction(
      CreateRecurringTransactionRequest req) async {
    final res = await _dio.post(
      ApiConstants.recurringTransactions,
      data: req.toJson(),
    );
    return RecurringTransactionResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<RecurringTransactionResponse> updateRecurringTransaction(
      String id, UpdateRecurringTransactionRequest req) async {
    final res = await _dio.patch(
      ApiConstants.recurringTransactionDetail(id),
      data: req.toJson(),
    );
    return RecurringTransactionResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> executeNow(String id) async {
    await _dio.post(ApiConstants.recurringTransactionExecuteNow(id));
  }

  Future<bool> togglePause(String id) async {
    final res = await _dio.patch(ApiConstants.recurringTransactionTogglePause(id));
    final data = res.data['data'] as Map<String, dynamic>?;
    return data?['isPaused'] as bool? ?? false;
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _dio.delete(ApiConstants.recurringTransactionDetail(id));
  }
}
