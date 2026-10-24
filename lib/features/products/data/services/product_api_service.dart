import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../dto/create_product_request.dart';
import '../dto/product_list_query.dart';
import '../dto/product_page_response.dart';
import '../dto/product_response.dart';
import '../dto/update_product_request.dart';

abstract class ProductApiService {
  Future<ProductPageResponse> getProducts(ProductListQuery query);
  Future<ProductResponse> getProduct(String id);
  Future<ProductResponse> createProduct(CreateProductRequest request);
  Future<ProductResponse> updateProduct(String id, UpdateProductRequest request);
  Future<void> deleteProduct(String id);
}

class DioProductApiService implements ProductApiService {
  DioProductApiService(this._dio);

  final Dio _dio;
  static const _path = '/products';

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return <String, dynamic>{};
  }

  @override
  Future<ProductPageResponse> getProducts(ProductListQuery query) =>
      _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          _path,
          queryParameters: query.toQueryParameters(),
        );
        return ProductPageResponse.fromJson(res.data ?? <String, dynamic>{});
      });

  @override
  Future<ProductResponse> getProduct(String id) => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('$_path/$id');
        return ProductResponse.fromJson(_extractData(res.data));
      });

  @override
  Future<ProductResponse> createProduct(CreateProductRequest request) =>
      _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          _path,
          data: request.toJson(),
        );
        return ProductResponse.fromJson(_extractData(res.data));
      });

  @override
  Future<ProductResponse> updateProduct(
    String id,
    UpdateProductRequest request,
  ) =>
      _guard(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          '$_path/$id',
          data: request.toJson(),
        );
        return ProductResponse.fromJson(_extractData(res.data));
      });

  @override
  Future<void> deleteProduct(String id) => _guard<void>(() async {
        await _dio.delete<void>('$_path/$id');
      });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    }
  }
}
