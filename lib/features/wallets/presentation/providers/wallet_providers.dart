import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../data/services/wallet_api_service.dart';
import '../../domain/repositories/wallet_repository.dart';

enum WalletFilterTab { all, personal, shared }

final walletApiServiceProvider = Provider<WalletApiService>((ref) {
  return DioWalletApiService(ref.watch(dioProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.watch(walletApiServiceProvider));
});

/// Trạng thái ẩn/hiện số dư nhạy cảm trên toàn bộ phân hệ Ví (•••••••• VND)
final isBalanceHiddenProvider = StateProvider<bool>((ref) => false);

/// Bộ lọc tab trên màn hình Tổng quan Ví
final walletFilterProvider = StateProvider<WalletFilterTab>((ref) {
  return WalletFilterTab.all;
});

