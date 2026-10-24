import '../../domain/models/paged_result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_category.dart';
import '../../domain/models/product_filter.dart';
import '../../domain/models/product_input.dart';
import '../dto/create_product_request.dart';
import '../dto/product_list_query.dart';
import '../dto/product_page_response.dart';
import '../dto/product_response.dart';
import '../dto/update_product_request.dart';

extension ProductResponseMapper on ProductResponse {
  Product toModel() => Product(
        id: id,
        name: name,
        sku: sku,
        description: description,
        price: price,
        stock: stock,
        category: ProductCategory.fromValue(category),
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension ProductPageResponseMapper on ProductPageResponse {
  PagedResult<Product> toModel() => PagedResult<Product>(
        items: data.map((e) => e.toModel()).toList(),
        page: page,
        limit: limit,
        total: total,
        totalPages: totalPages,
      );
}

extension ProductInputMapper on ProductInput {
  CreateProductRequest toCreateRequest() => CreateProductRequest(
        name: name,
        sku: sku,
        description: description,
        price: price,
        stock: stock,
        category: category.value,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );

  UpdateProductRequest toUpdateRequest() => UpdateProductRequest(
        name: name,
        sku: sku,
        description: description,
        price: price,
        stock: stock,
        category: category.value,
        imageUrl: imageUrl ?? '',
        isAvailable: isAvailable,
      );
}

extension ProductFilterMapper on ProductFilter {
  ProductListQuery toQuery({required int page, required int limit}) =>
      ProductListQuery(
        page: page,
        limit: limit,
        search: search,
        category: category?.value,
        minPrice: minPrice,
        maxPrice: maxPrice,
        isAvailable: inStock,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
      );
}
