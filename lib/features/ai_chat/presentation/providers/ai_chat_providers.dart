import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/ai_chat_repository_impl.dart';
import '../../data/services/ai_chat_api_service.dart';
import '../../domain/models/wallet_item_model.dart';
import '../../domain/repositories/ai_chat_repository.dart';

final aiChatApiServiceProvider = Provider<AiChatApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return DioAiChatApiService(dio);
});

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  final api = ref.watch(aiChatApiServiceProvider);
  return AiChatRepositoryImpl(apiService: api);
});

/// Lấy danh sách ví của người dùng hiện tại
final userWalletsProvider = FutureProvider<List<WalletItemModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get(ApiConstants.wallets);
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
    return list
        .whereType<Map<String, dynamic>>()
        .map(WalletItemModel.fromJson)
        .toList();
  } catch (_) {
    return [
      const WalletItemModel(
        id: 'a1111111-1111-4111-a111-111111111111',
        name: 'Ví Chi Tiêu Cá Nhân',
      )
    ];
  }
});

/// Lấy thông tin linh vật hiện tại của người dùng dựa theo tài sản ròng
final currentUserMascotProvider = FutureProvider<String?>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get(ApiConstants.currentMascot);
    final data = res.data;
    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      final mascotData = data['data']['mascot'];
      if (mascotData is Map<String, dynamic> && mascotData['tierName'] != null) {
        return mascotData['tierName'].toString().toLowerCase().trim();
      }
    }
    return null;
  } catch (_) {
    return null;
  }
});
