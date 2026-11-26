import '../../domain/models/category.dart';
import '../../domain/models/category_input.dart';
import '../../domain/models/category_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../mappers/category_mapper.dart';
import '../services/category_api_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._service);

  final CategoryApiService _service;

  @override
  Future<List<Category>> getCategories({CategoryType? type, String? search}) async {
    try {
      final res = await _service.getCategories(
        type: type?.value,
        search: search,
      );
      final categories = res.map(CategoryMapper.toDomain).toList();
      if (type != null) {
        return categories.where((c) => c.type == type).toList();
      }
      return categories;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Category> getCategoryById(String id) async {
    final res = await _service.getCategoryById(id);
    return CategoryMapper.toDomain(res);
  }

  @override
  Future<Category> createCategory(CategoryInput input) async {
    final req = CategoryMapper.toCreateRequest(input);
    final res = await _service.createCategory(req);
    return CategoryMapper.toDomain(res);
  }

  @override
  Future<Category> updateCategory(String id, CategoryInput input) async {
    final req = CategoryMapper.toUpdateRequest(input);
    final res = await _service.updateCategory(id, req);
    return CategoryMapper.toDomain(res);
  }

  @override
  Future<void> deleteCategory(String id) => _service.deleteCategory(id);
}
