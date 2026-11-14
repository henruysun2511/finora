import 'package:dio/dio.dart';
import '../../domain/models/expense_split_model.dart';
import '../../domain/models/my_splits_summary_model.dart';
import '../../domain/models/split_participant_model.dart';

class SplitApiService {
  const SplitApiService(this._dio);
  final Dio _dio;

  /// 1. Tạo phiên chia tiền cho giao dịch: POST /transactions/:transactionId/splits
  Future<ExpenseSplitModel> createSplit({
    required String transactionId,
    required String splitType,
    required List<Map<String, dynamic>> participants,
  }) async {
    final res = await _dio.post(
      '/transactions/$transactionId/splits',
      data: {
        'splitType': splitType.toLowerCase(),
        'participants': participants,
      },
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return ExpenseSplitModel.fromJson(data);
  }

  /// 2. Lấy thông tin phiên chia theo transactionId: GET /transactions/:transactionId/splits
  Future<ExpenseSplitModel> getSplitByTransactionId(String transactionId) async {
    final res = await _dio.get('/transactions/$transactionId/splits');
    final data = res.data['data'] as Map<String, dynamic>;
    return ExpenseSplitModel.fromJson(data);
  }

  /// 3. Lấy chi tiết phiên chia tiền: GET /splits/:splitId
  Future<ExpenseSplitModel> getSplitById(String splitId) async {
    final res = await _dio.get('/splits/$splitId');
    final data = res.data['data'] as Map<String, dynamic>;
    return ExpenseSplitModel.fromJson(data);
  }

  /// 4. Lấy danh sách các phiên chia tiền của tôi: GET /splits/me
  Future<List<ExpenseSplitModel>> getMySplits({
    int page = 1,
    int limit = 20,
    String? status,
    bool? asOwner,
    bool? asParticipant,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) query['status'] = status.toLowerCase();
    if (asOwner == true) {
      query['role'] = 'owner';
    } else if (asParticipant == true) {
      query['role'] = 'participant';
    } else {
      query['role'] = 'all';
    }

    final res = await _dio.get('/splits/me', queryParameters: query);
    final rawData = res.data['data'];
    final List items = rawData is List
        ? rawData
        : (rawData is Map ? (rawData['items'] ?? rawData['data'] ?? []) : []);

    return items
        .map((e) => ExpenseSplitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 5. Lấy thống kê tổng quan: GET /splits/summary
  Future<MySplitsSummaryModel> getSummary() async {
    final res = await _dio.get('/splits/summary');
    final raw = res.data is Map ? (res.data['data'] ?? res.data) : res.data;
    if (raw is Map<String, dynamic>) {
      return MySplitsSummaryModel.fromJson(raw);
    }
    return MySplitsSummaryModel.empty;
  }

  /// 6. Phản hồi yêu cầu chia tiền (accept, reject, propose): POST /splits/:splitId/respond
  Future<SplitParticipantModel> respondSplit({
    required String splitId,
    required String action,
    double? proposedAmount,
    String? note,
  }) async {
    final payload = <String, dynamic>{'action': action};
    if (proposedAmount != null && proposedAmount > 0) {
      payload['proposedAmount'] = proposedAmount;
    }
    if (note != null && note.isNotEmpty) {
      payload['note'] = note;
    }

    final res = await _dio.post('/splits/$splitId/respond', data: payload);
    final data = res.data['data'] as Map<String, dynamic>;
    return SplitParticipantModel.fromJson(data);
  }

  /// 7. Chủ phiên điều chỉnh lại tiền (Rebalance): PUT /splits/:splitId/rebalance
  Future<ExpenseSplitModel> rebalanceSplit({
    required String splitId,
    required List<Map<String, dynamic>> participants,
  }) async {
    final res = await _dio.put(
      '/splits/$splitId/rebalance',
      data: {'participants': participants},
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return ExpenseSplitModel.fromJson(data);
  }

  /// 8. Chốt phiên chia tiền (sinh Sổ nợ): POST /splits/:splitId/confirm
  Future<ExpenseSplitModel> confirmSplit(String splitId) async {
    final res = await _dio.post('/splits/$splitId/confirm');
    final data = res.data['data'] as Map<String, dynamic>;
    return ExpenseSplitModel.fromJson(data);
  }

  /// 9. Hủy phiên chia tiền: DELETE /splits/:splitId
  Future<ExpenseSplitModel> cancelSplit(String splitId) async {
    final res = await _dio.delete('/splits/$splitId');
    final data = res.data['data'] as Map<String, dynamic>;
    return ExpenseSplitModel.fromJson(data);
  }
}
