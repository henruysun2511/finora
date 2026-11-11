import '../../data/dto/adjust_balance_request.dart';
import '../../data/dto/create_account_request.dart';
import '../../data/dto/update_account_request.dart';
import '../models/account_model.dart';
import '../models/balance_adjustment_model.dart';

abstract class AccountRepository {
  Future<List<AccountModel>> getAccounts({
    String? walletId,
    int page = 1,
    int limit = 50,
  });
  Future<AccountModel> getAccountById(String id);
  Future<double> getAccountBalance(String id);
  Future<AccountModel> createAccount(
    CreateAccountRequest request, {
    String? idempotencyKey,
  });
  Future<AccountModel> updateAccount(String id, UpdateAccountRequest request);
  Future<AccountModel> archiveAccount(String id);
  Future<AccountModel> unarchiveAccount(String id);
  Future<void> deleteAccount(String id);
  Future<BalanceAdjustmentModel> adjustBalance(
    String id,
    AdjustBalanceRequest request, {
    required String idempotencyKey,
  });
}

