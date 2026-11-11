import '../../domain/models/account_model.dart';
import '../../domain/models/balance_adjustment_model.dart';
import '../../domain/repositories/account_repository.dart';
import '../dto/adjust_balance_request.dart';
import '../dto/create_account_request.dart';
import '../dto/update_account_request.dart';
import '../mappers/account_mapper.dart';
import '../mappers/balance_adjustment_mapper.dart';
import '../services/account_api_service.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountApiService _apiService;

  AccountRepositoryImpl(this._apiService);

  @override
  Future<List<AccountModel>> getAccounts({
    String? walletId,
    int page = 1,
    int limit = 50,
  }) async {
    final list = await _apiService.getAccounts(
      walletId: walletId,
      page: page,
      limit: limit,
    );
    return list.map(AccountMapper.fromJson).toList();
  }

  @override
  Future<AccountModel> getAccountById(String id) async {
    final data = await _apiService.getAccountById(id);
    return AccountMapper.fromJson(data);
  }

  @override
  Future<double> getAccountBalance(String id) async {
    final data = await _apiService.getAccountBalance(id);
    return (data['balance'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<AccountModel> createAccount(
    CreateAccountRequest request, {
    String? idempotencyKey,
  }) async {
    final data = await _apiService.createAccount(
      request,
      idempotencyKey: idempotencyKey,
    );
    return AccountMapper.fromJson(data);
  }

  @override
  Future<AccountModel> updateAccount(
    String id,
    UpdateAccountRequest request,
  ) async {
    final data = await _apiService.updateAccount(id, request);
    return AccountMapper.fromJson(data);
  }

  @override
  Future<AccountModel> archiveAccount(String id) async {
    final data = await _apiService.archiveAccount(id);
    return AccountMapper.fromJson(data);
  }

  @override
  Future<AccountModel> unarchiveAccount(String id) async {
    final data = await _apiService.unarchiveAccount(id);
    return AccountMapper.fromJson(data);
  }

  @override
  Future<void> deleteAccount(String id) => _apiService.deleteAccount(id);

  @override
  Future<BalanceAdjustmentModel> adjustBalance(
    String id,
    AdjustBalanceRequest request, {
    required String idempotencyKey,
  }) async {
    final data = await _apiService.adjustBalance(
      id,
      request,
      idempotencyKey: idempotencyKey,
    );
    return BalanceAdjustmentMapper.fromJson(data);
  }
}

