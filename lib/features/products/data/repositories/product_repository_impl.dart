import '../../domain/models/paged_result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_filter.dart';
import '../../domain/models/product_input.dart';
import '../../domain/repositories/product_repository.dart';
import '../mappers/product_mapper.dart';
import '../services/product_api_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._service);

  final ProductApiService _service;

  @override
  Future<PagedResult<Product>> getProducts({
    required int page,
    required int limit,
    required ProductFilter filter,
  }) async {
    final response = await _service.getProducts(
      filter.toQuery(page: page, limit: limit),
    );
    return response.toModel();
  }

  @override
  Future<Product> getProduct(String id) async =>
      (await _service.getProduct(id)).toModel();

  @override
  Future<Product> createProduct(ProductInput input) async =>
      (await _service.createProduct(input.toCreateRequest())).toModel();

  @override
  Future<Product> updateProduct(String id, ProductInput input) async =>
      (await _service.updateProduct(id, input.toUpdateRequest())).toModel();

  @override
  Future<void> deleteProduct(String id) => _service.deleteProduct(id);
}
