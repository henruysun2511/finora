import '../models/expense_split_model.dart';
import '../models/my_splits_summary_model.dart';
import '../models/split_participant_model.dart';

abstract class SplitRepository {
  Future<ExpenseSplitModel> createSplit({
    required String transactionId,
    required String splitType,
    required List<Map<String, dynamic>> participants,
  });

  Future<ExpenseSplitModel> getSplitByTransactionId(String transactionId);

  Future<ExpenseSplitModel> getSplitById(String splitId);

  Future<List<ExpenseSplitModel>> getMySplits({
    int page = 1,
    int limit = 20,
    String? status,
    bool? asOwner,
    bool? asParticipant,
  });

  Future<MySplitsSummaryModel> getSummary();

  Future<SplitParticipantModel> respondSplit({
    required String splitId,
    required String action,
    double? proposedAmount,
    String? note,
  });

  Future<ExpenseSplitModel> rebalanceSplit({
    required String splitId,
    required List<Map<String, dynamic>> participants,
  });

  Future<ExpenseSplitModel> confirmSplit(String splitId);

  Future<ExpenseSplitModel> cancelSplit(String splitId);
}
