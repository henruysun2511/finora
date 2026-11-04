import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/mascot_repository_impl.dart';
import '../../data/services/mascot_api_service.dart';
import '../../domain/repositories/mascot_repository.dart';

final mascotApiServiceProvider = Provider<MascotApiService>((ref) {
  return DioMascotApiService(ref.watch(dioProvider));
});

final mascotRepositoryProvider = Provider<MascotRepository>((ref) {
  return MascotRepositoryImpl(ref.watch(mascotApiServiceProvider));
});

