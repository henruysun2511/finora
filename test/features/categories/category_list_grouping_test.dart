import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/categories/domain/models/category.dart';
import 'package:finora_mb/features/categories/domain/models/category_type.dart';

void main() {
  group('Category Grouping Logic Tests', () {
    test('Phân tách chính xác danh mục người dùng tạo ở trên và hệ thống ở dưới', () {
      final allCategories = [
        const Category(
          id: 'sys-1',
          name: 'Ăn uống',
          type: CategoryType.expense,
          isDefault: true,
        ),
        const Category(
          id: 'user-1',
          name: 'Nuôi mèo',
          type: CategoryType.expense,
          isDefault: false,
        ),
        const Category(
          id: 'sys-2',
          name: 'Mua sắm',
          type: CategoryType.expense,
          isDefault: true,
        ),
        const Category(
          id: 'user-2',
          name: 'Khóa học Flutter',
          type: CategoryType.expense,
          isDefault: false,
        ),
      ];

      final userCategories = allCategories.where((c) => !c.isDefault).toList();
      final systemCategories = allCategories.where((c) => c.isDefault).toList();

      expect(userCategories.length, 2);
      expect(userCategories[0].name, 'Nuôi mèo');
      expect(userCategories[1].name, 'Khóa học Flutter');

      expect(systemCategories.length, 2);
      expect(systemCategories[0].name, 'Ăn uống');
      expect(systemCategories[1].name, 'Mua sắm');
    });
  });
}

