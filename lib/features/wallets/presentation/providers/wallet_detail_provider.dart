import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/domain/models/account_model.dart';
import '../../data/dto/invite_member_request.dart';
import '../../data/dto/update_member_role_request.dart';
import '../../data/dto/update_wallet_request.dart';
import '../../domain/enums/wallet_member_role.dart';
import '../../domain/models/wallet_balance_model.dart';
import '../../domain/models/wallet_member_model.dart';
import '../../domain/models/wallet_model.dart';
import 'wallet_providers.dart';
import 'wallets_overview_provider.dart';

class WalletDetailState {
  final WalletModel wallet;
  final WalletBalanceModel balance;
  final List<AccountModel> activeAccounts;
  final List<AccountModel> archivedAccounts;
  final List<WalletMemberModel> members;

  const WalletDetailState({
    required this.wallet,
    required this.balance,
    required this.activeAccounts,
    required this.archivedAccounts,
    required this.members,
  });

  bool get isOwner => wallet.isOwner;
  bool get canEdit => wallet.canEdit;
  bool get isShared => wallet.isShared;
}

final walletDetailProvider =
    FutureProvider.family<WalletDetailState, String>((ref, walletId) async {
  final repo = ref.watch(walletRepositoryProvider);

  final walletFuture = repo.getWalletById(walletId);
  final balanceFuture = repo.getWalletBalance(walletId).catchError(
    (_) => WalletBalanceModel.empty(walletId),
  );
  final accountsFuture = repo.getWalletAccounts(walletId).catchError(
    (_) => <AccountModel>[],
  );
  final membersFuture = repo.getMembers(walletId).catchError(
    (_) => <WalletMemberModel>[],
  );

  final results = await Future.wait([
    walletFuture,
    balanceFuture,
    accountsFuture,
    membersFuture,
  ]);

  final wallet = results[0] as WalletModel;
  final balance = results[1] as WalletBalanceModel;
  final accounts = results[2] as List<AccountModel>;
  final members = results[3] as List<WalletMemberModel>;

  final activeAccounts = accounts.where((a) => !a.isArchived).toList();
  final archivedAccounts = accounts.where((a) => a.isArchived).toList();

  return WalletDetailState(
    wallet: wallet,
    balance: balance,
    activeAccounts: activeAccounts,
    archivedAccounts: archivedAccounts,
    members: members,
  );
});

class WalletDetailActions {
  final Ref _ref;
  final String _walletId;

  WalletDetailActions(this._ref, this._walletId);

  Future<void> inviteMember(String email, WalletMemberRole role) async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.inviteMember(
      _walletId,
      InviteMemberRequest(email: email, role: role),
    );
    _ref.invalidate(walletDetailProvider(_walletId));
  }

  Future<void> updateMemberRole(String userId, WalletMemberRole role) async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.updateMemberRole(
      _walletId,
      userId,
      UpdateMemberRoleRequest(role: role),
    );
    _ref.invalidate(walletDetailProvider(_walletId));
  }

  Future<void> kickMember(String userId) async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.kickMember(_walletId, userId);
    _ref.invalidate(walletDetailProvider(_walletId));
  }

  Future<void> updateWallet(UpdateWalletRequest request) async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.updateWallet(_walletId, request);
    _ref.invalidate(walletDetailProvider(_walletId));
    _ref.invalidate(walletsOverviewProvider);
  }

  Future<void> deleteWallet() async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.deleteWallet(_walletId);
    _ref.invalidate(walletsOverviewProvider);
  }

  Future<void> transferOwnership(String newOwnerId) async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.transferOwnership(_walletId, newOwnerId);
    _ref.invalidate(walletDetailProvider(_walletId));
    _ref.invalidate(walletsOverviewProvider);
  }

  Future<void> leaveWallet() async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.leaveWallet(_walletId);
    _ref.invalidate(walletsOverviewProvider);
  }

  Future<void> acceptInvite() async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.acceptInvite(_walletId);
    _ref.invalidate(walletDetailProvider(_walletId));
    _ref.invalidate(walletsOverviewProvider);
  }

  Future<void> rejectInvite() async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.rejectInvite(_walletId);
    _ref.invalidate(walletsOverviewProvider);
  }
}

final walletDetailActionsProvider =
    Provider.family<WalletDetailActions, String>((ref, walletId) {
  return WalletDetailActions(ref, walletId);
});
