class ProductValidators {
  ProductValidators._();

  static final RegExp _skuRegex = RegExp(r'^[A-Z0-9\-_]+$');

  /// Kiểm tra tên sản phẩm: không để trống, độ dài từ 2 đến 200 ký tự.
  static String? validateName(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập tên sản phẩm';
    if (t.length < 2) return 'Tên quá ngắn (tối thiểu 2 ký tự)';
    if (t.length > 200) return 'Tên tối đa 200 ký tự';
    return null;
  }

  /// Kiểm tra mã SKU: không để trống, 2 đến 100 ký tự, chỉ chứa chữ/số/-/_
  static String? validateSku(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập mã SKU (bắt buộc theo chuẩn backend)';
    if (t.length < 2) return 'Mã SKU tối thiểu 2 ký tự';
    if (t.length > 100) return 'Mã SKU tối đa 100 ký tự';
    if (!_skuRegex.hasMatch(t.toUpperCase())) {
      return 'Mã SKU chỉ gồm chữ cái không dấu, số, gạch ngang (-) hoặc gạch dưới (_)';
    }
    return null;
  }

  /// Kiểm tra giá bán: số thực không âm (>= 0).
  static String? validatePrice(String? value) {
    final t = (value ?? '').trim().replaceAll(',', '.');
    if (t.isEmpty) return 'Vui lòng nhập giá sản phẩm';
    final n = double.tryParse(t);
    if (n == null) return 'Giá không hợp lệ';
    if (n < 0) return 'Giá phải >= 0';
    return null;
  }

  /// Kiểm tra tồn kho: số nguyên không âm (>= 0).
  static String? validateStock(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Vui lòng nhập số lượng tồn kho';
    final n = int.tryParse(t);
    if (n == null) return 'Số lượng không hợp lệ';
    if (n < 0) return 'Tồn kho phải >= 0';
    return null;
  }

  /// Kiểm tra đường dẫn URL ảnh (tuỳ chọn, nếu có phải đúng chuẩn URL có scheme/host).
  static String? validateImageUrl(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return null;
    final uri = Uri.tryParse(t);
    final ok = uri != null && uri.hasScheme && uri.host.isNotEmpty;
    return ok ? null : 'URL hình ảnh không hợp lệ';
  }
}
