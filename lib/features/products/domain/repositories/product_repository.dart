import '../models/paged_result.dart';
import '../models/product.dart';
import '../models/product_filter.dart';
import '../models/product_input.dart';

abstract class ProductRepository {
  Future<PagedResult<Product>> getProducts({
    required int page,
    required int limit,
    required ProductFilter filter,
  });

  Future<Product> getProduct(String id);

  Future<Product> createProduct(ProductInput input);

  Future<Product> updateProduct(String id, ProductInput input);

  Future<void> deleteProduct(String id);
}
