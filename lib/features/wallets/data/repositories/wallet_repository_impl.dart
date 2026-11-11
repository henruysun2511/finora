import '../../../accounts/data/mappers/account_mapper.dart';
import '../../../accounts/domain/models/account_model.dart';
import '../../domain/models/wallet_balance_model.dart';
import '../../domain/models/wallet_member_model.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../dto/create_wallet_request.dart';
import '../dto/invite_member_request.dart';
import '../dto/update_member_role_request.dart';
import '../dto/update_wallet_request.dart';
import '../mappers/wallet_mapper.dart';
import '../mappers/wallet_member_mapper.dart';
import '../services/wallet_api_service.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletApiService _apiService;

  WalletRepositoryImpl(this._apiService);

  @override
  Future<List<WalletModel>> getWallets() async {
    final list = await _apiService.getWallets();
    return list.map(WalletMapper.fromJson).toList();
  }

  @override
  Future<WalletModel> getWalletById(String id) async {
    final data = await _apiService.getWalletById(id);
    return WalletMapper.fromJson(data);
  }

  @override
  Future<WalletBalanceModel> getWalletBalance(String id) async {
    final data = await _apiService.getWalletBalance(id);
    return WalletMapper.balanceFromJson(data);
  }

  @override
  Future<List<AccountModel>> getWalletAccounts(String id) async {
    final list = await _apiService.getWalletAccounts(id);
    return list.map(AccountMapper.fromJson).toList();
  }

  @override
  Future<WalletModel> createWallet(CreateWalletRequest request) async {
    final data = await _apiService.createWallet(request);
    return WalletMapper.fromJson(data);
  }

  @override
  Future<WalletModel> updateWallet(
    String id,
    UpdateWalletRequest request,
  ) async {
    final data = await _apiService.updateWallet(id, request);
    return WalletMapper.fromJson(data);
  }

  @override
  Future<void> deleteWallet(String id) => _apiService.deleteWallet(id);

  @override
  Future<List<WalletMemberModel>> getMembers(String walletId) async {
    final list = await _apiService.getMembers(walletId);
    return list.map(WalletMemberMapper.fromJson).toList();
  }

  @override
  Future<void> inviteMember(
    String walletId,
    InviteMemberRequest request,
  ) async {
    await _apiService.inviteMember(walletId, request);
  }

  @override
  Future<void> updateMemberRole(
    String walletId,
    String userId,
    UpdateMemberRoleRequest request,
  ) async {
    await _apiService.updateMemberRole(walletId, userId, request);
  }

  @override
  Future<void> kickMember(String walletId, String userId) =>
      _apiService.kickMember(walletId, userId);
}

