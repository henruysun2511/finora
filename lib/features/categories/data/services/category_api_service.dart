import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../dto/category_response.dart';
import '../dto/create_category_request.dart';
import '../dto/update_category_request.dart';

abstract class CategoryApiService {
  Future<List<CategoryResponse>> getCategories({String? type, String? search});
  Future<CategoryResponse> getCategoryById(String id);
  Future<CategoryResponse> createCategory(CreateCategoryRequest request);
  Future<CategoryResponse> updateCategory(String id, UpdateCategoryRequest request);
  Future<void> deleteCategory(String id);
}

class DioCategoryApiService implements CategoryApiService {
  DioCategoryApiService(this._dio);

  final Dio _dio;
  static const _basePath = '/categories';

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      String? message;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? data['error'] as String?;
      }
      throw AppException(
        message ?? e.message ?? 'Đã xảy ra lỗi khi kết nối máy chủ',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    }
    return responseData;
  }

  @override
  Future<List<CategoryResponse>> getCategories({String? type, String? search}) =>
      _guard(() async {
        final query = <String, dynamic>{};
        if (type != null && type.isNotEmpty) query['type'] = type.toUpperCase();
        if (search != null && search.trim().isNotEmpty) query['search'] = search.trim();

        final res = await _dio.get<dynamic>(_basePath, queryParameters: query);
        final raw = _extractData(res.data);

        List<dynamic> items = [];
        if (raw is List) {
          items = raw;
        } else if (raw is Map<String, dynamic>) {
          if (raw['items'] is List) {
            items = raw['items'] as List;
          } else if (raw['data'] is List) {
            items = raw['data'] as List;
          }
        }

        return items
            .map((e) => CategoryResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<CategoryResponse> getCategoryById(String id) => _guard(() async {
        final res = await _dio.get<dynamic>('$_basePath/$id');
        final raw = _extractData(res.data);
        return CategoryResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<CategoryResponse> createCategory(CreateCategoryRequest request) =>
      _guard(() async {
        final res = await _dio.post<dynamic>(_basePath, data: request.toJson());
        final raw = _extractData(res.data);
        return CategoryResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<CategoryResponse> updateCategory(
    String id,
    UpdateCategoryRequest request,
  ) =>
      _guard(() async {
        final res =
            await _dio.patch<dynamic>('$_basePath/$id', data: request.toJson());
        final raw = _extractData(res.data);
        return CategoryResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<void> deleteCategory(String id) => _guard(() async {
        await _dio.delete<dynamic>('$_basePath/$id');
      });
}

