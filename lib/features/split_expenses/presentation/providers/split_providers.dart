import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/split_repository_impl.dart';
import '../../data/services/split_api_service.dart';
import '../../domain/models/expense_split_model.dart';
import '../../domain/models/my_splits_summary_model.dart';
import '../../domain/models/split_participant_model.dart';
import '../../domain/repositories/split_repository.dart';

/// 1. Split API Service Provider
final splitApiServiceProvider = Provider<SplitApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return SplitApiService(dio);
});

/// 2. Split Repository Provider
final splitRepositoryProvider = Provider<SplitRepository>((ref) {
  final api = ref.watch(splitApiServiceProvider);
  return SplitRepositoryImpl(api);
});

/// 3. Current User ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.value?.id;
});

/// 4. Split Summary Provider
final splitSummaryProvider = FutureProvider<MySplitsSummaryModel>((ref) async {
  final repo = ref.watch(splitRepositoryProvider);
  return repo.getSummary();
});

/// 5. Bộ lọc danh sách phiên chia tiền
enum SplitFilterTab {
  all('Tất cả'),
  asOwner('Tôi đã chi'),
  asParticipant('Tôi được chia');

  const SplitFilterTab(this.label);
  final String label;
}

final splitFilterTabProvider = StateProvider<SplitFilterTab>((ref) {
  return SplitFilterTab.all;
});

/// 6. Danh sách các phiên chia tiền
class MySplitsNotifier extends AsyncNotifier<List<ExpenseSplitModel>> {
  @override
  Future<List<ExpenseSplitModel>> build() async {
    final repo = ref.watch(splitRepositoryProvider);
    final tab = ref.watch(splitFilterTabProvider);

    bool? asOwner;
    bool? asParticipant;

    if (tab == SplitFilterTab.asOwner) {
      asOwner = true;
    } else if (tab == SplitFilterTab.asParticipant) {
      asParticipant = true;
    }

    return repo.getMySplits(
      page: 1,
      limit: 50,
      asOwner: asOwner,
      asParticipant: asParticipant,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final mySplitsProvider =
    AsyncNotifierProvider<MySplitsNotifier, List<ExpenseSplitModel>>(
  MySplitsNotifier.new,
);

/// 7. Chi tiết 1 phiên chia tiền theo ID
final splitDetailProvider =
    FutureProvider.family<ExpenseSplitModel, String>((ref, splitId) async {
  final repo = ref.watch(splitRepositoryProvider);
  return repo.getSplitById(splitId);
});

/// 8. Controller thực hiện các hành động trên phiên chia tiền
class SplitActionsController extends StateNotifier<AsyncValue<void>> {
  SplitActionsController(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;

  SplitRepository get _repo => _ref.read(splitRepositoryProvider);

  /// Phản hồi yêu cầu chia tiền (accept, reject, propose)
  Future<SplitParticipantModel?> respondSplit({
    required String splitId,
    required String action,
    double? proposedAmount,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.respondSplit(
        splitId: splitId,
        action: action,
        proposedAmount: proposedAmount,
        note: note,
      );
      // Invalidate chi tiết & danh sách
      _ref.invalidate(splitDetailProvider(splitId));
      _ref.invalidate(mySplitsProvider);
      _ref.invalidate(splitSummaryProvider);
      state = const AsyncValue.data(null);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Chốt phiên chia tiền (Chủ chi)
  Future<ExpenseSplitModel?> confirmSplit(String splitId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.confirmSplit(splitId);
      _ref.invalidate(splitDetailProvider(splitId));
      _ref.invalidate(mySplitsProvider);
      _ref.invalidate(splitSummaryProvider);
      state = const AsyncValue.data(null);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Hủy phiên chia tiền (Chủ chi)
  Future<ExpenseSplitModel?> cancelSplit(String splitId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.cancelSplit(splitId);
      _ref.invalidate(splitDetailProvider(splitId));
      _ref.invalidate(mySplitsProvider);
      _ref.invalidate(splitSummaryProvider);
      state = const AsyncValue.data(null);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Điều chỉnh lại phân bổ (Rebalance)
  Future<ExpenseSplitModel?> rebalanceSplit({
    required String splitId,
    required List<Map<String, dynamic>> participants,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.rebalanceSplit(
        splitId: splitId,
        participants: participants,
      );
      _ref.invalidate(splitDetailProvider(splitId));
      _ref.invalidate(mySplitsProvider);
      state = const AsyncValue.data(null);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final splitActionsProvider =
    StateNotifierProvider<SplitActionsController, AsyncValue<void>>(
  SplitActionsController.new,
);
