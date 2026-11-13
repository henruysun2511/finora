import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../../data/dto/create_transfer_request.dart';
import '../../domain/models/transfer.dart';
import 'transfer_list_provider.dart';
import 'transfer_providers.dart';

class TransferActionsNotifier {
  final Ref _ref;

  TransferActionsNotifier(this._ref);

  Future<Transfer> create(CreateTransferRequest request) async {
    final repo = _ref.read(transferRepositoryProvider);
    final transfer = await repo.create(request);

    // Invalidate caches & balances
    _ref.invalidate(transferListProvider);
    _ref.invalidate(walletsOverviewProvider);
    _ref.invalidate(dashboardOverviewProvider);
    _ref.invalidate(dashboardCashFlowProvider);

    return transfer;
  }

  Future<Transfer> getById(String id) async {
    final repo = _ref.read(transferRepositoryProvider);
    return repo.getById(id);
  }
}

final transferActionsProvider = Provider<TransferActionsNotifier>((ref) {
  return TransferActionsNotifier(ref);
});

final transferDetailProvider =
    FutureProvider.autoDispose.family<Transfer, String>((ref, id) async {
  final repo = ref.watch(transferRepositoryProvider);
  return repo.getById(id);
});
