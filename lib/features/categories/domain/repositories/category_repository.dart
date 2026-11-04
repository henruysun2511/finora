import '../models/category.dart';
import '../models/category_input.dart';
import '../models/category_type.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories({CategoryType? type, String? search});
  Future<Category> getCategoryById(String id);
  Future<Category> createCategory(CategoryInput input);
  Future<Category> updateCategory(String id, CategoryInput input);
  Future<void> deleteCategory(String id);
}

