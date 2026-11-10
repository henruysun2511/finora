import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/create_transaction_input.dart';
import '../../domain/models/transaction_enums.dart';
import 'transaction_form_state.dart';
import 'transaction_list_provider.dart';
import 'transaction_providers.dart';

final transactionFormProvider =
    StateNotifierProvider.autoDispose<TransactionFormNotifier, TransactionFormState>(
        (ref) {
  return TransactionFormNotifier(ref);
});

class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  TransactionFormNotifier(this._ref)
      : super(TransactionFormState(
          transactionDate: DateTime.now(),
          accountId: 'acc-cash',
          accountName: 'Tiền mặt (Ví da)',
        ));

  final Ref _ref;

  void setType(TransactionType type) {
    state = state.copyWith(type: type);
  }

  void setAmountDirectly(double amount, String amountString) {
    state = state.copyWith(amount: amount, amountString: amountString);
  }

  void onKeyPress(String key) {
    var cur = state.amountString;

    if (key == '⌫') {
      if (cur.length <= 1) {
        cur = '0';
      } else {
        cur = cur.substring(0, cur.length - 1);
      }
    } else if (key == '000') {
      if (cur != '0') {
        if (cur.length < 12) cur += '000';
      }
    } else if (key == '.') {
      if (!cur.contains('.')) {
        cur += '.';
      }
    } else {
      if (cur == '0') {
        cur = key;
      } else if (cur.length < 12) {
        cur += key;
      }
    }

    final doubleVal = double.tryParse(cur) ?? 0.0;
    state = state.copyWith(amountString: cur, amount: doubleVal);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setCategory({
    required String id,
    required String name,
    String? icon,
    String? color,
  }) {
    state = state.copyWith(
      categoryId: id,
      categoryName: name,
      categoryIcon: icon,
      categoryColor: color,
    );
  }

  void setAccount({required String id, required String name}) {
    state = state.copyWith(accountId: id, accountName: name);
  }

  void setToAccount({required String id, required String name}) {
    state = state.copyWith(toAccountId: id, toAccountName: name);
  }

  void setTransactionDate(DateTime date) {
    state = state.copyWith(transactionDate: date);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  void setLocationName(String location) {
    state = state.copyWith(locationName: location);
  }

  void setFee(double fee) {
    state = state.copyWith(fee: fee);
  }

  void setExcludeFromReport(bool val) {
    state = state.copyWith(excludeFromReport: val);
  }

  void setAmountHidden(bool val) {
    state = state.copyWith(amountHidden: val);
  }

  void setVisibility(String val) {
    state = state.copyWith(visibility: val);
  }

  void setPhoto(String? path) {
    if (path == null) {
      state = state.copyWith(clearPhoto: true);
    } else {
      state = state.copyWith(photoUrl: path);
    }
  }

  Future<bool> submit() async {
    if (state.amount <= 0) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập số tiền lớn hơn 0');
      return false;
    }

    if (state.accountId == null || state.accountId!.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn tài khoản nguồn');
      return false;
    }

    if (state.type == TransactionType.transfer) {
      if (state.toAccountId == null || state.toAccountId!.isEmpty) {
        state = state.copyWith(errorMessage: 'Vui lòng chọn tài khoản đích');
        return false;
      }
      if (state.accountId == state.toAccountId) {
        state = state.copyWith(
            errorMessage: 'Tài khoản nhận không được trùng tài khoản chuyển');
        return false;
      }
    } else {
      if (state.categoryId == null || state.categoryId!.isEmpty) {
        state = state.copyWith(errorMessage: 'Vui lòng chọn danh mục thu/chi');
        return false;
      }
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = _ref.read(transactionRepositoryProvider);
      final txName = state.name?.trim().isNotEmpty == true
          ? state.name!.trim()
          : (state.note?.trim().isNotEmpty == true
              ? state.note!.trim()
              : state.categoryName);

      final input = CreateTransactionInput(
        accountId: state.accountId!,
        toAccountId: state.toAccountId,
        categoryId: state.categoryId,
        type: state.type,
        amount: state.amount,
        fee: state.fee,
        name: txName,
        note: state.note,
        locationName: state.locationName,
        excludeFromReport: state.excludeFromReport,
        amountHidden: state.amountHidden,
        visibility: state.visibility,
        transactionDate: state.transactionDate ?? DateTime.now(),
        photoUrl: state.photoUrl,
      );

      if (state.type == TransactionType.transfer) {
        await repo.createTransfer(input);
      } else {
        await repo.createTransaction(input);
      }

      // Làm mới danh sách giao dịch
      _ref.read(dailyGridProvider.notifier).refresh();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}
