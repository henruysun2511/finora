import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/core/widgets/lucide_icon.dart';

void main() {
  group('LucideIcon Normalize and Path Tests', () {
    test('normalizeIconName chuyển đổi đúng các emoji thường gặp sang Lucide icon name', () {
      expect(LucideIcon.normalizeIconName('🍽️'), 'utensils');
      expect(LucideIcon.normalizeIconName('🛍️'), 'shopping-bag');
      expect(LucideIcon.normalizeIconName('🚗'), 'car');
      expect(LucideIcon.normalizeIconName('💡'), 'zap');
      expect(LucideIcon.normalizeIconName('🎬'), 'gamepad-2');
      expect(LucideIcon.normalizeIconName('💰'), 'banknote');
      expect(LucideIcon.normalizeIconName('🏠'), 'home');
      expect(LucideIcon.normalizeIconName('✈️'), 'plane');
      expect(LucideIcon.normalizeIconName('💊'), 'pill');
      expect(LucideIcon.normalizeIconName('🎓'), 'graduation-cap');
      expect(LucideIcon.normalizeIconName('🎁'), 'gift');
      expect(LucideIcon.normalizeIconName('☕'), 'coffee');
      expect(LucideIcon.normalizeIconName('📱'), 'smartphone');
      expect(LucideIcon.normalizeIconName('❤️'), 'heart');
      expect(LucideIcon.normalizeIconName('💳'), 'credit-card');
      expect(LucideIcon.normalizeIconName('📈'), 'trending-up');
    });

    test('normalizeIconName hỗ trợ alias tiếng Anh và tên gạch dưới', () {
      expect(LucideIcon.normalizeIconName('food'), 'utensils');
      expect(LucideIcon.normalizeIconName('shopping_bag'), 'shopping-bag');
      expect(LucideIcon.normalizeIconName('gamepad_2'), 'gamepad-2');
      expect(LucideIcon.normalizeIconName('bills'), 'zap');
      expect(LucideIcon.normalizeIconName('salary'), 'banknote');
    });

    test('normalizeIconName fallback về "tag" khi không nhận diện được', () {
      expect(LucideIcon.normalizeIconName(null), 'tag');
      expect(LucideIcon.normalizeIconName(''), 'tag');
      expect(LucideIcon.normalizeIconName('unknown_random_icon_xyz'), 'tag');
    });

    test('Tất cả các icon trong kLucideSvgPaths đều có nội dung hợp lệ', () {
      for (final entry in kLucideSvgPaths.entries) {
        expect(entry.value, isNotEmpty, reason: 'Icon ${entry.key} không được rỗng');
        expect(entry.value.contains('<'), isTrue);
      }
    });
  });
}

