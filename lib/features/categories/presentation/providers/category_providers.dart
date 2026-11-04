import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/services/category_api_service.dart';
import '../../domain/repositories/category_repository.dart';

final categoryApiServiceProvider = Provider<CategoryApiService>((ref) {
  return DioCategoryApiService(ref.watch(dioProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryApiServiceProvider));
});

