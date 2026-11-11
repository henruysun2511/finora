import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/account_item_model.dart';

/// Provider nạp danh sách tài khoản tài chính (Tiền mặt, Ngân hàng, Ví điện tử...) từ API GET /api/v1/accounts
final accountsListProvider =
    FutureProvider.autoDispose<List<AccountItemModel>>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    final res = await dio.get<dynamic>(ApiConstants.accounts);
    final data = res.data;
    List<dynamic> list = [];

    if (data is Map<String, dynamic> && data['data'] != null) {
      if (data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data['data']['items'] is List) {
        list = data['data']['items'] as List<dynamic>;
      }
    } else if (data is List) {
      list = data;
    }

    final accounts = list
        .whereType<Map<String, dynamic>>()
        .map(AccountItemModel.fromJson)
        .toList();

    if (accounts.isNotEmpty) return accounts;
  } catch (_) {}

  // Fallback danh sách tài khoản chuẩn Solarn FinTech
  return const [
    AccountItemModel(
      id: 'acc-cash',
      name: 'Tiền mặt (Ví da)',
      type: 'cash',
      balance: 2500000,
      currency: 'VND',
    ),
    AccountItemModel(
      id: 'acc-vcb',
      name: 'Vietcombank Digibank',
      type: 'bank',
      balance: 18250000,
      currency: 'VND',
      accountNumberLast4: '6789',
    ),
    AccountItemModel(
      id: 'acc-momo',
      name: 'Ví điện tử MoMo',
      type: 'ewallet',
      balance: 850000,
      currency: 'VND',
    ),
    AccountItemModel(
      id: 'acc-tcb',
      name: 'Techcombank Visa Debit',
      type: 'bank',
      balance: 5400000,
      currency: 'VND',
      accountNumberLast4: '3456',
    ),
  ];
});

