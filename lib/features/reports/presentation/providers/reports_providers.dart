import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../data/services/reports_api_service.dart';
import '../../domain/repositories/reports_repository.dart';

final reportsApiServiceProvider = Provider<ReportsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportsApiService(dio);
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final api = ref.watch(reportsApiServiceProvider);
  return ReportsRepositoryImpl(api);
});
