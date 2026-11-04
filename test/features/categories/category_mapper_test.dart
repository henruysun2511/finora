import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/categories/data/dto/category_response.dart';
import 'package:finora_mb/features/categories/data/mappers/category_mapper.dart';
import 'package:finora_mb/features/categories/domain/models/category_input.dart';
import 'package:finora_mb/features/categories/domain/models/category_type.dart';

void main() {
  group('CategoryMapper', () {
    test('toDomain chuyển đổi đúng từ CategoryResponse sang Category domain entity', () {
      const dto = CategoryResponse(
        id: 'cat-uuid-1',
        name: 'Ăn uống',
        type: 'EXPENSE',
        icon: '🍽️',
        color: '#F97316',
        isDefault: true,
        transactionCount: 15,
      );

      final domain = CategoryMapper.toDomain(dto);

      expect(domain.id, 'cat-uuid-1');
      expect(domain.name, 'Ăn uống');
      expect(domain.type, CategoryType.expense);
      expect(domain.icon, '🍽️');
      expect(domain.color, '#F97316');
      expect(domain.isDefault, isTrue);
      expect(domain.transactionCount, 15);
    });

    test('toCreateRequest và toUpdateRequest chuyển đổi đúng từ CategoryInput sang DTO', () {
      const input = CategoryInput(
        name: 'Cà phê & Trà',
        type: CategoryType.expense,
        icon: '☕',
        color: '#8B5CF6',
      );

      final createReq = CategoryMapper.toCreateRequest(input);
      expect(createReq.name, 'Cà phê & Trà');
      expect(createReq.type, 'EXPENSE');
      expect(createReq.icon, '☕');
      expect(createReq.color, '#8B5CF6');

      final createJson = createReq.toJson();
      expect(createJson['name'], 'Cà phê & Trà');
      expect(createJson['type'], 'EXPENSE');

      final updateReq = CategoryMapper.toUpdateRequest(input);
      expect(updateReq.name, 'Cà phê & Trà');
      final updateJson = updateReq.toJson();
      expect(updateJson['name'], 'Cà phê & Trà');
    });
  });
}

