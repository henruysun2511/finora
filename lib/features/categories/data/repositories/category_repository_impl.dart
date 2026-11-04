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
      if (res.isNotEmpty) {
        return res.map(CategoryMapper.toDomain).toList();
      }
    } catch (_) {}

    // Fallback danh mục mặc định chuẩn phong cách Solarn FinTech
    final defaultList = _getDefaultCategories();
    if (type != null) {
      return defaultList.where((c) => c.type == type).toList();
    }
    return defaultList;
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

  List<Category> _getDefaultCategories() {
    return const [
      Category(
        id: 'default-1',
        name: 'Ăn uống',
        type: CategoryType.expense,
        icon: 'utensils',
        color: '#F97316',
        isDefault: true,
        transactionCount: 14,
      ),
      Category(
        id: 'default-2',
        name: 'Mua sắm',
        type: CategoryType.expense,
        icon: 'shopping-bag',
        color: '#EC4899',
        isDefault: true,
        transactionCount: 8,
      ),
      Category(
        id: 'default-3',
        name: 'Di chuyển',
        type: CategoryType.expense,
        icon: 'car',
        color: '#8B5CF6',
        isDefault: true,
        transactionCount: 12,
      ),
      Category(
        id: 'default-4',
        name: 'Hóa đơn & Tiện ích',
        type: CategoryType.expense,
        icon: 'zap',
        color: '#10B981',
        isDefault: true,
        transactionCount: 5,
      ),
      Category(
        id: 'default-5',
        name: 'Giải trí',
        type: CategoryType.expense,
        icon: 'gamepad-2',
        color: '#3B82F6',
        isDefault: true,
        transactionCount: 6,
      ),
      Category(
        id: 'default-6',
        name: 'Lương & Thưởng',
        type: CategoryType.income,
        icon: 'banknote',
        color: '#10B981',
        isDefault: true,
        transactionCount: 2,
      ),
      Category(
        id: 'default-7',
        name: 'Đầu tư & Cổ tức',
        type: CategoryType.income,
        icon: 'trending-up',
        color: '#6366F1',
        isDefault: true,
        transactionCount: 4,
      ),
    ];
  }
}

