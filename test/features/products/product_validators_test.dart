import 'package:flutter_test/flutter_test.dart';
import 'package:finora_mb/features/products/domain/validators/product_validators.dart';

void main() {
  group('ProductValidators - validateName', () {
    test('trả về lỗi khi để trống', () {
      expect(ProductValidators.validateName(''), 'Vui lòng nhập tên sản phẩm');
      expect(ProductValidators.validateName('   '), 'Vui lòng nhập tên sản phẩm');
      expect(ProductValidators.validateName(null), 'Vui lòng nhập tên sản phẩm');
    });

    test('trả về lỗi khi tên dưới 2 ký tự', () {
      expect(ProductValidators.validateName('A'), 'Tên quá ngắn (tối thiểu 2 ký tự)');
    });

    test('trả về lỗi khi tên dài hơn 200 ký tự', () {
      final longName = 'A' * 201;
      expect(ProductValidators.validateName(longName), 'Tên tối đa 200 ký tự');
    });

    test('hợp lệ khi tên từ 2 đến 200 ký tự', () {
      expect(ProductValidators.validateName('Bàn phím cơ Finora'), isNull);
    });
  });

  group('ProductValidators - validateSku', () {
    test('trả về lỗi khi để trống', () {
      expect(
        ProductValidators.validateSku(''),
        'Vui lòng nhập mã SKU (bắt buộc theo chuẩn backend)',
      );
    });

    test('trả về lỗi khi SKU dưới 2 ký tự', () {
      expect(ProductValidators.validateSku('A'), 'Mã SKU tối thiểu 2 ký tự');
    });

    test('trả về lỗi khi chứa ký tự đặc biệt không hợp lệ', () {
      expect(
        ProductValidators.validateSku('SKU 123'),
        'Mã SKU chỉ gồm chữ cái không dấu, số, gạch ngang (-) hoặc gạch dưới (_)',
      );
      expect(
        ProductValidators.validateSku('SKU@#'),
        'Mã SKU chỉ gồm chữ cái không dấu, số, gạch ngang (-) hoặc gạch dưới (_)',
      );
    });

    test('hợp lệ khi đúng định dạng', () {
      expect(ProductValidators.validateSku('KB-FINORA-01'), isNull);
      expect(ProductValidators.validateSku('MOUSE_LOGI_X'), isNull);
    });
  });

  group('ProductValidators - validatePrice', () {
    test('trả về lỗi khi để trống hoặc không phải số', () {
      expect(ProductValidators.validatePrice(''), 'Vui lòng nhập giá sản phẩm');
      expect(ProductValidators.validatePrice('abc'), 'Giá không hợp lệ');
    });

    test('trả về lỗi khi giá âm', () {
      expect(ProductValidators.validatePrice('-1000'), 'Giá phải >= 0');
    });

    test('hợp lệ khi giá >= 0 (hỗ trợ cả dấu phẩy và chấm)', () {
      expect(ProductValidators.validatePrice('0'), isNull);
      expect(ProductValidators.validatePrice('1500000'), isNull);
      expect(ProductValidators.validatePrice('99.50'), isNull);
      expect(ProductValidators.validatePrice('99,50'), isNull);
    });
  });

  group('ProductValidators - validateStock', () {
    test('trả về lỗi khi để trống hoặc không phải số nguyên', () {
      expect(ProductValidators.validateStock(''), 'Vui lòng nhập số lượng tồn kho');
      expect(ProductValidators.validateStock('abc'), 'Số lượng không hợp lệ');
      expect(ProductValidators.validateStock('10.5'), 'Số lượng không hợp lệ');
    });

    test('trả về lỗi khi tồn kho âm', () {
      expect(ProductValidators.validateStock('-1'), 'Tồn kho phải >= 0');
    });

    test('hợp lệ khi tồn kho là số nguyên >= 0', () {
      expect(ProductValidators.validateStock('0'), isNull);
      expect(ProductValidators.validateStock('50'), isNull);
    });
  });

  group('ProductValidators - validateImageUrl', () {
    test('null khi để trống (vì ảnh là tuỳ chọn)', () {
      expect(ProductValidators.validateImageUrl(''), isNull);
      expect(ProductValidators.validateImageUrl(null), isNull);
      expect(ProductValidators.validateImageUrl('   '), isNull);
    });

    test('trả về lỗi khi URL không có scheme hoặc host', () {
      expect(ProductValidators.validateImageUrl('abc'), 'URL hình ảnh không hợp lệ');
      expect(ProductValidators.validateImageUrl('htp://'), 'URL hình ảnh không hợp lệ');
    });

    test('hợp lệ khi là link web đầy đủ', () {
      expect(
        ProductValidators.validateImageUrl('https://images.unsplash.com/photo-123'),
        isNull,
      );
    });
  });
}
