import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../data/services/transfer_api_service.dart';
import '../../domain/repositories/transfer_repository.dart';

final transferApiServiceProvider = Provider<TransferApiService>((ref) {
  return DioTransferApiService(ref.watch(dioProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepositoryImpl(ref.watch(transferApiServiceProvider));
});
