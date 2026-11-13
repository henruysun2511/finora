import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
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

  Future<void> inviteMember({
    String? email,
    String? userId,
    WalletMemberRole role = WalletMemberRole.editor,
  }) async {
    final repo = _ref.read(walletRepositoryProvider);
    await repo.inviteMember(
      _walletId,
      InviteMemberRequest(email: email, userId: userId, role: role),
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

class WalletTransactionItem {
  final String id;
  final String title;
  final double amount;
  final String type; // INCOME / EXPENSE
  final DateTime transactionDate;
  final String? createdBy;

  const WalletTransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.transactionDate,
    this.createdBy,
  });
}

final walletTransactionsProvider =
    FutureProvider.family<List<WalletTransactionItem>, String>((ref, walletId) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get(
      '/transactions',
      queryParameters: {'walletId': walletId, 'limit': 30},
    );
    final data = res.data;
    dynamic items;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic> && inner['items'] is List) {
        items = inner['items'];
      } else if (inner is List) {
        items = inner;
      } else if (data['items'] is List) {
        items = data['items'];
      }
    } else if (data is List) {
      items = data;
    }
    if (items is List) {
      return items.map((raw) {
        final m = raw as Map<String, dynamic>;
        final typeStr = (m['type'] as String?)?.toUpperCase() ?? 'EXPENSE';
        final title = (m['name'] as String?)?.trim().isNotEmpty == true
            ? m['name'] as String
            : (m['note'] as String?)?.trim().isNotEmpty == true
                ? m['note'] as String
                : (m['category']?['name'] as String? ?? 'Giao dịch');

        return WalletTransactionItem(
          id: m['id'] as String? ?? '',
          title: title,
          amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
          type: typeStr,
          transactionDate: m['transactionDate'] != null
              ? DateTime.tryParse(m['transactionDate'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
          createdBy: m['createdBy'] as String?,
        );
      }).toList();
    }
    return [];
  } catch (_) {
    return [];
  }
});
