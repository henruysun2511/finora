import '../../domain/models/expense_split_model.dart';
import '../../domain/models/my_splits_summary_model.dart';
import '../../domain/models/split_participant_model.dart';
import '../../domain/repositories/split_repository.dart';
import '../services/split_api_service.dart';

class SplitRepositoryImpl implements SplitRepository {
  const SplitRepositoryImpl(this._apiService);
  final SplitApiService _apiService;

  @override
  Future<ExpenseSplitModel> createSplit({
    required String transactionId,
    required String splitType,
    required List<Map<String, dynamic>> participants,
  }) {
    return _apiService.createSplit(
      transactionId: transactionId,
      splitType: splitType,
      participants: participants,
    );
  }

  @override
  Future<ExpenseSplitModel> getSplitByTransactionId(String transactionId) {
    return _apiService.getSplitByTransactionId(transactionId);
  }

  @override
  Future<ExpenseSplitModel> getSplitById(String splitId) {
    return _apiService.getSplitById(splitId);
  }

  @override
  Future<List<ExpenseSplitModel>> getMySplits({
    int page = 1,
    int limit = 20,
    String? status,
    bool? asOwner,
    bool? asParticipant,
  }) {
    return _apiService.getMySplits(
      page: page,
      limit: limit,
      status: status,
      asOwner: asOwner,
      asParticipant: asParticipant,
    );
  }

  @override
  Future<MySplitsSummaryModel> getSummary() {
    return _apiService.getSummary();
  }

  @override
  Future<SplitParticipantModel> respondSplit({
    required String splitId,
    required String action,
    double? proposedAmount,
    String? note,
  }) {
    return _apiService.respondSplit(
      splitId: splitId,
      action: action,
      proposedAmount: proposedAmount,
      note: note,
    );
  }

  @override
  Future<ExpenseSplitModel> rebalanceSplit({
    required String splitId,
    required List<Map<String, dynamic>> participants,
  }) {
    return _apiService.rebalanceSplit(
      splitId: splitId,
      participants: participants,
    );
  }

  @override
  Future<ExpenseSplitModel> confirmSplit(String splitId) {
    return _apiService.confirmSplit(splitId);
  }

  @override
  Future<ExpenseSplitModel> cancelSplit(String splitId) {
    return _apiService.cancelSplit(splitId);
  }
}
