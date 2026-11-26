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

    return accounts;
  } catch (_) {
    return const [];
  }
});

