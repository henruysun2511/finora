import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/messages/domain/validators/message_validators.dart';

void main() {
  group('MessageValidators - validateContent', () {
    test('trả về lỗi khi tin nhắn null hoặc rỗng', () {
      expect(MessageValidators.validateContent(null), 'Nội dung tin nhắn không được để trống');
      expect(MessageValidators.validateContent(''), 'Nội dung tin nhắn không được để trống');
      expect(MessageValidators.validateContent('    '), 'Nội dung tin nhắn không được để trống');
    });

    test('trả về lỗi khi tin nhắn vượt quá 2000 ký tự', () {
      final longText = 'a' * 2001;
      expect(MessageValidators.validateContent(longText), 'Tin nhắn tối đa 2000 ký tự');
    });

    test('hợp lệ khi nội dung từ 1 đến 2000 ký tự', () {
      expect(MessageValidators.validateContent('Chào bạn, mình gửi hoá đơn hôm nay nhé!'), isNull);
      expect(MessageValidators.validateContent('a' * 2000), isNull);
    });
  });

  group('MessageValidators - validateReceiverId', () {
    test('trả về lỗi khi chưa có receiverId', () {
      expect(MessageValidators.validateReceiverId(null), 'Vui lòng chỉ định người nhận tin nhắn');
      expect(MessageValidators.validateReceiverId(''), 'Vui lòng chỉ định người nhận tin nhắn');
    });

    test('hợp lệ khi receiverId hợp lệ', () {
      expect(MessageValidators.validateReceiverId('user_123'), isNull);
    });
  });
}

