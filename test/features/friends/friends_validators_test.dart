import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/friends/domain/validators/friends_validators.dart';

void main() {
  group('FriendsValidators - validateSearchQuery', () {
    test('trả về lỗi khi từ khóa rỗng', () {
      expect(
        FriendsValidators.validateSearchQuery(''),
        'Vui lòng nhập từ khóa tìm kiếm',
      );
      expect(
        FriendsValidators.validateSearchQuery(null),
        'Vui lòng nhập từ khóa tìm kiếm',
      );
      expect(
        FriendsValidators.validateSearchQuery('   '),
        'Vui lòng nhập từ khóa tìm kiếm',
      );
    });

    test('trả về lỗi khi từ khóa ngắn hơn 2 ký tự', () {
      expect(
        FriendsValidators.validateSearchQuery('a'),
        'Từ khóa tìm kiếm tối thiểu 2 ký tự',
      );
    });

    test('hợp lệ khi từ khóa từ 2 đến 100 ký tự', () {
      expect(FriendsValidators.validateSearchQuery('Trần Ngọc'), isNull);
      expect(FriendsValidators.validateSearchQuery('hung@gmail.com'), isNull);
    });
  });

  group('FriendsValidators - validateEmailOrPhone', () {
    test('trả về lỗi khi rỗng', () {
      expect(
        FriendsValidators.validateEmailOrPhone(''),
        'Vui lòng nhập email hoặc số điện thoại',
      );
    });

    test('kiểm tra định dạng email hợp lệ / không hợp lệ', () {
      expect(FriendsValidators.validateEmailOrPhone('valid@email.com'), isNull);
      expect(
        FriendsValidators.validateEmailOrPhone('invalid-email@'),
        'Email không đúng định dạng',
      );
    });

    test('kiểm tra số điện thoại Việt Nam hợp lệ / không hợp lệ', () {
      expect(FriendsValidators.validateEmailOrPhone('0912345678'), isNull);
      expect(FriendsValidators.validateEmailOrPhone('+84912345678'), isNull);
      expect(
        FriendsValidators.validateEmailOrPhone('01234'),
        'Số điện thoại Việt Nam không hợp lệ (10 chữ số)',
      );
    });
  });
}
