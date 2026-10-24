import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/services/mock_product_api_service.dart';
import '../../data/services/product_api_service.dart';
import '../../domain/repositories/product_repository.dart';

const bool kUseMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

/// Dependency injection cho feature products.
/// Chuyển đổi giữa Real Backend (Dio) và Mock API qua --dart-define=USE_MOCK_API=true
final productApiServiceProvider = Provider<ProductApiService>((ref) {
  if (kUseMockApi) {
    return MockProductApiService();
  }
  return DioProductApiService(ref.watch(dioProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productApiServiceProvider));
});
