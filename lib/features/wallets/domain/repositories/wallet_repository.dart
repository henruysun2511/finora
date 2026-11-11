import '../../../accounts/domain/models/account_model.dart';
import '../../data/dto/create_wallet_request.dart';
import '../../data/dto/invite_member_request.dart';
import '../../data/dto/update_member_role_request.dart';
import '../../data/dto/update_wallet_request.dart';
import '../models/wallet_balance_model.dart';
import '../models/wallet_member_model.dart';
import '../models/wallet_model.dart';

abstract class WalletRepository {
  Future<List<WalletModel>> getWallets();
  Future<WalletModel> getWalletById(String id);
  Future<WalletBalanceModel> getWalletBalance(String id);
  Future<List<AccountModel>> getWalletAccounts(String id);
  Future<WalletModel> createWallet(CreateWalletRequest request);
  Future<WalletModel> updateWallet(String id, UpdateWalletRequest request);
  Future<void> deleteWallet(String id);
  Future<List<WalletMemberModel>> getMembers(String walletId);
  Future<void> inviteMember(String walletId, InviteMemberRequest request);
  Future<void> updateMemberRole(
    String walletId,
    String userId,
    UpdateMemberRoleRequest request,
  );
  Future<void> kickMember(String walletId, String userId);
}

