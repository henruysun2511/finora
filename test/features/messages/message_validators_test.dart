import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/messages/domain/validators/message_validators.dart';

void main() {
  group('MessageValidators - validateMessageContent', () {
    test('trả về lỗi khi tin nhắn rỗng hoặc chỉ có khoảng trắng', () {
      expect(MessageValidators.validateMessageContent(''), 'Tin nhắn không được để trống');
      expect(MessageValidators.validateMessageContent('   '), 'Tin nhắn không được để trống');
      expect(MessageValidators.validateMessageContent(null), 'Tin nhắn không được để trống');
    });

    test('hợp lệ khi có nội dung phù hợp', () {
      expect(MessageValidators.validateMessageContent('Chào bạn, chuyển cho mình 200k nhé'), isNull);
    });

    test('trả về lỗi khi vượt quá 2000 ký tự', () {
      final longText = 'a' * 2001;
      expect(MessageValidators.validateMessageContent(longText), 'Tin nhắn tối đa 2000 ký tự');
    });
  });
}
