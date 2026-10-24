import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/product.dart';
import 'product_providers.dart';

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) {
  return ref.watch(productRepositoryProvider).getProduct(id);
});
