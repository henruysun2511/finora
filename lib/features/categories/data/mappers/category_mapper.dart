import '../../domain/models/category.dart';
import '../../domain/models/category_input.dart';
import '../../domain/models/category_type.dart';
import '../dto/category_response.dart';
import '../dto/create_category_request.dart';
import '../dto/update_category_request.dart';

class CategoryMapper {
  CategoryMapper._();

  static Category toDomain(CategoryResponse dto) {
    return Category(
      id: dto.id,
      name: dto.name,
      type: CategoryType.fromValue(dto.type),
      icon: dto.icon.isNotEmpty ? dto.icon : '🏷️',
      color: dto.color.isNotEmpty ? dto.color : '#1E5BD8',
      isDefault: dto.isDefault,
      parentId: dto.parentId,
      children: dto.children.map(toDomain).toList(),
      transactionCount: dto.transactionCount,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static CreateCategoryRequest toCreateRequest(CategoryInput input) {
    return CreateCategoryRequest(
      name: input.name,
      type: input.type.value,
      icon: input.icon,
      color: input.color,
      parentId: input.parentId,
    );
  }

  static UpdateCategoryRequest toUpdateRequest(CategoryInput input) {
    return UpdateCategoryRequest(
      name: input.name,
      type: input.type.value,
      icon: input.icon,
      color: input.color,
      parentId: input.parentId,
    );
  }
}

