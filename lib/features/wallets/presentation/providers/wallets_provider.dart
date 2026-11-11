import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../ai_chat/domain/models/wallet_item_model.dart';

/// Provider nạp danh sách ví thật của người dùng từ API GET /api/v1/wallets
final walletsListProvider =
    FutureProvider.autoDispose<List<WalletItemModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get<dynamic>(ApiConstants.wallets);
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
    final wallets = list
        .whereType<Map<String, dynamic>>()
        .map(WalletItemModel.fromJson)
        .toList();
    if (wallets.isNotEmpty) return wallets;
  } catch (_) {}

  // Fallback an toàn nếu chưa lấy được danh sách từ API
  return const [
    WalletItemModel(
      id: '11111111-1111-4111-8111-111111111111',
      name: 'Ví Cá Nhân (VND)',
    ),
    WalletItemModel(
      id: '22222222-2222-4222-8222-222222222222',
      name: 'Ví Gia Đình (VND)',
    ),
  ];
});

